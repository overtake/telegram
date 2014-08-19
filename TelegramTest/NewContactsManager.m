//
//  NewContactsManager.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NewContactsManager.h"
#import "Storage.h"
#import <AddressBook/AddressBook.h>
#import <zlib.h>
#define INIT_HASH_CHEKER() __block NSUInteger hash = self.contactsHash;
#define HASH_CHECK() if(self.contactsHash != hash) return;

@interface NewContactsManager()
@property (nonatomic) NSUInteger contactsHash;
@end

@implementation NewContactsManager

+ (id)sharedManager {
    static NewContactsManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NewContactsManager alloc] init];
    });
    return instance;
}


- (id) init {
    self = [super init];
    if(self) {
        [Notification addObserver:self selector:@selector(protocolUpdated:) name:PROTOCOL_UPDATED];
    }
    return self;
}

- (void)protocolUpdated:(NSNotification *)notify {
    [self getStatuses];
}


- (void) fullReload {
    DLog(@"");
    [self->keys removeAllObjects];
    self->keys = [[NSMutableDictionary alloc] init];
    self->list = [[NSMutableArray alloc] init];
    self.contactsHash = [[NSString randStringWithLength:10] hash];

    INIT_HASH_CHEKER();
    [[Storage manager] contacts:^(NSArray *contacts) {
        
        [ASQueue dispatchOnStageQueue:^{
            HASH_CHECK();
            [self->list addObjectsFromArray:contacts];
            for(TGContact *contact in contacts)
                [self insertContact:contact insertToDB:NO];
            
            [Notification perform:CONTACTS_MODIFIED data:@{KEY_CONTACTS : self->list}];
            
            [self remoteCheckContacts];
        }];
        
    }];
}


-(void)drop
{
    [ASQueue dispatchOnStageQueue:^{
        [self->list removeAllObjects];
        [Notification perform:CONTACTS_MODIFIED data:@{KEY_CONTACTS:self->list}];
    }];
}

-(void)syncContacts:(void (^)(void))callback {
    [[Storage manager] importedContacts:^(NSDictionary *imported) {
        [self importCloudContacts:imported callback:callback];
    }];

}

-(void)importCloudContacts:(NSDictionary *)imported callback:(void (^)(void))callback {
    
    
    [ASQueue dispatchOnStageQueue:^{
        NSArray *all = [[ABAddressBook sharedAddressBook] people];
        NSMutableArray *import = [[NSMutableArray alloc] init];
        NSMutableDictionary *toImportCheck = [[NSMutableDictionary alloc] init];
        for (ABPerson *person in all) {
            
            ABMutableMultiValue * phones = [person valueForKey:kABPhoneProperty];
            long client_id = [person hash];
            
            TGImportedContact *k = [imported objectForKey:[NSNumber numberWithLong:client_id]];
            TL_inputPhoneContact *contact = [TL_inputPhoneContact createWithClient_id:client_id phone:[phones valueAtIndex:0] first_name:[person valueForProperty:kABFirstNameProperty] last_name:[person valueForProperty:kABLastNameProperty]];
            if(!k) {
                [import addObject:contact];
                [toImportCheck setObject:contact forKey:[NSNumber numberWithLong:client_id]];
            }
        }
        
        if(import.count > 0) {
            [RPCRequest sendRequest:[TLAPI_contacts_importContacts createWithContacts:import replace:NO] successHandler:^(RPCRequest *request, id response) {
                TL_contacts_importedContacts *contacts = response;
                
                
                [ASQueue dispatchOnStageQueue:^{
                    [[Storage manager] insertImportedContacts:[contacts imported] completeHandler:nil];
                    [SharedManager proccessGlobalResponse:response];
                    
                    NSMutableArray *newContacts = [[NSMutableArray alloc] init];
                    for (TGImportedContact *imported in [contacts imported]) {
                        [newContacts addObject:[TL_contact createWithUser_id:imported.user_id mutual:YES]];
                        [toImportCheck removeObjectForKey:[NSNumber numberWithLong:imported.client_id]];
                    }
                    [[Storage manager] insertContacst:newContacts completeHandler:nil];
                    [self add:newContacts withCustomKey:@"user_id"];
                    
                    [[ASQueue mainQueue] dispatchOnQueue:^{
                        if(callback)
                            callback();
                    }];

                }];
                
                
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                NSLog(@"error import %@", error.error_msg);
                if(callback)
                    callback();
            } timeout:10];
        } else {
            if(callback)
                callback();
        }

    }];
    
}

-(void)getStatuses {
    [RPCRequest sendRequest:[TLAPI_contacts_getStatuses create] successHandler:^(RPCRequest *request, id response) {
        for (TGContactStatus *status in response) {
            TGUserStatus *userStatus = [TL_userStatusOnline createWithExpires:status.expires];
            
            [[UsersManager sharedManager] setUserStatus:userStatus forUid:status.user_id];            
        }
    } errorHandler:nil];
}

