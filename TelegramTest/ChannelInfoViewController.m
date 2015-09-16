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

@interface ChannelAddModeratorView : ChatBottomView

@end

@implementation ChannelAddModeratorView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        weak();
        
        [self.button setCallback:^{
            [[Telegram rightViewController] showComposeWithAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionAddChannelModeratorBehavior class] filter:@[] object:weakSelf.conversation.chat]]; 
        }];
        
        self.button.textButton.textColor = LINK_COLOR;
        
    }
    
    return self;
}

-(void)redrawRow {
    [self.button.textButton setStringValue:NSLocalizedString(@"Channel.AddModerator", nil)];
    
    [self.button sizeToFit];
}

@end


@interface ChannelInfoViewController ()
@property (nonatomic,strong) ChatBottomItem *addModeratorsItem;
@property (nonatomic,strong) ChannelAddModeratorView *addModeratorView;
@end

@implementation ChannelInfoViewController

-(void)loadView {
    [super loadView];
    self.headerView = [[ChannelInfoHeaderView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 350)];
    
    _addModeratorsItem = [[ChatBottomItem alloc] init];
    _addModeratorView = [[ChannelAddModeratorView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 42)];

}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setType:self.type];
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
    _addModeratorView.conversation = chat.dialog;
    self.type = ChatInfoViewControllerNormal;
    
    [self.rightNavigationBarView setHidden:!self.chat.isAdmin];
}

-(void)buildRightView {
    [super buildRightView];
     [self.rightNavigationBarView setHidden:!self.chat.dialog.chat.isAdmin];
}

- (void)reloadParticipants {
    [self.tableView removeAllItems:NO];
    [self.tableView addItem:self.headerItem tableRedraw:NO];

//    
//    if(self.type == ChatInfoViewControllerEdit) {
//        
//        TLChatParticipant *selfParticipant = self.fullChat.participants.self_participant;
//        
//        
//        ChatParticipantItem *item = [[ChatParticipantItem alloc] initWithObject:selfParticipant];
//        item.viewController = self;
//
//        
//        [self.tableView addItem:item tableRedraw:NO];
//        
//        [self.tableView addItem:_addModeratorsItem tableRedraw:NO];
//    } else {
//         [self.tableView addItem:self.bottomItem tableRedraw:NO];
//    }
    
    
   [self.tableView addItem:self.bottomItem tableRedraw:NO];
    [self.tableView reloadData];

}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    if(item == _addModeratorsItem)
    {
        return _addModeratorView;
    }
        
   return [super viewForRow:row item:item];
    
}

@end
