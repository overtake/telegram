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
#import "TGOpacityViewController.h"
#import "TGPasscodeSettingsViewController.h"
#import "TGSessionsViewController.h"
#import "TGPasswosdMainViewController.h"
#import "TGPasswordSetViewController.h"
#import "TGPasswordEmailViewController.h"
#import "ChatExportLinkViewController.h"
#import "TGStickersSettingsViewController.h"
#import "ComposeChooseGroupViewController.h"
#import "TGSplitViewController.h"
#import "CacheSettingsViewController.h"
#import "NotificationSettingsViewController.h"
#import "ComposeCreateChannelViewController.h"
#import "ChannelInfoViewController.h"
#import "ComposeCreateChannelUserNameStepViewController.h"
@class MainViewController;
@class LeftViewController;

@interface RightViewController : TGSplitViewController


@property (nonatomic,strong) MainViewController *mainViewController;
@property (nonatomic,strong) LeftViewController *leftViewController;


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
@property (nonatomic, strong) TGOpacityViewController *opacityViewController;
@property (nonatomic, strong) TGPasscodeSettingsViewController *passcodeViewController;

@property (nonatomic, strong) TGSessionsViewController *sessionsViewContoller;
@property (nonatomic, strong) TGPasswosdMainViewController *passwordMainViewController;
@property (nonatomic, strong) TGPasswordSetViewController *passwordSetViewController;


@property (nonatomic, strong) ChatExportLinkViewController *chatExportLinkViewController;
@property (nonatomic, strong) TGStickersSettingsViewController *stickersSettingsViewController;

@property (nonatomic, strong) ComposeChooseGroupViewController *composeChooseGroupViewController;

@property (nonatomic, strong) CacheSettingsViewController *cacheSettingsViewController;
@property (nonatomic, strong) NotificationSettingsViewController *notificationSettingsViewController;
@property (nonatomic, strong) ComposeCreateChannelViewController *composeCreateChannelViewController;
@property (nonatomic, strong) ChannelInfoViewController *channelInfoViewController;
@property (nonatomic, strong) ComposeCreateChannelUserNameStepViewController *composeCreateChannelUserNameStepViewController;



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
- (void)showComposeAddUserToGroup:(ComposeAction *)composeAction;
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
- (void)showUserNameControllerWithChannel:(TL_channel *)channel completionHandler:(dispatch_block_t)completionHandler;


- (void)showAddContactController;
- (void)showPrivacyController;
- (void)showLastSeenController;

-(void)showPrivacyUserListController:(PrivacyArchiver *)privacy arrayKey:(NSString *)arrayKey addCallback:(dispatch_block_t)addCallback title:(NSString *)title;
- (void)showPhoneChangeAlerController;
- (void)showPhoneChangeController;
- (void)showPhoneChangeConfirmController:(id)params phone:(NSString *)phone;

- (void)showAboveController:(TMViewController *)lastController;

-(void)showPasscodeController;

-(void)addFirstControllerAfterLoadMainController:(TMViewController *)viewController;
-(TMViewController *)currentEmptyController;

-(void)showSessionsController;
-(void)showPasswordMainController;
-(void)showSetPasswordWithAction:(TGSetPasswordAction *)action;
-(void)showEmailPasswordWithAction:(TGSetPasswordAction *)action;

-(void)clearStack;
-(void)didChangedLayout;

-(void)showChatExportLinkController:(TLChatFull *)chat;
-(void)showStickerSettingsController;

-(void)showCacheSettingsViewController;
-(void)showNotificationSettingsViewController;

-(void)showComposeCreateChannel:(ComposeAction *)action;

-(void)showChannelInfoPage:(TLChat *)chat;

@end
