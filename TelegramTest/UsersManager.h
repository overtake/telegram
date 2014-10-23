//
//  UsersManager.h
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SharedManager.h"

@interface UsersManager : SharedManager

@property (nonatomic, strong, readonly) TGUser *userSelf;

+ (int)currentUserId;
+ (TGUser *)currentUser;

- (void)addFromDB:(NSArray *)array;

- (void)add:(NSArray *)all withCustomKey:(NSString *)key update:(BOOL)isNeedUpdateDB;

- (void)loadUsers:(NSArray *)users completeHandler:(void (^)())completeHandler;

- (void)updateAccount:(NSString *)firstName lastName:(NSString *)lastName completeHandler:(void (^)(TGUser *user))completeHandler errorHandler:(void (^)(NSString *description))errorHandler;
- (void)updateAccountPhoto:(NSString *)path completeHandler:(void (^)(TGUser *user))completeHandler progressHandler:(void (^)(float progress))progressHandler errorHandler:(void (^)(NSString *description))errorHandler;
- (void)updateAccountPhotoByNSImage:(NSImage *)image completeHandler:(void (^)(TGUser *user))completeHandler progressHandler:(void (^)(float progress))progressHandler errorHandler:(void (^)(NSString *description))errorHandler;

- (void)setUserStatus:(TGUserStatus *)status forUid:(int)uid;

-(void)updateUserName:(NSString *)userName completeHandler:(void (^)(TGUser *))completeHandler errorHandler:(void (^)(NSString *))errorHandler;

@end