- (void) remoteCheckContacts {
    

    [ASQueue dispatchOnStageQueue:^{
        NSArray *allKeys = [[self->keys allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 intValue] > [obj2 intValue];
        }];
        NSString *md5Hash = [[allKeys componentsJoinedByString:@","] md5];
        
        INIT_HASH_CHEKER();
        [RPCRequest sendRequest:[TLAPI_contacts_getContacts createWithHash:md5Hash] successHandler:^(RPCRequest *request, id response) {
            HASH_CHECK();
            
            if([response isKindOfClass:[TL_contacts_contacts class]]) {
                TL_contacts_contacts* result = response;
                
                [SharedManager proccessGlobalResponse:response];
                
                
                NSMutableArray *needSave = [[NSMutableArray alloc] init];
                
                [result.contacts enumerateObjectsUsingBlock:^(TL_contact *obj, NSUInteger idx, BOOL *stop) {
                    TL_contact *local = self->keys[@(obj.user_id)];
                    
                    if(local.mutual != obj.mutual) {
                        [needSave addObject:obj];
                    }
                }];
                
                [[Storage manager] replaceContacts:needSave completeHandler:nil];
                
                
                [self->keys removeAllObjects];
                [self->list removeAllObjects];
                
                [self->list addObjectsFromArray:result.contacts];
                for(TGContact *contact in result.contacts)
                    [self insertContact:contact insertToDB:NO];
                
                DLog(@"");
                [Notification perform:CONTACTS_MODIFIED data:@{@"CONTACTS_RELOAD": self->keys}];
            }
        } errorHandler:nil timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    }];
    
}

- (void) insertContact:(TGContact *)contact insertToDB:(BOOL)insertToDB {
    [ASQueue dispatchOnStageQueue:^{
        [self->keys setObject:contact forKey:[NSNumber numberWithInt:contact.user_id]];
        if(insertToDB) {
            [[Storage manager] insertContact:contact completeHandler:nil];
        }
    }];
}

- (void) deleteContact:(TGUser *)user completeHandler:(void (^)(BOOL result))compleHandler {
    [RPCRequest sendRequest:[TLAPI_contacts_deleteContact createWithN_id:[user inputUser]] successHandler:^(RPCRequest *request, TL_contacts_link *response) {
        
        TGUser *user = response.user;
        [[UsersManager sharedManager] add:[NSArray arrayWithObject:user]];
        
        TGContact *contact = [TL_contact createWithUser_id:user.n_id mutual:NO];
        [self removeContact:contact removeFromDB:YES];
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            compleHandler(YES);
        }];
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [[ASQueue mainQueue] dispatchOnQueue:^{
            compleHandler(NO);
        }];
        
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
}

- (void) removeContact:(TGContact *)contact removeFromDB:(BOOL)removeFromDB {
    [ASQueue dispatchOnStageQueue:^{
        [self->keys removeObjectForKey:[NSNumber numberWithInt:contact.user_id]];
        [self->list removeObject:contact];
        if(removeFromDB) {
            [[Storage manager] removeContact:contact completeHandler:nil];
        }

    }];
}

- (void) importContact:(TL_inputPhoneContact *)contact callback:(void (^)(BOOL isAdd, TL_importedContact *contact, TGUser *user))callback {
    
    INIT_HASH_CHEKER();
    [RPCRequest sendRequest:[TLAPI_contacts_importContacts createWithContacts:(NSMutableArray *)[NSArray arrayWithObject:contact] replace:NO] successHandler:^(RPCRequest *request, TL_contacts_importedContacts *response) {
        HASH_CHECK();
        
        

        if(!response.imported.count)
            return callback(NO, nil, nil);
        
        [SharedManager proccessGlobalResponse:response];
        
        TL_importedContact *importedContact = [response.imported objectAtIndex:0];
        
        TGUser *userContact = nil;
        for(TGUser *user in response.users) {
            if(user.n_id == importedContact.user_id)
                userContact = user;
        }
        
        TGContact *contact = [TL_contact createWithUser_id:userContact.n_id mutual:NO];
        [self insertContact:contact insertToDB:YES];
        
        [self add:@[contact] withCustomKey:@"user_id"];
        
        ABAddressBook *book = [ABAddressBook sharedAddressBook];
        if(book) {
            ABPerson* person = [[ABPerson alloc] init];
            [person setValue:userContact.first_name forProperty:kABFirstNameProperty];
            [person setValue:userContact.last_name forProperty:kABLastNameProperty];
            ABMutableMultiValue *phone = [[ABMutableMultiValue alloc] init];
            [phone addValue:userContact.phone withLabel:kABPhoneMobileLabel];
            
            [person setValue:phone forProperty:kABPhoneProperty];
            
            [book addRecord:person];
            [book save];
        }
       
        [[ASQueue mainQueue] dispatchOnQueue:^{
            callback(YES, importedContact, userContact);
        }];
        
        [Notification perform:@"NEW_CONTACT" data:@{@"contact": contact, @"user": userContact}];
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        HASH_CHECK();

        [[ASQueue mainQueue] dispatchOnQueue:^{
            callback(NO, nil, nil);
        }];
        
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
}

@end