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
@interface TGPasswosdMainViewController ()<TMTableViewDelegate>


@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) id passwordResult;

@end

@implementation TGPasswosdMainViewController





-(void)loadView {
    [super loadView];
    
    [self setCenterBarViewText:NSLocalizedString(@"PrivacyAndSecurity.TwoStepVerification", nil)];
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    
    [self.view addSubview:self.tableView.containerView];
    
}


-(void)rebuildController {
    
    
    [self.tableView removeAllItems:NO];
    
    
    if([self.passwordResult isKindOfClass:[TL_account_noPassword class]]) {
        GeneralSettingsRowItem *turnPassword = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
            
            TGSetPasswordAction *firstAction = [[TGSetPasswordAction alloc] init];
            
            firstAction.title = NSLocalizedString(@"PasswordSettings.SetPassword", nil);
            
            firstAction.callback = ^BOOL (NSString *fp) {
                
                if(fp.length > 0) {
                    TGSetPasswordAction *confirmAction = [[TGSetPasswordAction alloc] init];
                    
                    confirmAction.title = NSLocalizedString(@"PasswordSettings.ConfirmPassword", nil);
                    
                    confirmAction.callback = ^BOOL (NSString *sp) {
                        
                       
                        if([sp isEqualToString:fp]) {
                            
                            TGSetPasswordAction *emailAction = [[TGSetPasswordAction alloc] init];
                            
                            emailAction.title = NSLocalizedString(@"PasswordSettings.RecoveryEmail", nil);
                            emailAction.desc =  NSLocalizedString(@"PasswordSettings.RecoveryEmailDesc", nil);
                            
                            emailAction.hasButton = YES;
                            
                            emailAction.callback = ^BOOL (NSString *email) {
                                
                                
                                [self setPassword:fp current_pswd_hash:[[NSData alloc] init] email:email hint:@"" flags:1 | (NSStringIsValidEmail(email) ? 2 : 0) successCallback:^{
                                    
                                    if(NSStringIsValidEmail(email)) {
                                        alert(nil, NSLocalizedString(@"PasswordSettings.AlertConfirmEmailDescription", nil));
                                    } else {
                                        alert(nil, NSLocalizedString(@"PasswordSettings.AlertSuccessActivatedDescription", nil));
                                    }
                                    
                                    
                                    
                                }];
                                
                                return !email || NSStringIsValidEmail(email);
                            };
                            
                            [[Telegram rightViewController] showEmailPasswordWithAction:emailAction];
                        }
                         
                        return [sp isEqualToString:fp];
                    };
                    
                    [[Telegram rightViewController] showSetPasswordWithAction:confirmAction];
                    
                    return YES;
                }
                
                return NO;
                
                
            };
            
            [[Telegram rightViewController] showSetPasswordWithAction:firstAction];
            
            
        } description:NSLocalizedString(@"PasswordSettings.TurnOnPassword", nil) height:82 stateback:^id(GeneralSettingsRowItem *item) {
            return @(NO);
        }];
        
        [self.tableView insert:turnPassword atIndex:self.tableView.list.count tableRedraw:NO];
        
    } else {
        
         TL_account_password *pwd = _passwordResult;
        
        
        GeneralSettingsRowItem *changePassword = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
            
            
            TGSetPasswordAction *sAction = [[TGSetPasswordAction alloc] init];
            
            sAction.title = NSLocalizedString(@"PasswordSettings.InputPassword", nil);
            
            __weak TGSetPasswordAction *asWeak = sAction;
            
            sAction.callback = ^BOOL (NSString *password) {
                
                
                NSData *phash = passwordHash(password,[pwd current_salt]);
                
                [self showModalProgress];
                
                [RPCRequest sendRequest:[TLAPI_account_getPasswordSettings createWithCurrent_password_hash:phash] successHandler:^(RPCRequest *request, TL_account_passwordSettings *response) {
                    
                    
                    if([response isKindOfClass:[TL_account_passwordSettings class]]) {
                        
                        TGSetPasswordAction *firstAction = [[TGSetPasswordAction alloc] init];
                        
                        firstAction.title = NSLocalizedString(@"PasswordSettings.InputNewPassword", nil);
                        
                        firstAction.callback = ^BOOL (NSString *fp) {
                            
                            if(fp.length > 0) {
                                TGSetPasswordAction *confirmAction = [[TGSetPasswordAction alloc] init];
                                
                                confirmAction.title = NSLocalizedString(@"PasswordSettings.ConfirmPassword", nil);
                                
                                confirmAction.callback = ^BOOL (NSString *sp) {
                                    
                                    
                                    if([sp isEqualToString:fp]) {
                                        
                                        [self setPassword:fp current_pswd_hash:phash email:[response email] hint:[pwd hint] flags:3 successCallback:^{
                                            alert(nil, NSLocalizedString(@"PasswordSettings.AlertSuccessChangedDescription", nil));
                                        }];
                                    }
                                    
                                    return [sp isEqualToString:fp];
                                };
                                
                                [[Telegram rightViewController] showSetPasswordWithAction:confirmAction];
                                
                                return YES;
                            }
                            
                            return NO;
                            
                            
                        };
                        
                        [[Telegram rightViewController] showSetPasswordWithAction:firstAction];
                        
                        
                    }
                    
                    [self hideModalProgressWithSuccess];
                    
                    
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    [self hideModalProgress];
                    
                    [asWeak.controller performSelector:@selector(performShake) withObject:nil];
                    
                }];
                
                
                
                return YES;
            };
            
            [[Telegram rightViewController] showSetPasswordWithAction:sAction];
            
            
        } description: NSLocalizedString(@"PasswordSettings.ChangePassword", nil) height:82 stateback:^id(GeneralSettingsRowItem *item) {
            return @(NO);
        }];
        
        [self.tableView insert:changePassword atIndex:self.tableView.list.count tableRedraw:NO];
        

        
        GeneralSettingsRowItem *turnPassword = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
            
            
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
                            
                        }];
                        
                    }
                    
                    
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    [self hideModalProgress];
                    
                    [asWeak.controller performSelector:@selector(performShake) withObject:nil];
                    
                }];
                
                
                
                return YES;
            };
            
            [[Telegram rightViewController] showSetPasswordWithAction:sAction];

            
            
        } description: NSLocalizedString(@"PasswordSettings.TurnOffPassword", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
            return @(NO);
        }];
        
        [self.tableView insert:turnPassword atIndex:self.tableView.list.count tableRedraw:NO];
        
            GeneralSettingsRowItem *recoveryEmail = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
                
                
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
                            
                            emailAction.callback = ^BOOL (NSString *email) {
                                
                                if(NSStringIsValidEmail(email)) {
                                    [self setPassword:password current_pswd_hash:phash email:email hint:pwd.hint flags:2 successCallback:^{
                                        
                                        alert(NSLocalizedString(@"PasswordSettings.AlertConfirmEmail", nil), NSLocalizedString(@"PasswordSettings.AlertConfirmEmailDescription", nil));
                                        
                                    }];
                                }
                                
                                return !email || NSStringIsValidEmail(email);
                            };
                            
                            
                            [[Telegram rightViewController] showEmailPasswordWithAction:emailAction];
                            
                        }
                        
                        
                        [self hideModalProgressWithSuccess];
                        
                    } errorHandler:^(RPCRequest *request, RpcError *error) {
                        [self hideModalProgress];
                        
                        [asWeak.controller performSelector:@selector(performShake) withObject:nil];
                        
                    }];
                    
                    
                    
                    return YES;
                };
                
                [[Telegram rightViewController] showSetPasswordWithAction:sAction];
                
                
                
            } description:pwd.has_recovery ? NSLocalizedString(@"PasswordSettings.ChangeRecoveryEmail", nil) : NSLocalizedString(@"PasswordSettings.SetRecoveryEmail", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
                return @(NO);
            }];
            
            [self.tableView insert:recoveryEmail atIndex:self.tableView.list.count tableRedraw:NO];
        
    }
    
    
    [self.tableView reloadData];
    
}




