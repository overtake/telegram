//
//  ChannelInfoViewController.m
//  Telegram
//
//  Created by keepcoder on 21.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelInfoViewController.h"
#import "ChannelInfoHeaderView.h"
#import "ChatParticipantItem.h"
#import "ComposeActionAddChannelModeratorBehavior.h"



@interface ChannelInfoViewController ()
@end

@implementation ChannelInfoViewController

-(void)loadView {
    [super loadView];
    self.headerView = [[ChannelInfoHeaderView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 350)];

}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)setType:(ChatInfoViewControllerType)type {
    [super setType:type];
    
    [self reloadParticipants];
}

-(void)save {
    [self.headerView save];
}

-(void)setChat:(TLChat *)chat {
    [super setChat:chat];
    
    [self.rightNavigationBarView setHidden:!self.chat.isAdmin && !self.chat.isPublisher];
}

-(void)buildRightView {
    [super buildRightView];
     [self.rightNavigationBarView setHidden:!self.chat.isAdmin && !self.chat.isPublisher];
}

- (void)reloadParticipants {
    [self.tableView removeAllItems:NO];
    [self.tableView addItem:self.headerItem tableRedraw:NO];


    
   [self.tableView addItem:self.bottomItem tableRedraw:NO];
    [self.tableView reloadData];

}



@end
