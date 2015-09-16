//
//  ComposeConfirmModeratorViewController.m
//  Telegram
//
//  Created by keepcoder on 16.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeConfirmModeratorViewController.h"
#import "TGSettingsTableView.h"
#import "TGUserContainerRowItem.h"
#import "SelectUserItem.h"

@interface ComposeConfirmModeratorViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,strong) TGUserContainerRowItem *userContainer;

@property (nonatomic,assign) BOOL isModerator;
@end

@implementation ComposeConfirmModeratorViewController

-(void)loadView {
    [super loadView];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    

    
}


-(void)setAction:(ComposeAction *)action {
    
    [super setAction:action];
    
    
    _isModerator = YES;
    
    _userContainer = [[TGUserContainerRowItem alloc] initWithUser:[(SelectUserItem *)action.result.multiObjects[0] user]];
    
    _userContainer.height = 60;
    
    [_tableView removeAllItems:NO];
    
    [_tableView addItem:_userContainer tableRedraw:NO];
    
    GeneralSettingsRowItem *moderatorItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
        
        self.isModerator = YES;
        [_tableView reloadData];
        
    } description:NSLocalizedString(@"Channel.Moderator", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return @(_isModerator);
    }];
    
   
    GeneralSettingsRowItem *editorItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(GeneralSettingsRowItem *item) {
        
        self.isModerator = NO;
        [_tableView reloadData];
        
    } description:NSLocalizedString(@"Channel.Editor", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return @(!_isModerator);
    }];
    
     moderatorItem.xOffset = 30;
     editorItem.xOffset = 30;
    
    
    
    
    GeneralSettingsBlockHeaderItem *accessHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.AccessHeader", nil) height:42 flipped:NO];
    
    accessHeader.xOffset = 30;
    
    GeneralSettingsBlockHeaderItem *accessDescription = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.AccessDescription", nil) height:200 flipped:YES];
    
    accessDescription.xOffset = 30;

    
    
    [_tableView addItem:accessHeader tableRedraw:NO];
    
    [_tableView addItem:moderatorItem tableRedraw:NO];
    [_tableView addItem:editorItem tableRedraw:NO];
    
    [_tableView addItem:accessDescription tableRedraw:NO];
    
    [_tableView reloadData];
}

-(void)setIsModerator:(BOOL)isModerator {
    _isModerator = isModerator;
    
    self.action.result.singleObject = @(isModerator);
}

-(void)reloadData {
    
    
    
}

@end
