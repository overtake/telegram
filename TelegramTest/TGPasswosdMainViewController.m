//
//  TGPasswosdMainViewController.m
//  Telegram
//
//  Created by keepcoder on 27.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGPasswosdMainViewController.h"
#import "GeneralSettingsRowView.h"
#import "GeneralSettingsBlockHeaderView.h"
#import "GeneralSettingsRowItem.h"
#import "TGSetPasswordAction.h"
#import "NSMutableData+Extension.h"
#import <MtProtoKit/MTEncryption.h>
#import "TGTimer.h"
@interface TGPasswosdMainViewController ()<TMTableViewDelegate>

@property (nonatomic,strong) NSProgressIndicator *progressIndicator;

@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) id passwordResult;
@property (nonatomic,strong) TGTimer *updateTimer;
@end

@implementation TGPasswosdMainViewController





-(void)loadView {
    [super loadView];
    
    
    [self setCenterBarViewText:NSLocalizedString(@"PrivacyAndSecurity.TwoStepVerification", nil)];
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    
    self.progressIndicator = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 35, 35)];
    
    [self.progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
    
    
    [self.view addSubview:self.progressIndicator];
    
    [self.progressIndicator setCenterByView:self.view];
    
    
    [self.view addSubview:self.tableView.containerView];
    
}


