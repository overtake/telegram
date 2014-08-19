//
//  OnlineNotificationManager.m
//  Messenger for Telegram
//
//  Created by keepcoder on 28.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "OnlineNotificationManager.h"
#import "TGTimer.h"

@interface OnlineNotificationManager ()
@property (nonatomic,strong) NSMutableArray *users;
@property (nonatomic,strong) TGTimer *timer;
@end

@implementation OnlineNotificationManager

- (void)addUser:(TGUser *)user {
    if(user && [_users indexOfObject:user] == NSNotFound) {
        [_users addObject:user];
    }
    
    [self checkAndStart];
}

- (void)removeUser:(TGUser *)user {
    [_users removeObject:user];
    
    [self checkAndStart];
}

- (void)checkAndStart {
    
    if(_users.count > 0) {
        if(!_timer) {
            _timer = [[TGTimer alloc] initWithTimeout:60.0 repeat:YES completion:^{
                [self notify];
            } queue:[ASQueue globalQueue].nativeQueue];
            
            [_timer start];
        }
        
    } else {
        [_timer invalidate];
        _timer = nil;
    }
    
    
}

- (void)notify {
    for (TGUser *user in _users) {
        [Notification perform:USER_STATUS data:@{KEY_USER_ID: @(user.n_id)}];
    }
}

+ (void)addUser:(TGUser *)user {
    [ASQueue dispatchOnStageQueue:^{
        [[self instance] addUser:user];
    }];
    
}

+ (void)removeUser:(TGUser *)user {
    [ASQueue dispatchOnStageQueue:^{
       [[self instance] removeUser:user];
    }];
    
}

+ (id)instance {
    static OnlineNotificationManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] init];
        instance.users = [[NSMutableArray alloc] init];
    });
    return instance;
}

@end
