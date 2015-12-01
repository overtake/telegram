//
//  UsersManager.m
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "UsersManager.h"
#import "UploadOperation.h"
#import "TLFileLocation+Extensions.h"
#import "ImageUtils.h"
#import "TGTimer.h"
#import <AddressBook/AddressBook.h>
#import "TLUserCategory.h"
@interface UsersManager ()
@property (nonatomic, strong) TGTimer *lastSeenUpdater;
@property (nonatomic, strong) RPCRequest *lastSeenRequest;
@end

@implementation UsersManager


- (id)initWithQueue:(ASQueue *)queue {
    if(self = [super initWithQueue:queue]) {
        [Notification addObserver:self selector:@selector(protocolUpdated:) name:PROTOCOL_UPDATED];
        [Notification addObserver:self selector:@selector(logoutNotification) name:LOGOUT_EVENT];
    }
    return self;
}

- (void)protocolUpdated:(NSNotification *)notify {
    [self.queue dispatchOnQueue:^{
        [self.lastSeenUpdater invalidate];
        [self.lastSeenRequest cancelRequest];
        
//        self.lastSeenUpdater = [[TGTimer alloc] initWithTimeout:300 repeat:YES completion:^{
//            [self statusUpdater];
//        } queue:self.queue.nativeQueue];
//        
//        [self.lastSeenUpdater start];
      //  [self statusUpdater];
    }];
}

- (void)statusUpdater {
    [self.lastSeenRequest cancelRequest];
    
    NSMutableArray *needUsersUpdate = [[NSMutableArray alloc] init];
    for(TLUser *user in list) {
        if(user.lastSeenUpdate + 300 < [[MTNetwork instance] getTime]) {
            if(user.type == TLUserTypeForeign || user.type == TLUserTypeRequest) {
                [needUsersUpdate addObject:user.inputUser];
                if(needUsersUpdate.count >= 100)
                    break;
            }
        }
    }
    
    if(needUsersUpdate.count == 0)
        return;
    
    self.lastSeenRequest = [RPCRequest sendRequest:[TLAPI_users_getUsers createWithN_id:needUsersUpdate] successHandler:^(RPCRequest *request, NSMutableArray *response) {
        
        [self add:response withCustomKey:@"n_id" update:YES];
        
    } errorHandler:nil];
}

- (void)logoutNotification {
    [self.queue dispatchOnQueue:^{
        [self.lastSeenRequest cancelRequest];
        [self.lastSeenUpdater invalidate];
        self.lastSeenUpdater = nil;
    }];
}

-(void)drop {
    [self.queue dispatchOnQueue:^{
        [self->list removeAllObjects];
        [self->keys removeAllObjects];
    }];
}

-(void)loadUsers:(NSArray *)users completeHandler:(void (^)())completeHandler {
    
    [RPCRequest sendRequest:[TLAPI_users_getUsers createWithN_id:[users mutableCopy]] successHandler:^(RPCRequest *request, id response) {
        
        [self add:response];
        if(completeHandler)
            completeHandler();
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(completeHandler) {
            completeHandler();
        }
    }];
}

+(NSArray *)findUsersByName:(NSString *)userName {
    
    if([userName hasPrefix:@"@"])
        userName = [userName substringFromIndex:1];
    
    return [[[UsersManager sharedManager] all] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.username BEGINSWITH[c] %@",userName]];
}

+(TLUser *)findUserByName:(NSString *)userName {
    if([userName hasPrefix:@"@"])
        userName = [userName substringFromIndex:1];
    
    NSArray *users = [[[UsersManager sharedManager] all] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.username == %@",userName]];
    
    if(users.count == 1)
        return users[0];
    
    return nil;
}

+(NSArray *)findUsersByMention:(NSString *)userName withUids:(NSArray *)uids {
    if([userName hasPrefix:@"@"])
        userName = [userName substringFromIndex:1];
    
    
    NSArray *userNames;
    NSArray *fullName;
    
    if(userName.length > 0) {
        userNames = [[[UsersManager sharedManager] all] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.username BEGINSWITH[c] %@ AND self.n_id IN %@",userName,uids]];
        
        
        fullName = [[[UsersManager sharedManager] all] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TLUser *evaluatedObject, NSDictionary *bindings) {
            
            return evaluatedObject.username.length > 0 && [evaluatedObject.fullName searchInStringByWordsSeparated:userName] && [uids indexOfObject:@(evaluatedObject.n_id)] != NSNotFound;
            
        }]];
    } else {
        
        userNames = [[[UsersManager sharedManager] all] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TLUser *evaluatedObject, NSDictionary *bindings) {
            
            return evaluatedObject.username.length > 0 && [uids indexOfObject:@(evaluatedObject.n_id)] != NSNotFound;
            
        }]];
        
        fullName = @[];
        
    }
    
    
    
    
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:userNames];
    
    [fullName enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([result indexOfObject:obj] == NSNotFound) {
            [result addObject:obj];
        }
        
    }];
    
    [result removeObject:[self currentUser]];
    
    return result;

}