-(void)setPassword:(NSString *)password current_pswd_hash:(NSData *)current_pswd_hash email:(NSString *)email hint:(NSString *)hint flags:(int)flags successCallback:(dispatch_block_t)successCallback {
    
    [self showModalProgress];
    
    NSData *passhash = [[NSData alloc] init];
    
    NSMutableData *newsalt = [[NSMutableData alloc] init];
    
    if(password.length > 0) {
        
        newsalt = [[self.passwordResult n_salt] mutableCopy];
        
        [newsalt addRandomBytes:8];
        
        NSMutableData *hashData = [NSMutableData dataWithData:newsalt];
        
        [hashData appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
        
        [hashData appendData:newsalt];
        
         passhash =  MTSha256(hashData);
        
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
            
            [[Telegram rightViewController] clearStack];
            
            [[Telegram rightViewController] showPrivacyController];
            
            [self hideModalProgressWithSuccess];
            
            if(successCallback)
            {
                successCallback();
            }
            
            return;
        }
        
        [self hideModalProgress];
        
    }];
    
    
    
}

-(void)reload {
    [self.tableView removeAllItems:YES];
    
    [RPCRequest sendRequest:[TLAPI_account_getPassword create] successHandler:^(RPCRequest *request, id response) {
        
        _passwordResult = response;
        
        [self rebuildController];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    
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
