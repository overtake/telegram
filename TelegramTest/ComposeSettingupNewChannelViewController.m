//
//  ComposeSettingupNewChannelViewController.m
//  Telegram
//
//  Created by keepcoder on 20.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeSettingupNewChannelViewController.h"
#import "TGSettingsTableView.h"
@interface ComposeSettingupNewChannelViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@end

@implementation ComposeSettingupNewChannelViewController


-(void)loadView {
    [super loadView];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    
}


-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
    
    self.action.result = [[ComposeResult alloc] init];
    
    [self reload];
}


-(void)reload {
    
    [self.tableView removeAllItems:NO];
    
    
    GeneralSettingsBlockHeaderItem *headerItem = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.TypeHeader", nil) height:60 flipped:NO];
    headerItem.xOffset = 30;
    
    
    GeneralSettingsRowItem *publicSelector = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
        

        self.action.result.singleObject = @(YES);
        
    } description:NSLocalizedString(@"Channel.Public", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return self.action.result.singleObject;
    }];
    
    GeneralSettingsRowItem *privateSelector = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
        
        
        self.action.result.singleObject = @(NO);
        
    } description:NSLocalizedString(@"Channel.Private", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return @(![self.action.result.singleObject boolValue]);
    }];

    

    GeneralSettingsBlockHeaderItem *selectorDesc = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.ChoiceTypeDescription", nil) height:42 flipped:YES];
    
    
    selectorDesc.xOffset = privateSelector.xOffset = publicSelector.xOffset = 30;
    
    
    
    
    [self.tableView addItem:headerItem tableRedraw:NO];
    [self.tableView addItem:publicSelector tableRedraw:NO];
    [self.tableView addItem:privateSelector tableRedraw:NO];
    [self.tableView addItem:selectorDesc tableRedraw:NO];
    
    
    [self.tableView reloadData];
}

@end
