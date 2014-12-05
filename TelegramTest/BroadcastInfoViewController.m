//
//  BroadcastInfoViewController.m
//  Telegram
//
//  Created by keepcoder on 11.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BroadcastInfoViewController.h"
#import "ChatParticipantItem.h"
#import "UserInfoContainerView.h"
#import "BroadcastInfoHeaderView.h"
@interface BroadcastInfoViewController ()

@end

@implementation BroadcastInfoViewController

-(id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {

    }
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Notification addObserver:self selector:@selector(chatStatusNotification:) name:BROADCAST_STATUS];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Notification removeObserver:self];
}

-(void)loadView {
    [super loadView];
     self.headerView = [[BroadcastInfoHeaderView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 260)];
}


-(void)setBroadcast:(TL_broadcast *)broadcast
{
    self->_broadcast = broadcast;
    [self view];
    
    self.bottomView.conversation = broadcast.conversation;
    
    [super setChat:nil];
    
}


- (void)chatStatusNotification:(NSNotification *)notify {
    if([[notify.userInfo objectForKey:KEY_CHAT_ID] intValue] == self.broadcast.n_id) {
        [self reloadParticipants];
    }
}

- (void)reloadParticipants {
    
    
    [[[BroadcastManager sharedManager] broadcastMembersCheckerById:self.broadcast.n_id] reloadParticipants];
    
    if(self.notNeedToUpdate) {
        self.notNeedToUpdate = NO;
        return;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSNumber *participant in self.broadcast.participants) {
        ChatParticipantItem *item = [[ChatParticipantItem alloc] initWithUser:[[UsersManager sharedManager] find:[participant integerValue]]];
        item.isBlocking = ((ChatParticipantItem *)[self.tableView itemByHash:item.hash]).isBlocking;
        item.isCanKicked = YES;
        item.viewController = self;
        [array addObject:item];
        
        
    }
    
    
    [self.tableView removeAllItems:NO];
    [self.tableView addItem:self.headerItem tableRedraw:NO];
    [self.tableView insert:[array sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(ChatParticipantItem *obj1, ChatParticipantItem *obj2) {
        
        if(obj1.user.n_id == UsersManager.currentUserId) {
            return NSOrderedAscending;
        }
        
        if(obj2.user.n_id == UsersManager.currentUserId) {
            return NSOrderedDescending;
        }
        
        int online1 = obj1.user.lastSeenTime;
        int online2 = obj2.user.lastSeenTime;
        
        return online1 > online2 ?  NSOrderedAscending : NSOrderedDescending;
    }] startIndex:1 tableRedraw:NO];
    
    [self.tableView addItem:self.bottomItem tableRedraw:NO];
    [self.tableView reloadData];
    
}


- (void)save {
    dispatch_block_t block = ^{
        self.type = ChatInfoViewControllerNormal;
        [self buildRightView];
    };
    
    self.broadcast.title = self.headerView.title;
        
    [Notification perform:BROADCAST_UPDATE_TITLE data:@{KEY_BROADCAST:self.broadcast}];
        
    [[Storage manager] insertBroadcast:self.broadcast];
        
    block();

}


- (void)kickParticipantByItem:(ChatParticipantItem *)item {
    [self.broadcast removeParticipant:item.user.n_id];
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
    [self.tableView removeItem:item];
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;

    [Notification perform:BROADCAST_UPDATE_TITLE data:@{KEY_BROADCAST:self.broadcast}];
}

@end
