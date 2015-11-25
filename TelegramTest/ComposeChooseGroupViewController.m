//
//  ComposeAddToGroupViewController.m
//  Telegram
//
//  Created by keepcoder on 19.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeChooseGroupViewController.h"
#import "SelectChatItem.h"
#import "SelectUsersTableView.h"
@interface ComposeChooseGroupViewController ()<TMTableViewDelegate,ComposeBehaviorDelegate,SelectTableDelegate>
@property (nonatomic,strong) SelectUsersTableView *tableView;
@end

@implementation ComposeChooseGroupViewController

-(void)loadView {
    [super loadView];
    
    _tableView = [[SelectUsersTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    [self.doneButton setHidden:YES];
    
}

-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
}


-(void)behaviorDidEndRequest:(id)response {
    [self hideModalProgress];
}

-(void)behaviorDidStartRequest {
    [self showModalProgress];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

-(void)_didStackRemoved {
    [self.action.behavior composeDidCancel];
    [self.tableView removeAllItems:NO];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.selectLimit = 0;
    
    self.action.behavior.delegate = self;
    
    [self.tableView readyChats];
    
    self.tableView.selectDelegate = self;
    
    [self.tableView scrollToBeginningOfDocument:self];
    
    self.action.currentViewController = self;
    
    [self setCenterBarViewTextAttributed:self.action.behavior.centerTitle];
    
    
    
}




-(void)selectTableDidChangedItem:(SelectChatItem *)item {
    
    [self.tableView cancelSelection];
    
    confirm(appName(), [NSString stringWithFormat:NSLocalizedString(@"Bot.confirmAddBot", nil),item.chat.title], ^{
        
        self.action.result = [[ComposeResult alloc] initWithMultiObjects:@[item.chat]];
        
        [self.action.behavior composeDidDone];
        
        [self.tableView cancelSelection];
        
        
    }, nil);
    
}

@end