-(void)rebuildController {
    
    
    [self.tableView removeAllItems:NO];
    
    TL_account_password *pwd = _passwordResult;
    
    
    if([self.passwordResult email_unconfirmed_pattern].length == 0) {
        if([self.passwordResult isKindOfClass:[TL_account_noPassword class]]) {
            GeneralSettingsRowItem *turnPassword = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
                
                TGSetPasswordAction *firstAction = [[TGSetPasswordAction alloc] init];
                
                firstAction.title = NSLocalizedString(@"PasswordSettings.SetPassword", nil);
                firstAction.header = NSLocalizedString(@"PasswordSettings.YourPassword", nil);
                firstAction.callback = ^BOOL (NSString *fp) {
                    
                    if(fp.length > 0) {
                        TGSetPasswordAction *confirmAction = [[TGSetPasswordAction alloc] init];
                        
                        confirmAction.title = NSLocalizedString(@"PasswordSettings.ConfirmPassword", nil);
                        confirmAction.header = NSLocalizedString(@"PasswordSettings.YourPassword", nil);
                        confirmAction.callback = ^BOOL (NSString *sp) {
                            
                            
                            if([sp isEqualToString:fp]) {
                                
                                TGSetPasswordAction *hintAction = [[TGSetPasswordAction alloc] init];
                                
                               
                                
                                hintAction.title = NSLocalizedString(@"PasswordSettings.SetupHint", nil);
                                hintAction.header =  NSLocalizedString(@"PasswordSettings.SetupHintTitle", nil);
                                
                                
                                hintAction.callback = ^BOOL (NSString *hint) {
                                    
                                    TGSetPasswordAction *emailAction = [[TGSetPasswordAction alloc] init];
                                    
                                    emailAction.title = NSLocalizedString(@"PasswordSettings.RecoveryEmail", nil);
                                    emailAction.desc =  NSLocalizedString(@"PasswordSettings.RecoveryEmailDesc", nil);
                                    
                                    emailAction.hasButton = YES;
                                    
                                    
                                    __weak TGSetPasswordAction *wEAction = emailAction;
                                    
                                    emailAction.callback = ^BOOL (NSString *email) {
                                        
                                        if(!email || NSStringIsValidEmail(email)) {
                                            [self setPassword:fp current_pswd_hash:[[NSData alloc] init] email:email hint:hint flags:1 | (NSStringIsValidEmail(email) ? 2 : 0) successCallback:^{
                                                
                                                if(NSStringIsValidEmail(email)) {
                                                    alert(nil, NSLocalizedString(@"PasswordSettings.AlertConfirmEmailDescription", nil));
                                                } else {
                                                    alert(nil, NSLocalizedString(@"PasswordSettings.AlertSuccessActivatedDescription", nil));
                                                }
                                                
                                                
                                                
                                            } errorCallback:^{
                                                [wEAction.controller performSelector:@selector(performShake) withObject:nil];
                                            }];

                                        }
                                        
                                        
                                        return !email || NSStringIsValidEmail(email);
                                    };
                                    
                                    [[Telegram rightViewController] showEmailPasswordWithAction:emailAction];
                                    
                                    
                                    return YES;
                                    
                                };
                                
                                [[Telegram rightViewController] showEmailPasswordWithAction:hintAction];
                            }
                            
                            return [sp isEqualToString:fp];
                        };
                        
                        [[Telegram rightViewController] showSetPasswordWithAction:confirmAction];
                        
                        return YES;
                    }
                    
                    return NO;
                    
                    
                };
                
                [[Telegram rightViewController] showSetPasswordWithAction:firstAction];
                
                
            } description:NSLocalizedString(@"PasswordSettings.TurnOnPassword", nil) height:82 stateback:^id(TGGeneralRowItem *item) {
                return @(NO);
            }];
            
            [self.tableView insert:turnPassword atIndex:self.tableView.list.count tableRedraw:NO];
            
            GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"PasswordSettings.AdditionDescription", nil) height:60 flipped:NO];
            
            
            [self.tableView insert:description atIndex:self.tableView.count tableRedraw:NO];

            
            
        } else {
            
            
            
            
            GeneralSettingsRowItem *changePassword = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
                
                
                TGSetPasswordAction *sAction = [[TGSetPasswordAction alloc] init];
                
                sAction.title = NSLocalizedString(@"PasswordSettings.InputPassword", nil);
                sAction.header =  NSLocalizedString(@"PasswordSettings.YourPassword", nil);
                __weak TGSetPasswordAction *asWeak = sAction;
                
                sAction.callback = ^BOOL (NSString *password) {
                    
                    
                    NSData *phash = passwordHash(password,[pwd current_salt]);
                    
                    [self showModalProgress];
                    
                    [RPCRequest sendRequest:[TLAPI_account_getPasswordSettings createWithCurrent_password_hash:phash] successHandler:^(RPCRequest *request, TL_account_passwordSettings *response) {
                        
                        
                        if([response isKindOfClass:[TL_account_passwordSettings class]]) {
                            
                            TGSetPasswordAction *firstAction = [[TGSetPasswordAction alloc] init];
                            
                            firstAction.title = NSLocalizedString(@"PasswordSettings.InputNewPassword", nil);
                            firstAction.header =  NSLocalizedString(@"PasswordSettings.YourPassword", nil);
                            firstAction.callback = ^BOOL (NSString *fp) {
                                
                                if(fp.length > 0) {
                                    TGSetPasswordAction *confirmAction = [[TGSetPasswordAction alloc] init];
                                    
                                    confirmAction.title = NSLocalizedString(@"PasswordSettings.ConfirmPassword", nil);
                                    confirmAction.header =  NSLocalizedString(@"PasswordSettings.YourPassword", nil);
                                    confirmAction.callback = ^BOOL (NSString *sp) {
                                        
                                        
                                        if([sp isEqualToString:fp]) {
                                            
                                            [self setPassword:fp current_pswd_hash:phash email:[response email] hint:[pwd hint] flags:3 successCallback:^{
                                                alert(nil, NSLocalizedString(@"PasswordSettings.AlertSuccessChangedDescription", nil));
                                            } errorCallback:nil];
                                        }
                                        
                                        return [sp isEqualToString:fp];
                                    };
                                    
                                    [[Telegram rightViewController] showSetPasswordWithAction:confirmAction];
                                    
                                    return YES;
                                }
                                
                                return NO;
                                
                                
                            };
                            [[Telegram rightViewController].navigationViewController.viewControllerStack removeLastObject];
                            [[Telegram rightViewController] showSetPasswordWithAction:firstAction];
                            
                            
                        }
                        
                        [self hideModalProgressWithSuccess];
                        
                        
                        
                    } errorHandler:^(RPCRequest *request, RpcError *error) {
                        [self hideModalProgress];
                        
                        [asWeak.controller performSelector:@selector(performShake) withObject:nil];
                        
                    } timeout:10];
                    
                    
                    
                    return YES;
                };
                
                [[Telegram rightViewController] showSetPasswordWithAction:sAction];
                
                
            } description: NSLocalizedString(@"PasswordSettings.ChangePassword", nil) height:82 stateback:^id(TGGeneralRowItem *item) {
                return @(NO);
            }];
            
            [self.tableView insert:changePassword atIndex:self.tableView.list.count tableRedraw:NO];
            
            
            
            GeneralSettingsRowItem *turnPassword = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
                
                
                TGSetPasswordAction *sAction = [[TGSetPasswordAction alloc] init];
                
                sAction.title = NSLocalizedString(@"PasswordSettings.InputPassword", nil);
                
                __weak TGSetPasswordAction *asWeak = sAction;
                
                sAction.callback = ^BOOL (NSString *password) {
                    
                    
                    NSData *phash = passwordHash(password,[pwd current_salt]);
                    
                    [self showModalProgress];
                    
                    [RPCRequest sendRequest:[TLAPI_account_getPasswordSettings createWithCurrent_password_hash:phash] successHandler:^(RPCRequest *request, TL_account_passwordSettings *response) {
                        
                        
                        if([response isKindOfClass:[TL_account_passwordSettings class]]) {
                            
                            [self setPassword:@"" current_pswd_hash:phash email:[response email] hint:[pwd hint] flags:1 successCallback:^{
                                
                                alert(nil, NSLocalizedString(@"PasswordSettings.AlertSuccessDeactivatedDescription", nil));
                                
                            } errorCallback:^{
                                [asWeak.controller performSelector:@selector(performShake) withObject:nil];
                            }];
                            
                        }
                        
                        
                        
                    } errorHandler:^(RPCRequest *request, RpcError *error) {
                        [self hideModalProgress];
                        
                        [asWeak.controller performSelector:@selector(performShake) withObject:nil];
                        
                    } timeout:10];
                    
                    
                    
                    return YES;
                };
                
                [[Telegram rightViewController] showSetPasswordWithAction:sAction];
                
                
                
            } description: NSLocalizedString(@"PasswordSettings.TurnOffPassword", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
                return @(NO);
            }];
            
            [self.tableView insert:turnPassword atIndex:self.tableView.list.count tableRedraw:NO];
            
            GeneralSettingsRowItem *recoveryEmail = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
                
                
                TGSetPasswordAction *sAction = [[TGSetPasswordAction alloc] init];
                
                sAction.title = NSLocalizedString(@"PasswordSettings.InputPassword", nil);
                
                __weak TGSetPasswordAction *asWeak = sAction;
                
                sAction.callback = ^BOOL (NSString *password) {
                    
                    
                    NSData *phash = passwordHash(password,[pwd current_salt]);
                    
                    [self showModalProgress];
                    
                    [RPCRequest sendRequest:[TLAPI_account_getPasswordSettings createWithCurrent_password_hash:phash] successHandler:^(RPCRequest *request, TL_account_passwordSettings *response) {
                        
                        
                        if([response isKindOfClass:[TL_account_passwordSettings class]]) {
                            
                            
                            
                            TGSetPasswordAction *emailAction = [[TGSetPasswordAction alloc] init];
                            
                            if(pwd.has_recovery) {
                                emailAction.title = NSLocalizedString(@"PasswordSettings.ChangeRecoveryEmail", nil);
                                emailAction.desc =  NSLocalizedString(@"PasswordSettings.RecoveryEmailDesc", nil);
                            } else {
                                emailAction.title = NSLocalizedString(@"PasswordSettings.RecoveryEmail", nil);
                                emailAction.desc =  NSLocalizedString(@"PasswordSettings.RecoveryEmailDesc", nil);
                            }
                            
                            
                            emailAction.defaultValue = [response email];
                            
                            __weak TGSetPasswordAction *wEAction;
                            
                            emailAction.callback = ^BOOL (NSString *email) {
                                
                                if(NSStringIsValidEmail(email)) {
                                    [self setPassword:password current_pswd_hash:phash email:email hint:pwd.hint flags:2 successCallback:^{
                                        
                                        alert(NSLocalizedString(@"PasswordSettings.AlertConfirmEmail", nil), NSLocalizedString(@"PasswordSettings.AlertConfirmEmailDescription", nil));
                                        
                                    } errorCallback:^{
                                        [wEAction.controller performSelector:@selector(performShake) withObject:nil];
                                    }];
                                }
                                
                                return !email || NSStringIsValidEmail(email);
                            };
                            
                            [[Telegram rightViewController].navigationViewController.viewControllerStack removeLastObject];
                            [[Telegram rightViewController] showEmailPasswordWithAction:emailAction];
                            
                        }
                        
                        
                        [self hideModalProgressWithSuccess];
                        
                    } errorHandler:^(RPCRequest *request, RpcError *error) {
                        [self hideModalProgress];
                        
                        [asWeak.controller performSelector:@selector(performShake) withObject:nil];
                        
                    } timeout:10];
                    
                    
                    
                    return YES;
                };
                
                [[Telegram rightViewController] showSetPasswordWithAction:sAction];
                
                
                
            } description:pwd.has_recovery ? NSLocalizedString(@"PasswordSettings.ChangeRecoveryEmail", nil) : NSLocalizedString(@"PasswordSettings.SetRecoveryEmail", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
                return @(NO);
            }];
            
            [self.tableView insert:recoveryEmail atIndex:self.tableView.list.count tableRedraw:NO];
            
            
            // description
            
            GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"PasswordSettings.EnabledDescription", nil),[_passwordResult email_unconfirmed_pattern]] height:100 flipped:YES];
            
            [self.tableView insert:description atIndex:self.tableView.count tableRedraw:NO];
        }

    } else {
        
        if(![_passwordResult isKindOfClass:[TL_account_noPassword class]]) {
            
            GeneralSettingsRowItem *recoveryEmail = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
                
                
                TGSetPasswordAction *sAction = [[TGSetPasswordAction alloc] init];
                
                sAction.title = NSLocalizedString(@"PasswordSettings.InputPassword", nil);
                
                __weak TGSetPasswordAction *asWeak = sAction;
                
                
                void (^changeEmail)(NSString *password,NSData *phash,NSString *email) = ^(NSString *password,NSData *phash,NSString *email) {
                    
                    
                    TGSetPasswordAction *emailAction = [[TGSetPasswordAction alloc] init];
                    
                    if(pwd.has_recovery) {
                        emailAction.title = NSLocalizedString(@"PasswordSettings.ChangeRecoveryEmail", nil);
                        emailAction.desc =  NSLocalizedString(@"PasswordSettings.RecoveryEmailDesc", nil);
                    } else {
                        emailAction.title = NSLocalizedString(@"PasswordSettings.RecoveryEmail", nil);
                        emailAction.desc =  NSLocalizedString(@"PasswordSettings.RecoveryEmailDesc", nil);
                    }
                    
                    
                    emailAction.defaultValue = email;
                    
                    __weak TGSetPasswordAction *wEAction = emailAction;
                    
                    emailAction.callback = ^BOOL (NSString *email) {
                        
                        if(NSStringIsValidEmail(email)) {
                            [self setPassword:password current_pswd_hash:phash email:email hint:pwd.hint flags:2 successCallback:^{
                                
                                alert(NSLocalizedString(@"PasswordSettings.AlertConfirmEmail", nil), NSLocalizedString(@"PasswordSettings.AlertConfirmEmailDescription", nil));
                                
                            } errorCallback:^{
                                [wEAction.controller performSelector:@selector(performShake) withObject:nil];
                            }];
                        }
                        
                        return !email || NSStringIsValidEmail(email);
                    };
                    
                    [[Telegram rightViewController].navigationViewController.viewControllerStack removeLastObject];
                    [[Telegram rightViewController] showEmailPasswordWithAction:emailAction];
                    
                };
                
                
                sAction.callback = ^BOOL (NSString *password) {
                    
                    NSData *phash = passwordHash(password,[pwd current_salt]);
                    
                    [self showModalProgress];
                    
                    
                    [RPCRequest sendRequest:[TLAPI_account_getPasswordSettings createWithCurrent_password_hash:phash] successHandler:^(RPCRequest *request, TL_account_passwordSettings *response) {
                        
                        
                        if([response isKindOfClass:[TL_account_passwordSettings class]]) {
                            
                            changeEmail(password,phash,[response email]);
                            
                        }
                        
                        
                        [self hideModalProgressWithSuccess];
                        
                    } errorHandler:^(RPCRequest *request, RpcError *error) {
                        [self hideModalProgress];
                        
                        [asWeak.controller performSelector:@selector(performShake) withObject:nil];
                        
                    } timeout:10];
                    
                    
                    
                    return YES;
                };
                
                [[Telegram rightViewController] showSetPasswordWithAction:sAction];
                
                
                
            } description:NSLocalizedString(@"PasswordSettings.ChangeRecoveryEmail", nil) height:82 stateback:^id(TGGeneralRowItem *item) {
                return @(NO);
            }];
            
            [self.tableView insert:recoveryEmail atIndex:self.tableView.list.count tableRedraw:NO];
            
        }
        
        
        
        
        
        GeneralSettingsRowItem *turnPassword = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
            
            
            if([_passwordResult isKindOfClass:[TL_account_noPassword class]]) {
                
                
                [self setPassword:@"" current_pswd_hash:[[NSData alloc] init] email:@"" hint:@"" flags:2 successCallback:^{
                    
                    alert(nil, NSLocalizedString(@"PasswordSettings.AlertSuccessDeactivatedDescription", nil));
                    
                } errorCallback:nil];
                
            } else {
                
                TGSetPasswordAction *sAction = [[TGSetPasswordAction alloc] init];
                
                sAction.title = NSLocalizedString(@"PasswordSettings.InputPassword", nil);
                
                __weak TGSetPasswordAction *asWeak = sAction;
                
                sAction.callback = ^BOOL (NSString *password) {
                    
                    
                    NSData *phash = passwordHash(password,[pwd current_salt]);
                    
                    [self showModalProgress];
                    
                    [RPCRequest sendRequest:[TLAPI_account_getPasswordSettings createWithCurrent_password_hash:phash] successHandler:^(RPCRequest *request, TL_account_passwordSettings *response) {
                        
                        
                        if([response isKindOfClass:[TL_account_passwordSettings class]]) {
                            
                            [self setPassword:@"" current_pswd_hash:phash email:@"" hint:@"" flags:2 | 1 successCallback:^{
                                
                                alert(nil, NSLocalizedString(@"PasswordSettings.AlertSuccessDeactivatedDescription", nil));
                                
                            } errorCallback:^{
                                [asWeak performSelector:@selector(performShake) withObject:nil];
                            }];
                            
                        }
                        
                        
                        
                    } errorHandler:^(RPCRequest *request, RpcError *error) {
                        [self hideModalProgress];
                    } timeout:10];
                    
                    
                    
                    return YES;
                };
                
                [[Telegram rightViewController] showSetPasswordWithAction:sAction];
                
            }
            
            
            
            
            
        } description: NSLocalizedString(@"PasswordSettings.AbortPassword", nil) height:self.tableView.count == 0 ? 82 : 42 stateback:^id(TGGeneralRowItem *item) {
            return @(NO);
        }];
        
        [self.tableView insert:turnPassword atIndex:self.tableView.count tableRedraw:NO];
        
        
        GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"PasswordSettings.ConfrimEmailDescription", nil),[_passwordResult email_unconfirmed_pattern]] height:100 flipped:NO];
        
        
        
        [self.tableView insert:description atIndex:self.tableView.count tableRedraw:NO];
    }
    

    
    
    [self.tableView reloadData];
    
}




