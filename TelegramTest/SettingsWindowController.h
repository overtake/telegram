//
//  SettingsWindowController.h
//  Messenger for Telegram
//
//  Created by keepcoder on 25.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface SettingsWindowController : NSWindowController


typedef enum {
    SettingsWindowActionChatSettings,
    SettingsWindowActionSecuritySettings,
    SettingsWindowActionBlockedUsers
} SettingsWindowAction;

@property (nonatomic,assign) SettingsWindowAction action;

-(void)showWindowWithAction:(SettingsWindowAction)action;

@end
