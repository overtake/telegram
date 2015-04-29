//
//  UsersManager.h
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SharedManager.h"

@interface UsersManager : SharedManager

@property (nonatomic, strong, readonly) TLUser *userSelf;

+ (int)currentUserId;
+ (TLUser *)currentUser;

+(TLUser *)findUserByName:(NSString *)userName;
+(NSArray *)findUsersByName:(NSString *)userName;
+(NSArray *)findUsersByMention:(NSString *)userName withUids:(NSArray *)uids;

- (void)addFromDB:(NSArray *)array;

- (void)add:(NSArray *)all withCustomKey:(NSString *)key update:(BOOL)isNeedUpdateDB;

- (void)loadUsers:(NSArray *)users completeHandler:(void (^)())completeHandler;

- (void)updateAccount:(NSString *)firstName lastName:(NSString *)lastName completeHandler:(void (^)(TLUser *user))completeHandler errorHandler:(void (^)(NSString *description))errorHandler;
- (void)updateAccountPhoto:(NSString *)path completeHandler:(void (^)(TLUser *user))completeHandler progressHandler:(void (^)(float progress))progressHandler errorHandler:(void (^)(NSString *description))errorHandler;
- (void)updateAccountPhotoByNSImage:(NSImage *)image completeHandler:(void (^)(TLUser *user))completeHandler progressHandler:(void (^)(float progress))progressHandler errorHandler:(void (^)(NSString *description))errorHandler;

- (void)setUserStatus:(TLUserStatus *)status forUid:(int)uid;

-(void)updateUserName:(NSString *)userName completeHandler:(void (^)(TLUser *))completeHandler errorHandler:(void (^)(NSString *))errorHandler;

@end