-(void)setPassword:(NSString *)password current_pswd_hash:(NSData *)current_pswd_hash email:(NSString *)email hint:(NSString *)hint flags:(int)flags successCallback:(dispatch_block_t)successCallback errorCallback:(dispatch_block_t)errorCallback {
    
    [self showModalProgress];
    
    NSData *passhash = [[NSData alloc] init];
    
    NSMutableData *newsalt = [[NSMutableData alloc] init];
    
    if(password.length > 0) {
        
        newsalt = [[self.passwordResult n_salt] mutableCopy];
        
        [newsalt addRandomBytes:8];
        
        passhash = passwordHash(password, newsalt);
        
    }
    

    [RPCRequest sendRequest:[TLAPI_account_updatePasswordSettings createWithCurrent_password_hash:current_pswd_hash n_settings:[TL_account_passwordInputSettings createWithFlags:flags n_salt:newsalt n_password_hash:passhash hint:hint email:email]] successHandler:^(RPCRequest *request, id response) {
        
        
        
        [[Telegram rightViewController] clearStack];
        
        [[Telegram rightViewController] showPrivacyController];
        
        [self hideModalProgressWithSuccess];
        
        if(successCallback)
        {
            successCallback();
        }
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(error.error_code == 400) {
            
            if([error.error_msg isEqualToString:@"EMAIL_UNCONFIRMED"]) {
                [[Telegram rightViewController] clearStack];
                
                [[Telegram rightViewController] showPrivacyController];
                
                [self hideModalProgressWithSuccess];
                
                if(successCallback)
                {
                    successCallback();
                }
                
                 return;
            }
            

        }
        
        if(errorCallback)
        {
            errorCallback();
        }
        
        [self hideModalProgress];
        
    } timeout:10];
    
    
    
}

