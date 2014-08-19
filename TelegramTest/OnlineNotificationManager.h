//
//  OnlineNotificationManager.h
//  Messenger for Telegram
//
//  Created by keepcoder on 28.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnlineNotificationManager : NSObject

+(void) addUser:(TGUser *)user;

+(void)removeUser:(TGUser *)user;

@end
