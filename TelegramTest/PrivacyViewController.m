//
//  PrivacyViewController.m
//  Telegram
//
//  Created by keepcoder on 19.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PrivacyViewController.h"
#import "GeneralSettingsRowItem.h"
#import "GeneralSettingsRowView.h"
#import "GeneralSettingsBlockHeaderView.h"
@interface PrivacyViewController () <TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;

@property (nonatomic,strong) GeneralSettingsRowItem *lastSeenRowItem;
@property (nonatomic,strong) GeneralSettingsRowItem *blockedUsersRowIten;
@property (nonatomic,strong) GeneralSettingsRowItem *accountDaysItem;

@property (nonatomic,assign) int accountDaysTTL;


@end

@implementation PrivacyViewController

-(void)loadView {
    [super loadView];
    
    [self setCenterBarViewText:NSLocalizedString(@"PrivacyAndSecurity.Header", nil)];
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    
    [self.view addSubview:self.tableView.containerView];
    
    
    GeneralSettingsBlockHeaderItem *privacyHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"PrivacyAndSecurity.PrivacyHeader", nil) height:51 flipped:NO];
    
    [self.tableView insert:privacyHeader atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    self.blockedUsersRowIten = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        [[Telegram rightViewController] showBlockedUsers];
        
    } description:NSLocalizedString(@"PrivacyAndSecurity.BlockedUsers", nil) subdesc:@"" height:42 stateback:nil];
    
    [self.tableView insert:self.blockedUsersRowIten atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    self.lastSeenRowItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        if(!self.lastSeenRowItem.locked)
            [[Telegram rightViewController] showLastSeenController];
        
    } description:NSLocalizedString(@"PrivacyAndSecurity.LastSeen", nil) subdesc:@"" height:42 stateback:nil];
    
    [self.tableView insert:self.lastSeenRowItem atIndex:self.tableView.list.count tableRedraw:NO];
    

    
    GeneralSettingsBlockHeaderItem *security = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"PrivacyAndSecurity.SecurityHeader", nil) height:51 flipped:NO];
    
    [self.tableView insert:security atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    GeneralSettingsRowItem *passcode = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        [[Telegram rightViewController] showPasscodeController];
        
    } description:NSLocalizedString(@"PrivacyAndSecurity.PassCode", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @(YES);
    }];
    
    [self.tableView insert:passcode atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    
    BOOL accept = YES;
    
#ifdef TGDEBUG
    
  //  accept = ACCEPT_FEATURE;
    
#endif
    
    
    if(accept) {
        
        GeneralSettingsRowItem *terminateSessions = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
            
            [[Telegram rightViewController] showSessionsController];
            
            //  [self terminateSessions];
            
        } description:NSLocalizedString(@"PrivacyAndSecurity.TerminateSessions", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
            return @(YES);
        }];
        
        [self.tableView insert:terminateSessions atIndex:self.tableView.list.count tableRedraw:NO];
        
        GeneralSettingsRowItem *twoStepVerification = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
            
            [[Telegram rightViewController] showPasswordMainController];
            
        } description:NSLocalizedString(@"PrivacyAndSecurity.TwoStepVerification", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
            return @(YES);
        }];
        
        [self.tableView insert:twoStepVerification atIndex:self.tableView.list.count tableRedraw:NO];
    }
    
    
    
    
//    
//    GeneralSettingsRowItem *logout = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
//        N
//        [self logOut];
//        
//        
//    } description:NSLocalizedString(@"PrivacyAndSecurity.Logout", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
//        return @([SettingsArchiver checkMaskedSetting:AutoGroupAudio]);
//    }];
//    
//    [self.tableView insert:logout atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    GeneralSettingsBlockHeaderItem *deleteAccountHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"PrivacyAndSecurity.DeleteAccountHeader", nil) height:51 flipped:NO];
    
    [self.tableView insert:deleteAccountHeader atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    self.accountDaysItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
       /// [self logOut];
        
        GeneralSettingsRowView *view = [self.tableView viewAtColumn:0 row:[self.tableView indexOfItem:self.accountDaysItem] makeIfNecessary:NO];
        
        if(view) {
            NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
            
            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"AccountDaysTTL30",nil) withBlock:^(id sender) {
                
                [self sendAccountDaysTTL:30];
                
            }]];
            
            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"AccountDaysTTL90",nil) withBlock:^(id sender) {
                [self sendAccountDaysTTL:90];
            }]];
            
            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"AccountDaysTTL182",nil) withBlock:^(id sender) {
                [self sendAccountDaysTTL:182];
            }]];
            
            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"AccountDaysTTL365",nil) withBlock:^(id sender) {
                [self sendAccountDaysTTL:365];
            }]];
            
            [menu popUpForView:view.subdescField];
        }
        
    } description:NSLocalizedString(@"PrivacyAndSecurity.DeleteAccount", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @([SettingsArchiver checkMaskedSetting:AutoGroupAudio]);
    }];
    
    [self.tableView insert:self.accountDaysItem atIndex:self.tableView.list.count tableRedraw:NO];
    
    self.accountDaysItem.locked = YES;
    
    [self.tableView reloadData];
    
    [self loadDeleteAccountTimer];