- (void)addFromDB:(NSArray *)array {
    [self add:array withCustomKey:@"n_id" update:NO];
}

- (void)add:(NSArray *)all withCustomKey:(NSString *)key {
    [self add:all withCustomKey:key update:YES];
}

- (void)add:(NSArray *)all withCustomKey:(NSString *)key update:(BOOL)isNeedUpdateDB {

    [self.queue dispatchOnQueue:^{
        
        NSMutableArray *usersToUpdate = [NSMutableArray array];
        
        for (TLUser *newUser in all) {
            TLUser *currentUser = [keys objectForKey:[newUser valueForKey:key]];
            
            if(newUser.first_name.length == 0 && newUser.last_name.length == 0)
            {
                newUser.first_name =  NSLocalizedString(@"User.Deleted", nil);
            }
            
            
           
            
            BOOL needUpdateUserInDB = NO;
            if(currentUser) {
                BOOL isNeedRebuildNames = NO;
                BOOL isNeedChangeTypeNotify = NO;
                
                currentUser.flags = newUser.flags;
                
                
                if(newUser.type != currentUser.type) {
                    [currentUser setType:newUser.type];
                    
                    isNeedRebuildNames = YES;
                    isNeedChangeTypeNotify = YES;
                    
                    needUpdateUserInDB = YES;
                }
                
                if(currentUser.type != TLUserTypeEmpty) {
                    if(![newUser.first_name isEqualToString:currentUser.first_name] || ![newUser.last_name isEqualToString:currentUser.last_name] || ![newUser.username isEqualToString:currentUser.username] || ( newUser.phone && ![newUser.phone isEqualToString:currentUser.phone])) {
                        
            
                        currentUser.first_name = newUser.first_name;
                        currentUser.last_name = newUser.last_name;
                        currentUser.username = newUser.username;
                        currentUser.phone = newUser.phone;
                        
                        isNeedRebuildNames = YES;
                        
                        needUpdateUserInDB = YES;
                    }
                }
                
                if(currentUser.photo.photo_small.hashCacheKey != newUser.photo.photo_small.hashCacheKey) {
                    currentUser.photo = newUser.photo;
                    
                    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:currentUser.photo.photo_id media:[TL_photoSize createWithType:@"x" location:currentUser.photo.photo_big w:640 h:640 size:0] peer_id:currentUser.n_id];

                    [Notification perform:USER_UPDATE_PHOTO data:@{KEY_USER: currentUser, KEY_PREVIEW_OBJECT:previewObject}];
                    needUpdateUserInDB = YES;
                }
                
                currentUser.access_hash = newUser.access_hash;
                
                if(!currentUser.phone || !currentUser.phone.length)
                    currentUser.phone = newUser.phone;
                
                if(isNeedRebuildNames) {
                    [currentUser rebuildNames];
                    [Notification perform:USER_UPDATE_NAME data:@{KEY_USER: currentUser}];
                }
                
                if(isNeedChangeTypeNotify) {
                    [Notification perform:[Notification notificationForUser:currentUser action:USER_CHANGE_TYPE] data:@{KEY_USER:currentUser}];
                }
                
            } else {
                
                
                if(newUser.type == TLUserTypeEmpty) {
                    newUser.first_name = @"Deleted";
                    newUser.last_name = @"";
                    newUser.phone = @"";
                    newUser.username = @"";
                }
                
                [self->list addObject:newUser];
                [self->keys setObject:newUser forKey:[newUser valueForKey:key]];
                
                [newUser rebuildNames];
                
                
                
                [newUser rebuildType];
                
                 currentUser = newUser;
                if(isNeedUpdateDB) {
                    currentUser.lastSeenUpdate = [[MTNetwork instance] getTime];
                }

                
                needUpdateUserInDB = YES;
            }
            
            if(currentUser.type == TLUserTypeSelf)
                _userSelf = currentUser;
            
            BOOL result = [self setUserStatus:newUser.status forUser:currentUser];
            if(!needUpdateUserInDB && result) {
                needUpdateUserInDB = YES;
            }
            
            if(needUpdateUserInDB && isNeedUpdateDB) {
                [usersToUpdate addObject:newUser];
            }
        }
        
        
        
        if(usersToUpdate.count)
            [[Storage manager] insertUsers:usersToUpdate completeHandler:nil];
    }];
    
}

