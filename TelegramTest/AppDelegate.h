//
//  AppDelegate.h
//  TelegramTest
//
//  Created by keepcoder on 07.09.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TGInitializer.h"
#import "NSContactsPopover.h"
#import <HockeySDK/HockeySDK.h>
#import "TelegramWindow.h"
#import "LoginWindow.h"
#import "MainWindow.h"

@class Telegram;

@protocol NSUserNotificationCenterDelegate <NSObject>
@end


@interface AppDelegate : NSObject <NSApplicationDelegate, NSApplicationDelegate,NSWindowDelegate, NSUserNotificationCenterDelegate, BITHockeyManagerDelegate>



@property (nonatomic, strong) IBOutlet  Telegram *telegram;
@property (nonatomic, strong) MainWindow *mainWindow;
@property (nonatomic, strong) LoginWindow *loginWindow;

- (TelegramWindow *)window;
- (void)logoutWithForce:(BOOL)force;

- (void)setConnectionStatus:(NSString *)status;
- (void)initializeMainWindow;


@end