-(void)backgroundReload {
    [RPCRequest sendRequest:[TLAPI_account_getPassword create] successHandler:^(RPCRequest *request, id response) {
        
        
        _passwordResult = response;
        
        [self rebuildController];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        
    }];
}

-(void)reload {
    
    [self.tableView removeAllItems:YES];
    
    [self.progressIndicator setHidden:NO];
    
    [self.progressIndicator startAnimation:self.view];
    
    [self.progressIndicator setCenterByView:self.view];
    
    [self.tableView.containerView setHidden:YES];
    
    [RPCRequest sendRequest:[TLAPI_account_getPassword create] successHandler:^(RPCRequest *request, id response) {
        
        
        
        [self.progressIndicator stopAnimation:self.view];
        [self.progressIndicator setHidden:YES];
        [self.tableView.containerView setHidden:NO];
        
        _passwordResult = response;
        
        [self rebuildController];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        
    }];
}

-(BOOL)becomeFirstResponder {
    
    [self backgroundReload];
    
    [_updateTimer invalidate];
    _updateTimer = nil;
    
    _updateTimer  = [[TGTimer alloc] initWithTimeout:5 repeat:YES completion:^{
        
        if([[NSApplication sharedApplication] isActive])
            [self backgroundReload];
        
    } queue:[ASQueue mainQueue].nativeQueue];
    
    return [super becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_updateTimer invalidate];
    _updateTimer = nil;
}




-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self becomeFirstResponder];
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
