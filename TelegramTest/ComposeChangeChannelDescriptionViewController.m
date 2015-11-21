//
//  ComposeChangeChannelDescriptionViewController.m
//  Telegram
//
//  Created by keepcoder on 05/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "ComposeChangeChannelDescriptionViewController.h"
#import "TGSettingsTableView.h"
#import "TGGeneralInputRowItem.h"
#import "ComposeActionChangeChannelAboutBehavior.h"

@interface ComposeChangeChannelDescriptionViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,strong) TGGeneralInputRowItem *inputItem;
@end

@implementation ComposeChangeChannelDescriptionViewController


-(void)loadView {
    [super loadView];
    
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    weak();
    
    [self.doneButton setTapBlock:^{
        weakSelf.action.result = [[ComposeResult alloc] init];
        weakSelf.action.result.singleObject = weakSelf.inputItem.result.string;
        
        [weakSelf.action.behavior composeDidDone];
    }];
    
    [self.view addSubview:_tableView.containerView];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    
    [_tableView removeAllItems:YES];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    
    
    _inputItem = [[TGGeneralInputRowItem alloc] initWithObject:self.action.reservedObject1];
    
    TLChat *chat = self.action.object;
    
    _inputItem.result = [[NSAttributedString alloc] initWithString:chat.chatFull.about attributes:@{NSFontAttributeName:TGSystemFont(13)}];
    
    [_tableView addItem:_inputItem tableRedraw:YES];
    
    
    GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:self.action.reservedObject2 height:50 flipped:YES];
    
    
    [_tableView addItem:description tableRedraw:YES];
}

@end
