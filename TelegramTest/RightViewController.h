//
//  RightViewController.h
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessagesViewController.h"
#import "UserInfoViewController.h"
#import "ChatInfoViewController.h"
#import "TMCollectionPageController.h"
#import "HistoryFilter.h"
#import "BroadcastInfoViewController.h"
#import "ComposeAction.h"
#import "ComposePickerViewController.h"
#import "ComposeChatCreateViewController.h"
#import "ComposeBroadcastListViewController.h"
#import "EncryptedKeyViewController.h"
#import "BlockedUsersViewController.h"
#import "GeneralSettingsViewController.h"
#import "SettingsSecurityViewController.h"
#import "AboutViewController.h"
#import "UserNameViewController.h"
#import "AddContactViewController.h"
#import "PrivacyViewController.h"
#import "PrivacySettingsViewController.h"
#import "PrivacyUserListController.h"
#import "PhoneChangeAlertController.h"
#import "PhoneChangeController.h"
#import "PhoneChangeConfirmController.h"
@interface RightViewController : TMViewController

@property (nonatomic, strong) MessagesViewController *messagesViewController;
@property (nonatomic, strong) UserInfoViewController *userInfoViewController;
@property (nonatomic, strong) ChatInfoViewController *chatInfoViewController;
@property (nonatomic, strong) BroadcastInfoViewController *broadcastInfoViewController;
@property (nonatomic, strong) TMCollectionPageController *collectionViewController;
@property (nonatomic, strong) ComposePickerViewController *composePickerViewController;
@property (nonatomic, strong) ComposeChatCreateViewController *composeChatCreateViewController;
@property (nonatomic, strong) ComposeBroadcastListViewController *composeBroadcastListViewController;
@property (nonatomic, strong) EncryptedKeyViewController *encryptedKeyViewController;
@property (nonatomic, strong) BlockedUsersViewController *blockedUsersViewController;
@property (nonatomic, strong) GeneralSettingsViewController *generalSettingsViewController;
@property (nonatomic, strong) SettingsSecurityViewController *settingsSecurityViewController;
@property (nonatomic, strong) AboutViewController *aboutViewController;
@property (nonatomic, strong) UserNameViewController *userNameViewController;
@property (nonatomic, strong) AddContactViewController *addContactViewController;
@property (nonatomic, strong) PrivacyViewController *privacyViewController;
@property (nonatomic, strong) PrivacySettingsViewController *lastSeenViewController;
@property (nonatomic, strong) PrivacyUserListController *privacyUserListController;
@property (nonatomic, strong) PhoneChangeAlertController *phoneChangeAlertController;
@property (nonatomic, strong) PhoneChangeController *phoneChangeController;
@property (nonatomic, strong) PhoneChangeConfirmController *phoneChangeConfirmController;

- (void)modalViewSendAction:(id)object;
- (BOOL)isModalViewActive;
- (BOOL)isActiveDialog;
- (void)navigationGoBack;
- (void)hideModalView:(BOOL)isHide animation:(BOOL)animated;

- (void)showShareContactModalView:(TLUser *)user;
- (void)showForwardMessagesModalView:(TL_conversation *)dialog messagesCount:(NSUInteger)messagesCount;

- (void)showByDialog:(TL_conversation *)dialog sender:(id)sender;

- (BOOL)showByDialog:(TL_conversation *)dialog withJump:(int)messageId historyFilter:(Class)filter sender:(id)sender;

- (void)showComposeWithAction:(ComposeAction *)composeAction;
- (void)showComposeCreateChat:(ComposeAction *)composeAction;
- (void)showComposeBroadcastList:(ComposeAction *)composeAction;
- (void)showUserInfoPage:(TLUser *)user conversation:(TL_conversation *)conversation;
- (void)showUserInfoPage:(TLUser *)user;
- (void)showCollectionPage:(TL_conversation *)conversation;
- (void)showChatInfoPage:(TLChat *)chat;
- (void)showBroadcastInfoPage:(TL_broadcast *)broadcast;
- (void)showNotSelectedDialog;

-(void)showEncryptedKeyWindow:(TL_encryptedChat *)chat;

- (void)showBlockedUsers;
- (void)showGeneralSettings;
- (void)showSecuritySettings;
- (void)showAbout;
- (void)showUserNameController;

- (void)showAddContactController;
- (void)showPrivacyController;
- (void)showLastSeenController;

-(void)showPrivacyUserListController:(PrivacyArchiver *)privacy arrayKey:(NSString *)arrayKey addCallback:(dispatch_block_t)addCallback title:(NSString *)title;
- (void)showPhoneChangeAlerController;
- (void)showPhoneChangeController;
- (void)showPhoneChangeConfirmController:(id)params phone:(NSString *)phone;

- (void)showAboveController:(TMViewController *)lastController;

@end