//    
//    
//    GeneralSettingsBlockHeaderItem *deleteAccountHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithObject:NSLocalizedString(@"PrivacyAndSecurity.DeleteAccountHeader", nil)];
//    
//    deleteAccountHeader.height = 61;
//    
//    [self.tableView insert:deleteAccountHeader atIndex:self.tableView.list.count tableRedraw:NO];
//    
//    
//    GeneralSettingsRowItem *deleteAccount = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
//        
//    } description:NSLocalizedString(@"PrivacyAndSecurity.DeleteAccount", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
//        return @([SettingsArchiver checkMaskedSetting:EmojiReplaces]);
//    }];
//    
//    [self.tableView insert:deleteAccount atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    [self.tableView reloadData];
    
}


-(void)sendAccountDaysTTL:(int)days {
    
    if(!self.accountDaysItem.locked) {
        self.accountDaysItem.locked = YES;
        
        [self.tableView reloadData];
        
        [RPCRequest sendRequest:[TLAPI_account_setAccountTTL createWithTtl:[TL_accountDaysTTL createWithDays:days]] successHandler:^(RPCRequest *request, id response) {
            
            
            self.accountDaysItem.locked = NO;
            
            if([response isKindOfClass:[TL_boolTrue class]]) {
                self.accountDaysTTL = days;
                [self updateAccountDaysTTL];
            } else {
                [self updateAccountDaysTTL];
            }
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            self.accountDaysItem.locked = NO;
            [self updateAccountDaysTTL];
        }];
    }
}

-(void)loadDeleteAccountTimer {
    [RPCRequest sendRequest:[TLAPI_account_getAccountTTL create] successHandler:^(RPCRequest *request, TL_accountDaysTTL *response) {
        
        self.accountDaysItem.locked = NO;
        
        self.accountDaysTTL = response.days;
        
         [self updateAccountDaysTTL];
       
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
    }];
}

-(void)updateAccountDaysTTL {
    
    NSString *key = [NSString stringWithFormat:@"AccountDaysTTL%d",self.accountDaysTTL];
    
    self.accountDaysItem.subdesc = NSLocalizedString(key, nil);
    
    [self.tableView reloadData];
}

- (void)terminateSessions {
    
    confirm(NSLocalizedString(@"Confirm", nil), NSLocalizedString(@"Confirm.TerminateSessions", nil), ^ {
        
        [self showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_auth_resetAuthorizations create] successHandler:^(RPCRequest *request, id response) {
            
            alert(NSLocalizedString(@"Success", nil), NSLocalizedString(@"Confirm.SuccessResetSessions", nil));
            
            [self hideModalProgress];
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
             [self hideModalProgress];
            
        } timeout:5];
    },nil);
    
    
}

- (void)logOut {
    confirm(NSLocalizedString(@"Confirm", nil),NSLocalizedString(@"Confirm.ConfirmLogout", nil), ^ {
        [[Telegram delegate] logoutWithForce:NO];
    },nil);
    
}

-(void)updatePrivacyDescription:(NSNotification *)notification {
    
    
    
    PrivacyArchiver *lsPrivacy = [PrivacyArchiver privacyForType:kStatusTimestamp];
    
    
    NSString * subdesc = @"";
    
    NSString *adc = @"";
    
    if(lsPrivacy.disallowUsers.count > 0) {
        adc = [adc stringByAppendingFormat:@" (-%lu",lsPrivacy.disallowUsers.count];
    }
    
    if(lsPrivacy.allowUsers.count > 0) {
        adc = [adc stringByAppendingFormat:@"%@+%lu",adc.length > 0 ? @", " : @" (", lsPrivacy.allowUsers.count];
    }
    
    if(adc.length > 0)
        adc = [adc stringByAppendingString:@")"];
    
    switch (lsPrivacy.allowType) {
        case PrivacyAllowTypeContacts:
            
            subdesc = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"PrivacySettingsController.MyContacts", nil),adc];
            break;
        case PrivacyAllowTypeEverbody:
            subdesc = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"PrivacySettingsController.Everbody", nil),adc];
            break;
        case PrivacyAllowTypeNobody:
            subdesc = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"PrivacySettingsController.Nobody", nil),adc];
            break;
            
        default:
            break;
    }
    
    self.lastSeenRowItem.subdesc = subdesc;

    [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self updatePrivacyDescription:nil];
    
    [Notification addObserver:self selector:@selector(updatePrivacyDescription:) name:PRIVACY_UPDATE];
    
    
    
    if([PrivacyArchiver privacyForType:kStatusTimestamp] == nil && !self.lastSeenRowItem.locked) {
        
        [self.lastSeenRowItem setLocked:YES];
        
        [self.tableView reloadData];
        
        [RPCRequest sendRequest:[TLAPI_account_getPrivacy createWithN_key:[TL_inputPrivacyKeyStatusTimestamp create]] successHandler:^(RPCRequest *request, TL_account_privacyRules *response) {
            
            [SharedManager proccessGlobalResponse:response];
            
            PrivacyArchiver *privacy = [PrivacyArchiver privacyFromRules:[response rules] forKey:kStatusTimestamp];
            
            [privacy _save];
            
            [self.lastSeenRowItem setLocked:NO];
            [self.tableView reloadData];
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
        }];
        
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Notification removeObserver:self];
}


- (CGFloat)rowHeight:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return  item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[GeneralSettingsBlockHeaderItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsBlockHeaderView class] identifier:@"GeneralSettingsBlockHeaderView"];
    }
    
    if([item isKindOfClass:[GeneralSettingsRowItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsRowView class] identifier:@"GeneralSettingsRowViewClass"];
    }
    
    return nil;
    
}

- (void)selectionDidChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}


@end
