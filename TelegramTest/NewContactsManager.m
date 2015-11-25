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

#import "TGHashContact.h"
#define INIT_HASH_CHEKER() __block NSUInteger hash = self.contactsHash;
#define HASH_CHECK() if(self.contactsHash != hash) return;

@interface NewContactsManager()
@end

@implementation NewContactsManager

+ (id)sharedManager {
    static NewContactsManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NewContactsManager alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}


- (id) initWithQueue:(ASQueue *)queue {
    self = [super initWithQueue:queue];
    if(self) {
        [Notification addObserver:self selector:@selector(protocolUpdated:) name:PROTOCOL_UPDATED];
        [Notification addObserver:self selector:@selector(userStatusChanged:) name:USER_STATUS];
    }
    return self;
}

-(void)userStatusChanged:(NSNotification *)notification
{
    [self.queue dispatchOnQueue:^{
        [self sortAndNotify:YES];
    }];
    
}

- (void)protocolUpdated:(NSNotification *)notify {
    [self getStatuses:nil];
}


- (void) fullReload {
        
    [self.queue dispatchOnQueue:^{
        [self->keys removeAllObjects];
        [self->list removeAllObjects];
        
        [[Storage manager] contacts:^(NSArray *contacts) {
            
            [self.queue dispatchOnQueue:^{
                [self add:contacts withCustomKey:@"user_id"];
                
                [Notification perform:CONTACTS_MODIFIED data:@{@"CONTACTS_RELOAD": self->list}];
                
                [self remoteCheckContacts:^{
                    
                    [self iCloudSync];
                    
                }];
            }];
        }];
        
        
        
        
    }];
}


-(void)iCloudSync {
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"icloudsync"]) {
        [[Storage manager] importedContacts:^(NSSet *imported) {
            
            [self.queue dispatchOnQueue:^{
                [self importCloudContacts:imported];
            }];
            
        }];
    }
}


-(void)add:(NSArray *)all withCustomKey:(NSString*)key {
    [self.queue dispatchOnQueue:^{
        [super add:all withCustomKey:key];
        
        [self sortAndNotify:NO];
    }];
}

-(void)sortAndNotify:(BOOL)notify
{
    
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"self.user.lastSeenTime" ascending:NO];
    
    [self->list sortUsingDescriptors:@[descriptor]];
    
    
    if(notify)
    {
        [Notification perform:CONTACTS_SORT_CHANGED data:@{}];
    }
}


-(void)drop
{
    [self.queue dispatchOnQueue:^{
        [self->list removeAllObjects];
        [Notification perform:CONTACTS_MODIFIED data:@{KEY_CONTACTS:self->list}];
    }];
}



