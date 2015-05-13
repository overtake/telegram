//
//  Telegram.h
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/28/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import "TelegramFirstController.h"
#import "AppDelegate.h"
#import "SettingsWindowController.h"
#import "ASQueue.h"
#import "ConnectionStatusViewControllerView.h"
#import "TGEnterPasswordPanel.h"
@interface Telegram : NSObjectController

+ (Telegram *)sharedInstance;

+(TL_conversation *)conversation;

Telegram * TelegramInstance();


BOOL isTestServer();
NSString* appName();

@property (nonatomic, strong) IBOutlet TelegramFirstController *firstController;

+ (RightViewController *)rightViewController;
+ (LeftViewController *)leftViewController;
+ (MainViewController *)mainViewController;
+ (SettingsWindowController *)settingsWindowController;
+ (AppDelegate *)delegate;


+ (void)setConnectionState:(ConnectingStatusType)state;


- (void)makeFirstController:(TMViewController *)controller;

- (void)onAuthSuccess;
- (void)onLogoutSuccess;
+ (void)drop;

void setMaxChatUsers(int max_chat_users);
void setMaxBroadcastUsers(int max_broadcast_users);

int maxBroadcastUsers();
int maxChatUsers();

@property (nonatomic) BOOL isWindowActive;
@property (nonatomic, assign) BOOL isOnline;

- (void)setAccountOnline;
- (void)setAccountOffline:(BOOL)force;


- (void)showMessagesFromDialog:(TLDialog *)dialog sender:(id)sender;
- (void)showUserInfoWithUserId:(int)userID conversation:(TL_conversation *)conversaion sender:(id)sender;
- (void)showMessagesWidthUser:(TLUser *)user sender:(id)sender;
- (void)showNotSelectedDialog;


+(void)showEnterPasswordPanel;

+(BOOL)isSingleLayout;

+(TGEnterPasswordPanel *)enterPasswordPanel;

+(void)initializeDatabase;


+(void)saveHashTags:(NSString *)message peer_id:(int)peer_id;

@end
