//
//  Telegram.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/28/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "Telegram.h"
#import "DialogsManager.h"
#import "TGTimer.h"

#define ONLINE_EXPIRE 55
#define OFFLINE_AFTER 40

@interface Telegram()

@property (nonatomic, strong) TGTimer *accountStatusTimer;
@property (nonatomic, strong) TGTimer *accountOfflineStatusTimer;
@property (nonatomic, strong) RPCRequest *onlineRequest;

@end

@implementation Telegram

+ (Telegram *)sharedInstance {
    return [self delegate].telegram;
}

+ (AppDelegate *)delegate {
    return ((AppDelegate *)[NSApplication sharedApplication].delegate);
}

Telegram *TelegramInstance() {
    return [Telegram sharedInstance];
}

//- (void) setDialog:(TL_conversation *)dialog {
//    self->_dialog = dialog;
////    [Notification perform:@"CHANGE_DIALOG" object:self.dialog];
//}

+ (MainViewController *)mainViewController {
    return (MainViewController *)[self delegate].mainWindow.rootViewController;
}

+ (RightViewController *)rightViewController {
    return [[self mainViewController] rightViewController];
}

+ (LeftViewController *)leftViewController {
    return [[self mainViewController] leftViewController];
}

+ (SettingsWindowController *)settingsWindowController {
    return [[self mainViewController] settingsWindowController];
}

- (id)init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [Notification addObserver:self selector:@selector(protocolUpdated:) name:PROTOCOL_UPDATED];
    if([[MTNetwork instance] isAuth])
        [self protocolUpdated:nil];
}

- (void)dealloc {
    [Notification removeObserver:self];
}


- (void)protocolUpdated:(NSNotification *)notify {
    [self.accountStatusTimer invalidate];
    self.accountStatusTimer = nil;
    self.accountStatusTimer = [[TGTimer alloc] initWithTimeout:ONLINE_EXPIRE - 5 repeat:YES completion:^{
        _isOnline = NO;
        [self setAccountOnline];
    } queue:[ASQueue globalQueue].nativeQueue];
    [self.accountStatusTimer start];
}

- (BOOL)canBeOnline {
    return self.isWindowActive || [SettingsArchiver checkMaskedSetting:OnlineForever];
}

- (void)setAccountOffline:(BOOL)force {
    if([SettingsArchiver checkMaskedSetting:OnlineForever])
        return;
    
    if(force) {
        [self.accountOfflineStatusTimer invalidate];
        self.accountOfflineStatusTimer = nil;
        
        [self.onlineRequest cancelRequest];
        self.onlineRequest = [RPCRequest sendRequest:[TLAPI_account_updateStatus createWithOffline:YES] successHandler:^(RPCRequest *request, id response) {
            _isOnline = NO;
            DLog(@"account is offline success");
        } errorHandler:nil];
    } else {
        if(!self.accountOfflineStatusTimer) {
            self.accountOfflineStatusTimer = [[TGTimer alloc] initWithTimeout:OFFLINE_AFTER repeat:NO completion:^{
                [self setAccountOffline:YES];
            } queue:[ASQueue globalQueue].nativeQueue];
            [self.accountOfflineStatusTimer start];
        }
    }
}

- (void)setIsOnline:(BOOL)isOnline {
    self->_isOnline = isOnline;
    [Notification perform:USER_ONLINE_CHANGED data:nil];
}

- (void)setAccountOnline {
    
    if(![self canBeOnline]) {
        self.isOnline = NO;
        return;
    }
    
    [self.accountOfflineStatusTimer invalidate];
    self.accountOfflineStatusTimer = nil;
    
    if(self.isOnline)
        return;
    
    
    if([[MTNetwork instance] isAuth]) {
        [[UsersManager sharedManager] setUserStatus:[TL_userStatusOnline createWithExpires:[[MTNetwork instance] getTime] + ONLINE_EXPIRE] forUid:UsersManager.currentUserId];
        
        [self.onlineRequest cancelRequest];
        self.onlineRequest = [RPCRequest sendRequest:[TLAPI_account_updateStatus createWithOffline:NO] successHandler:^(RPCRequest *request, id response) {
            self.isOnline = YES;
            
            DLog(@"account is online");
        } errorHandler:nil];
    }
}

- (void)makeFirstController:(TMViewController *)controller {
    [self.firstController setViewController:controller];
}

-(void)notificationDialogUpdate:(NSNotification *)notify {
    TL_conversation *d = [notify.userInfo objectForKey:KEY_DIALOG];
    [self showMessagesFromDialog:d sender:self];
}

- (void)showMessagesFromDialog:(TL_conversation *)d sender:(id)sender {
    [[Telegram rightViewController] showByDialog:d sender:(id)sender];
}

- (void)showMessagesWidthUser:(TGUser *)user sender:(id)sender {
    if(user == nil)
        return ELog(@"User nil");
    TL_conversation *dn = [[DialogsManager sharedManager] findByUserId:user.n_id];
    if(!dn) {
        dn = [[DialogsManager sharedManager] createDialogForUser:user];
    }
    
    
    [self showMessagesFromDialog:dn sender:sender];
}

- (void)showUserInfoWithUserId:(int)userID conversation:(TL_conversation *)conversation sender:(id)sender {
    TGUser  *user = [[UsersManager sharedManager] find:userID];
    [self showUserInfoWithUser:user conversation:conversation sender:sender];
}

- (void)showNotSelectedDialog {
    
//    [self.mainViewController.leftViewController.dialogsViewController.table selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
//    [self.mainViewController.leftViewController.contactsViewController.table selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    
//    [self.mainViewController.leftViewController.dialogsViewController tableViewSetSelectionDialog:nil];
//    [self.mainViewController.leftViewController.contactsViewController setSelelected:-1];
    
    [[Telegram rightViewController] showNotSelectedDialog];
}


- (void)showUserInfoWithUser:(TGUser *)user conversation:(TL_conversation *)conversation sender:(id)sender {
    if(user == nil)
        return ELog(@"User nil");
    
    [[Telegram rightViewController] showUserInfoPage:user conversation:conversation];
    [[[Telegram mainViewController].view window] makeFirstResponder:nil];
}

- (void)onAuthSuccess {
    [[MTNetwork instance] successAuthForDatacenter:[[MTNetwork instance] currentDatacenter]];
    [[Telegram delegate] initializeMainWindow];
    [[MTNetwork instance].updateService update];
}

- (void)onLogoutSuccess {
//    [[Telegram delegate] initializeMainWindow];
}

BOOL isTestServer() {
    BOOL result = [[NSProcessInfo processInfo].environment[@"test_server"] boolValue];
    return result;
}

NSString * appName() {
    return isTestServer() ? @"telegram-test-server" : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

+ (void)drop {
    [[[Telegram rightViewController] messagesViewController] drop];
}

- (void)hideModalView:(BOOL)isHide animation:(BOOL)animated {
    [[Telegram rightViewController] hideModalView:isHide animation:animated];
}

- (void)navigationGoBack {
    [[Telegram rightViewController] navigationGoBack];
}

- (BOOL)isModalViewActive {
    return [[Telegram rightViewController] isModalViewActive];
}
@end