-(void)importCloudContacts:(NSSet *)importedSet {
    
    
    
    [self.queue dispatchOnQueue:^{
        
         NSArray *all = [[ABAddressBook sharedAddressBook] people];
        
        NSMutableSet *abset = [[NSMutableSet alloc] init];
        
        
        for (ABPerson *person in all) {
            
            ABMutableMultiValue * phones = [person valueForKey:kABPhoneProperty];
            
            for (int i = 0; i < phones.count; i++) {
                
                NSString *phoneNumber = [phones valueAtIndex:i];
                NSString *firstName = [person valueForProperty:kABFirstNameProperty];
                NSString *lastName = [person valueForProperty:kABLastNameProperty];
                
                if(!firstName)
                    firstName = @"";
                if(!lastName)
                    lastName = @"";
                
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneNumber length])];
                
                TGHashContact *contact = [[TGHashContact alloc] initWithHash:[NSString stringWithFormat:@"%@:tg-itemQ:%@:tg-itemQ:%@",firstName,lastName,phoneNumber]];
                
                [abset addObject:contact];
            }
            
        }
        
        NSMutableSet *changedSet = [abset mutableCopy];
        [changedSet minusSet:importedSet];
        
        
        NSMutableSet *deleteSet = [importedSet mutableCopy];
        [deleteSet minusSet:abset];
        
        
        NSMutableArray *import = [[NSMutableArray alloc] init];
        [changedSet enumerateObjectsUsingBlock:^(TGHashContact *obj, BOOL *stop) {
            
            NSArray *params = [[obj hashObject] componentsSeparatedByString:@":tg-itemQ:"];

            [import addObject:[TL_inputPhoneContact createWithClient_id:[obj hash] phone:params[2] first_name:params[0] last_name:params[1]]];
        }];
        
        
        if(import.count > 0) {
            [RPCRequest sendRequest:[TLAPI_contacts_importContacts createWithContacts:import replace:NO] successHandler:^(RPCRequest *request, TL_contacts_importedContacts *contacts) {
                
                [SharedManager proccessGlobalResponse:contacts];
                
                NSMutableArray *addedContacts = [[NSMutableArray alloc] init];
                
                [[contacts imported] enumerateObjectsUsingBlock:^(TLImportedContact *importedContact, NSUInteger idx, BOOL *stop) {
                    
                    if(![self find:importedContact.user_id withCustomKey:@"user_id"])
                        [addedContacts addObject:[TL_contact createWithUser_id:importedContact.user_id mutual:YES]];
                    
                    [changedSet enumerateObjectsUsingBlock:^(TGHashContact *contact, BOOL *stop) {
                        
                        if(contact.hash == importedContact.client_id) {
                            
                            contact.user_id = importedContact.user_id;
                        }
                        
                    }];
                    
                }];
                
                [[Storage manager] insertImportedContacts:changedSet];
                
                [[Storage manager] insertContacst:addedContacts];
                
                [self add:addedContacts withCustomKey:@"user_id"];
                
                
                [Notification perform:CONTACTS_MODIFIED data:@{@"CONTACTS_RELOAD": self->list}];
                
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"icloudsync"];
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
               
            } timeout:10 queue:self.queue.nativeQueue];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"icloudsync"];
        }
        
        
    }];
    
}

-(void)getStatuses:(dispatch_block_t)callback {
    [RPCRequest sendRequest:[TLAPI_contacts_getStatuses create] successHandler:^(RPCRequest *request, id response) {
        
        for (TL_contactStatus *contactStatus in response) {
            
            [[UsersManager sharedManager] setUserStatus:contactStatus.status forUid:contactStatus.user_id];
        }
        
        if(callback) {
            [ASQueue dispatchOnMainQueue:^{
                callback();
            }];
        }
        
        
    } errorHandler:nil timeout:0 queue:self.queue.nativeQueue];
}

- (void) remoteCheckContacts:(dispatch_block_t)callback {
    
    [self.queue dispatchOnQueue:^{
        
        NSArray *allKeys = [[self->keys allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 intValue] > [obj2 intValue];
        }];
        NSString *md5Hash = [[allKeys componentsJoinedByString:@","] md5];
        

        [RPCRequest sendRequest:[TLAPI_contacts_getContacts createWithN_hash:md5Hash] successHandler:^(RPCRequest *request, id response) {
            
            if([response isKindOfClass:[TL_contacts_contacts class]]) {
                
                [SharedManager proccessGlobalResponse:response];

                [[Storage manager] dropContacts];
                [[Storage manager] insertContacst:[response contacts]];
                
                [self->keys removeAllObjects];
                [self->list removeAllObjects];
                
               
                [self add:[response contacts] withCustomKey:@"user_id"];
                
                [Notification perform:CONTACTS_MODIFIED data:@{@"CONTACTS_RELOAD": self->list}];
            }
            
            callback();
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            callback();
        } timeout:10 queue:self.queue.nativeQueue];
    }];
    
}

- (void) insertContact:(TLContact *)contact {
    
    [self.queue dispatchOnQueue:^{
        if(![self find:contact.user_id withCustomKey:@"user_id"]) {
            [self add:@[contact] withCustomKey:@"user_id"];
            [Notification perform:CONTACTS_MODIFIED data:@{@"CONTACTS_RELOAD": self->list}];
            [[Storage manager] insertContact:contact];
        }
        
    }];
}