- (BOOL)setUserStatus:(TLUserStatus *)status forUser:(TLUser *)currentUser {
    
    BOOL result = currentUser.status.expires != status.expires && currentUser.status.was_online != status.was_online && currentUser.status.class != status.class;
    
    BOOL saveOnlyTime = currentUser.status.class == status.class || (([currentUser.status isKindOfClass:[TL_userStatusOnline class]] || [currentUser.status isKindOfClass:[TL_userStatusOffline class]])  && ([status isKindOfClass:[TL_userStatusOnline class]] || [status isKindOfClass:[TL_userStatusOffline class]]));
    
    currentUser.status = status;
    currentUser.lastSeenUpdate = [[MTNetwork instance] getTime];
    currentUser.status.was_online = status.was_online;
    currentUser.status.expires = status.expires;
    
    if(result)
        [Notification perform:USER_STATUS data:@{KEY_USER_ID: @(currentUser.n_id)}];
    
    
    if(result) {
        if(saveOnlyTime) {
            [[Storage manager] updateUsersStatus:@[currentUser]];
        } else {
             [[Storage manager] insertUser:currentUser completeHandler:nil];
        }
    }
    
    return result;
}

- (void)setUserStatus:(TLUserStatus *)status forUid:(int)uid {
    [self.queue dispatchOnQueue:^{
        TLUser *currentUser = [keys objectForKey:@(uid)];
        if(currentUser) {
            BOOL result = [self setUserStatus:status forUser:currentUser];
        }
    }];
}


+ (int)currentUserId {
    return [[UsersManager sharedManager] userSelf].n_id;
}


+ (TLUser *)currentUser {
    
    TLUser *user = [[UsersManager sharedManager] userSelf];
    
    if(!user) {
        NSData *data = [[Telegram standartUserDefaults] objectForKey:@"selfUser"];
        if(data) {
            user = [TLClassStore deserialize:data];
            [user rebuildNames];
        }
        
    }
    
    return user;
}



-(void)updateUserName:(NSString *)userName completeHandler:(void (^)(TLUser *))completeHandler errorHandler:(void (^)(NSString *))errorHandler {
    
    if([userName isEqualToString:self.userSelf.username] )
    {
        completeHandler(self.userSelf);
        
        return;
    }
    
    [RPCRequest sendRequest:[TLAPI_account_updateUsername createWithUsername:userName] successHandler:^(RPCRequest *request, TLUser *response) {
        
        if(response.type == TLUserTypeSelf) {
            [self add:@[response]];
        }
        
        [self.userSelf rebuildNames];
        
        [[Storage manager] insertUser:self.userSelf completeHandler:nil];
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            completeHandler(self.userSelf);
        }];
        
        [Notification perform:USER_UPDATE_NAME data:@{KEY_USER:self.userSelf}];

        
     } errorHandler:^(RPCRequest *request, RpcError *error) {
         
         [ASQueue dispatchOnMainQueue:^{
             if(errorHandler)
                 errorHandler(NSLocalizedString(@"Profile.CantUpdate", nil));
         }];
         
     } timeout:10 queue:self.queue.nativeQueue];
}




-(void)updateAccount:(NSString *)firstName lastName:(NSString *)lastName completeHandler:(void (^)(TLUser *))completeHandler errorHandler:(void (^)(NSString *))errorHandler {
    
    firstName = firstName.length > 30 ? [firstName substringToIndex:30] : firstName;
    
    lastName = lastName.length > 30 ? [lastName substringToIndex:30] : lastName;
    
    
    if([firstName isEqualToString:self.userSelf.first_name] && [lastName isEqualToString:self.userSelf.last_name])
    {
        completeHandler(self.userSelf);
        
        return;
    }
    
    
    self.userSelf.first_name = firstName;
    self.userSelf.last_name = lastName;
    
    [self.userSelf rebuildNames];
    
    [Notification perform:USER_UPDATE_NAME data:@{KEY_USER:self.userSelf}];
    
    
    [RPCRequest sendRequest:[TLAPI_account_updateProfile createWithFirst_name:firstName last_name:lastName] successHandler:^(RPCRequest *request, TLUser *response) {
        
        if(response.type == TLUserTypeSelf) {
            [self add:@[response]];
        }
        
        [[Storage manager] insertUser:self.userSelf completeHandler:nil];
        
        completeHandler(self.userSelf);
        [Notification perform:USER_UPDATE_NAME data:@{KEY_USER:self.userSelf}];
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(errorHandler)
            errorHandler(NSLocalizedString(@"Profile.CantUpdate", nil));
    } timeout:10];
}

