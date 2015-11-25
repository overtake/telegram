//
//  TGPasscodeSettingsViewController.m
//  Telegram
//
//  Created by keepcoder on 23.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGPasscodeSettingsViewController.h"
#import "GeneralSettingsRowView.h"
#import "GeneralSettingsBlockHeaderView.h"
#import "GeneralSettingsRowItem.h"
#import "TGPasslock.h"
#import "NSData+Extensions.h"
@interface TGPasscodeSettingsViewController ()<TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@end

@implementation TGPasscodeSettingsViewController


-(void)loadView {
    [super loadView];
    
    
    [self setCenterBarViewText:NSLocalizedString(@"PasscodeSettings.Header", nil)];
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    
    [self.view addSubview:self.tableView.containerView];
    
    
    [self rebuildController];
    
    
}


-(void)rebuildController {
    
    
    [self.tableView removeAllItems:NO];
    
    GeneralSettingsRowItem *turnPasscode = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        
        
        if([[MTNetwork instance] passcodeIsEnabled]) {
            
            [self showPasslock:^BOOL(BOOL result, NSString *md5Hash) {
                
                BOOL res = [[MTNetwork instance] checkPasscode:[md5Hash dataUsingEncoding:NSUTF8StringEncoding]];
                
                if(res) {
                    [[MTNetwork instance] updatePasscode:[[NSData alloc] initWithEmptyBytes:32]];
                    
                //    [Storage rekey:nil];
                    
                    [self rebuildController];
                    
                    [TMViewController hidePasslock];
                }
                
                
                
                return res;
            }];
            
            
        } else {
            [self showCreatePasslock:^BOOL(BOOL result, NSString *md5Hash) {
                
                [[MTNetwork instance] updatePasscode:[md5Hash dataUsingEncoding:NSUTF8StringEncoding]];
                
            //    [Storage rekey:md5Hash];
                
                [TMViewController hidePasslock];
                
                [self rebuildController];
                
                return YES;
                
            }];
        }
        
        
        
        
    } description:[[MTNetwork instance] passcodeIsEnabled] ? NSLocalizedString(@"PasscodeSettings.TurnOffPasscode", nil) : NSLocalizedString(@"PasscodeSettings.TurnOnPasscode", nil) height:82 stateback:^id(TGGeneralRowItem *item) {
        return @(NO);
    }];
    
    [self.tableView insert:turnPasscode atIndex:self.tableView.list.count tableRedraw:NO];
    
    if(![[MTNetwork instance] passcodeIsEnabled]) {
        
        GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"PasscodeSettings.TurnOnDescription", nil) height:100 flipped:YES];
        
        [self.tableView insert:description atIndex:self.tableView.count tableRedraw:NO];
    }
    
    
    
    if([[MTNetwork instance] passcodeIsEnabled]) {
        
        GeneralSettingsRowItem *changePasscode = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
            
            [self showChangePasslock:^BOOL(BOOL result, NSString *md5Hash) {
                
                if(result) {
                    
                 //   [Storage rekey:md5Hash];
                    
                    [[MTNetwork instance] updatePasscode:[md5Hash dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [self rebuildController];
                    
                    [TMViewController hidePasslock];
                   
                }
                
                 return result;
                
            }];
            
        } description:NSLocalizedString(@"PasscodeSettings.ChangePasscode", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
            return @(NO);
        }];
        
        
        
        [self.tableView insert:changePasscode atIndex:self.tableView.list.count tableRedraw:NO];
        
        
        GeneralSettingsRowItem *autoLockPasscode = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeChoice callback:^(TGGeneralRowItem *item) {
            
            
        } description:NSLocalizedString(@"PasscodeSettings.AutoLock", nil) height:82 stateback:^id(TGGeneralRowItem *item) {
            return [TGPasslock autoLockDescription];
        }];
        
        
        
        
        NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Passcode.AutoLockTime0", nil) withBlock:^(id sender) {
            [TGPasslock setAutoLockTime:0];
            [self.tableView reloadData];
        }]];
        
#ifdef TGDEBUG
        if(ACCEPT_FEATURE) {
            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Passcode.AutoLockTime5", nil) withBlock:^(id sender) {
                [TGPasslock setAutoLockTime:5];
                [self.tableView reloadData];
            }]];
        }
        
#endif
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Passcode.AutoLockTime60", nil) withBlock:^(id sender) {
            [TGPasslock setAutoLockTime:60];
            [self.tableView reloadData];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Passcode.AutoLockTime300", nil) withBlock:^(id sender) {
            [TGPasslock setAutoLockTime:300];
            [self.tableView reloadData];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Passcode.AutoLockTime3600", nil) withBlock:^(id sender) {
            [TGPasslock setAutoLockTime:3600];
            [self.tableView reloadData];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Passcode.AutoLockTime18000", nil) withBlock:^(id sender) {
            [TGPasslock setAutoLockTime:18000];
            
            [self.tableView reloadData];
        }]];
        
        autoLockPasscode.menu = menu;
    
        
        [self.tableView insert:autoLockPasscode atIndex:self.tableView.list.count tableRedraw:NO];
        
        
    }
    
   
    
    
    [self.tableView reloadData];
    
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
