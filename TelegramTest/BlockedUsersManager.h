//
//  BlockedUsersManager.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SharedManager.h"

@interface BlockedUsersManager : SharedManager

typedef void (^BlockedHandler)(BOOL response);

+ (id)sharedManager;
- (void)remoteLoad;

- (void)block:(int)user_id completeHandler:(BlockedHandler)block;
- (void)unblock:(int)user_id completeHandler:(BlockedHandler)block;
- (void)block:(BOOL)isBlock user_id:(int)user_id completeHandler:(BlockedHandler)block;
-(void)updateBlocked:(int)user_id isBlocked:(BOOL)isBlocked;

- (BOOL)isBlocked:(int)user_id;
@end
