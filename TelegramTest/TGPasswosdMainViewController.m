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
                            
                            emailAction.callback = ^BOOL (NSString *email) {
                                
                                
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
        
        
        GeneralSettingsRowItem *changePassword = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
            
            
            
            
        } description: NSLocalizedString(@"PasswordSettings.ChangePassword", nil) height:82 stateback:^id(GeneralSettingsRowItem *item) {
            return @(NO);
        }];
        
        [self.tableView insert:changePassword atIndex:self.tableView.list.count tableRedraw:NO];
        

        
        GeneralSettingsRowItem *turnPassword = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
            
            
            
            
        } description: NSLocalizedString(@"PasswordSettings.TurnOffPassword", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
            return @(NO);
        }];
        
        [self.tableView insert:turnPassword atIndex:self.tableView.list.count tableRedraw:NO];
        
        
        
        GeneralSettingsRowItem *recoveryEmail = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
            
            
            
            
        } description: NSLocalizedString(@"PasswordSettings.SetRecoveryEmail", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
            return @(NO);
        }];
        
        [self.tableView insert:recoveryEmail atIndex:self.tableView.list.count tableRedraw:NO];
        
    }
    
    
   
    
    
    
    [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView removeAllItems:YES];
    
    [RPCRequest sendRequest:[TLAPI_account_getPassword create] successHandler:^(RPCRequest *request, id response) {
        
        _passwordResult = response;
        
        [self rebuildController];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        
    }];
    
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