- (void) deleteContact:(TLUser *)user completeHandler:(void (^)(BOOL result))compleHandler {
    [RPCRequest sendRequest:[TLAPI_contacts_deleteContact createWithN_id:[user inputUser]] successHandler:^(RPCRequest *request, TL_contacts_link *response) {
        
        TLUser *user = response.user;
        [[UsersManager sharedManager] add:[NSArray arrayWithObject:user]];
        
        TLContact *contact = [TL_contact createWithUser_id:user.n_id mutual:NO];
        
        
        
        [self removeContact:contact];
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            compleHandler(YES);
        }];
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [[ASQueue mainQueue] dispatchOnQueue:^{
            compleHandler(NO);
        }];
        
    } timeout:10 queue:self.queue.nativeQueue];
}

- (void) removeContact:(TLContact *)contact {
    [self.queue dispatchOnQueue:^{
        id f = [self find:contact.user_id withCustomKey:@"user_id"];
        if(f) {
            [self remove:@[f] withCustomKey:@"user_id"];
            [Notification perform:CONTACTS_MODIFIED data:@{@"CONTACTS_RELOAD": self->list}];
            [[Storage manager] removeContact:f];
        }
    }];
}

- (void) importContact:(TL_inputPhoneContact *)contact callback:(void (^)(BOOL isAdd, TL_importedContact *contact, TLUser *user))callback {
    

    
    [RPCRequest sendRequest:[TLAPI_contacts_importContacts createWithContacts:(NSMutableArray *)[NSArray arrayWithObject:contact] replace:NO] successHandler:^(RPCRequest *request, TL_contacts_importedContacts *response) {
        
        if(!response.imported.count) {
            [ASQueue dispatchOnMainQueue:^{
                callback(NO, nil, nil);
            }];
            return;
        }
        
        
        [SharedManager proccessGlobalResponse:response];
        
        TL_importedContact *importedContact = [response.imported objectAtIndex:0];
        
        TLUser *userContact = nil;
        for(TLUser *user in response.users) {
            if(user.n_id == importedContact.user_id)
                userContact = user;
        }
        
        TGHashContact *hashContact = [[TGHashContact alloc] initWithHash:[NSString stringWithFormat:@"%@:tg-itemQ:%@:tg-itemQ:%@",userContact.first_name,userContact.last_name,userContact.phone] user_id:userContact.n_id];
        
        [[Storage manager] insertImportedContacts:[NSSet setWithObject:hashContact]];
        
        TLContact *contact = [TL_contact createWithUser_id:importedContact.user_id mutual:YES];
        
        [[Storage manager] insertContact:contact];
        
        [self add:@[contact] withCustomKey:@"hash"];
        
        ABAddressBook *book = [ABAddressBook sharedAddressBook];
        if(book) {
            
            NSArray *all = [[ABAddressBook sharedAddressBook] people];
            
            __block BOOL needCreate = YES;
            
            [all enumerateObjectsUsingBlock:^(ABPerson *person, NSUInteger idx, BOOL *stop) {
                ABMutableMultiValue * phones = [person valueForKey:kABPhoneProperty];
                
               
                
                for (int i = 0; i < [phones count]; i++) {
                    NSString *phone = [phones valueAtIndex:0];
                    phone = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
                    
                    if([phone isEqualToString:userContact.phone]) {
                        
                        [person setValue:userContact.first_name forProperty:kABFirstNameProperty];
                        [person setValue:userContact.last_name forProperty:kABLastNameProperty];
                        
                        needCreate = NO;
                        
                    }
                }
            }];
            
            if (needCreate) {
                ABPerson* person = [[ABPerson alloc] init];
                [person setValue:userContact.first_name forProperty:kABFirstNameProperty];
                [person setValue:userContact.last_name forProperty:kABLastNameProperty];
                ABMutableMultiValue *phone = [[ABMutableMultiValue alloc] init];
                [phone addValue:userContact.phoneWithFormat withLabel:kABPhoneMobileLabel];
                
                [person setValue:phone forProperty:kABPhoneProperty];
                
                [book addRecord:person];
            }
            
            [book save];
            
            
        }
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            callback(YES, importedContact, userContact);
        }];
        
        [Notification perform:CONTACTS_MODIFIED data:@{@"CONTACTS_RELOAD": self->list}];
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            callback(NO, nil, nil);
        }];
        
    } timeout:0 queue:self.queue.nativeQueue];
}



@end