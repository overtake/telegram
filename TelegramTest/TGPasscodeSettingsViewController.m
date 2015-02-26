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
@interface TGPasscodeSettingsViewController ()<TMTableViewDelegate>
@property (nonatomic,strong) TMTextField *centerTextField;
@property (nonatomic,strong) TMTableView *tableView;
@end

@implementation TGPasscodeSettingsViewController


-(void)loadView {
    [super loadView];
    
    
    _centerTextField = [TMTextField defaultTextField];
    [self.centerTextField setAlignment:NSCenterTextAlignment];
    [self.centerTextField setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
    [self.centerTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
    [self.centerTextField setTextColor:NSColorFromRGB(0x222222)];
    [[self.centerTextField cell] setTruncatesLastVisibleLine:YES];
    [[self.centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.centerTextField setDrawsBackground:NO];
    
    [self.centerTextField setStringValue:NSLocalizedString(@"PasscodeSettings.Header", nil)];
    
    TMView *centerView = [[TMView alloc] initWithFrame:NSZeroRect];
    
    
    self.centerNavigationBarView = centerView;
    
    [centerView addSubview:self.centerTextField];
    
    [self.centerTextField sizeToFit];
    
    [self.centerTextField setCenterByView:centerView];
    
    [self.centerTextField setFrameOrigin:NSMakePoint(self.centerTextField.frame.origin.x, 13)];
    
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    
    [self.view addSubview:self.tableView.containerView];
    
    
    [self rebuildController];
    
    
}


-(void)rebuildController {
    
    
    [self.tableView removeAllItems:NO];
    
    GeneralSettingsRowItem *turnPasscode = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
        
        if([TGPasslock isEnabled]) {
            [self showPasslock:^(BOOL result, NSString *md5Hash) {
                
                [TGPasslock disableWithHash:md5Hash];
                
                [self rebuildController];
                
            }];
        } else {
            [self showCreatePasslock:^(BOOL result, NSString *md5Hash) {
                
                [TGPasslock enableWithHash:md5Hash];
                
                [self rebuildController];
                
            }];
        }
        
        
    } description:[TGPasslock isEnabled] ? NSLocalizedString(@"PasscodeSettings.TurnOffPasscode", nil) : NSLocalizedString(@"PasscodeSettings.TurnOnPasscode", nil) height:82 stateback:^id(GeneralSettingsRowItem *item) {
        return @(NO);
    }];
    
    [self.tableView insert:turnPasscode atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    if([TGPasslock isEnabled]) {
        
        GeneralSettingsRowItem *changePasscode = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
            
            [self showChangePasslock:^(BOOL result, NSString *md5Hash) {
                
                [TGPasslock changeWithHash:md5Hash];
                
                [self rebuildController];
                
            }];
            
        } description:NSLocalizedString(@"PasscodeSettings.ChangePasscode", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
            return @(NO);
        }];
        
        
        
        [self.tableView insert:changePasscode atIndex:self.tableView.list.count tableRedraw:NO];
        
        
        GeneralSettingsRowItem *autoLockPasscode = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeChoice callback:^(GeneralSettingsRowItem *item) {
            
            
        } description:NSLocalizedString(@"PasscodeSettings.AutoLock", nil) height:82 stateback:^id(GeneralSettingsRowItem *item) {
            return [TGPasslock autoLockDescription];
        }];
        
        
        
        
        NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Passcode.AutoLockTime0", nil) withBlock:^(id sender) {
            [TGPasslock setAutoLockTime:0];
            [self.tableView reloadData];
        }]];
        
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
