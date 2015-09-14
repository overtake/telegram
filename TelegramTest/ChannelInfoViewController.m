//
//  ChannelInfoViewController.m
//  Telegram
//
//  Created by keepcoder on 21.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelInfoViewController.h"
#import "ChannelInfoHeaderView.h"
@implementation ChannelInfoViewController

-(void)loadView {
    [super loadView];
    self.headerView = [[ChannelInfoHeaderView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 350)];
    

}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setType:self.type];
}

-(void)save {
    [self.headerView save];
}

-(void)setChat:(TLChat *)chat {
    [super setChat:chat];
    
    self.type = ChatInfoViewControllerNormal;
    
    [self.rightNavigationBarView setHidden:!self.chat.dialog.chat.isAdmin];
}

-(void)buildRightView {
    [super buildRightView];
     [self.rightNavigationBarView setHidden:!self.chat.dialog.chat.isAdmin];
}

@end