-(void)updateAccountPhoto:(NSString *)path completeHandler:(void (^)(TLUser *user))completeHandler progressHandler:(void (^)(float))progressHandler errorHandler:(void (^)(NSString *description))errorHandler {
    UploadOperation *operation = [[UploadOperation alloc] init];
    
    [operation setUploadComplete:^(UploadOperation *operation, id input) {
        
        [RPCRequest sendRequest:[TLAPI_photos_uploadProfilePhoto createWithFile:input caption:@"me" geo_point:[TL_inputGeoPointEmpty create] crop:[TL_inputPhotoCropAuto create]] successHandler:^(RPCRequest *request, id response) {
            
            [SharedManager proccessGlobalResponse:response];
            
            if(completeHandler)
                completeHandler(self.userSelf);
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            if(errorHandler)
                errorHandler(NSLocalizedString(@"Profile.Error.CantUpdatePhoto", nil));
        } timeout:10];
        
    }];
    
    [operation setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        [ASQueue dispatchOnMainQueue:^{
            if(progressHandler)
                progressHandler((float)current/(float)total * 100);
        }];
    }];
    
    [operation setUploadStarted:^(UploadOperation *operation, NSData *data) {
        
    }];
    
    [operation setFilePath:path];
    [operation ready:UploadImageType];
}

-(void)updateAccountPhotoByNSImage:(NSImage *)image completeHandler:(void (^)(TLUser *user))completeHandler progressHandler:(void (^)(float progress))progressHandler errorHandler:(void (^)(NSString *description))errorHandler {
    
    UploadOperation *operation = [[UploadOperation alloc] init];
    
    [operation setUploadComplete:^(UploadOperation *operation, id input) {
        
        [RPCRequest sendRequest:[TLAPI_photos_uploadProfilePhoto createWithFile:input caption:@"me" geo_point:[TL_inputGeoPointEmpty create] crop:[TL_inputPhotoCropAuto create]] successHandler:^(RPCRequest *request, id response) {
            
            
            [SharedManager proccessGlobalResponse:response];
            
            if(completeHandler)
                completeHandler(self.userSelf);
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            if(errorHandler)
                errorHandler(NSLocalizedString(@"Profile.Error.CantUpdatePhoto", nil));
        } timeout:10];
        
    }];
    
    [operation setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        [ASQueue dispatchOnMainQueue:^{
            if(progressHandler)
                progressHandler((float)current/(float)total * 100);
        }];
    }];
    
    [operation setUploadStarted:^(UploadOperation *operation, NSData *data) {
        
    }];
    
    [operation setFileData:compressImage([image TIFFRepresentation], 0.7)];
    [operation ready:UploadImageType];
}



+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}
@end

/*
 
 //                        ABAddressBook *book = [ABAddressBook sharedAddressBook];
 //                        if(book) {
 //                            NSArray *all = [[ABAddressBook sharedAddressBook] people];
 //
 //                            [all enumerateObjectsUsingBlock:^(ABPerson *person, NSUInteger idx, BOOL *stop) {
 //                                ABMutableMultiValue * phones = [person valueForKey:kABPhoneProperty];
 //
 //
 //
 //                                NSUInteger count = [phones count];
 //
 //                                BOOL savePerson = NO;
 //
 //                                 ABMutableMultiValue *ps = [[ABMutableMultiValue alloc] init];
 //
 //                                for (int i = 0; i < count; i++) {
 //
 //                                    NSString *phone = [phones valueAtIndex:i];
 //                                    phone = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
 //
 //                                    if([phone isEqualToString:currentUser.phone]) {
 //
 //                                        savePerson = YES;
 //
 //                                    }
 //
 //                                    [ps addValue:phone withLabel:[phones labelAtIndex:i]];
 //                                }
 //
 //                                if(savePerson) {
 //                                    [person setValue:newUser.first_name forProperty:kABFirstNameProperty];
 //                                    [person setValue:newUser.last_name forProperty:kABLastNameProperty];
 //
 //
 //                                    [ps addValue:newUser.phone withLabel:kABPhoneMobileLabel];
 //
 //                                    [person setValue:ps forKey:kABPhoneProperty];
 //
 //                                    [book save];
 //                                }
 //
 //
 //
 //                            }];
 //                        }
 
 
 */
