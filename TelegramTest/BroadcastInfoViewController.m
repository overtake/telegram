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
        
         self.headerView = [[BroadcastInfoHeaderView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 250)];
        
        [Notification removeObserver:self];
        
        [Notification addObserver:self selector:@selector(chatStatusNotification:) name:BROADCAST_STATUS];

    }
    
    return self;
}


-(void)setBroadcast:(TL_broadcast *)broadcast
{
    self->_broadcast = broadcast;
    
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
        if(self.tableView.count > 1) {
            [self buildFirstItem];
            TMRowItem *item = (TMRowItem *)[self.tableView itemAtPosition:1];
            [item redrawRow];
        }
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
    [self buildFirstItem];
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


- (void)buildFirstItem {
    if(self.tableView.count < 2)
        return;
    
    ChatParticipantItem *item;
    for(int i = 0; i < self.tableView.count; i++) {
        ChatParticipantItem *loopItem = (ChatParticipantItem *)[self.tableView itemAtPosition:i];
        if([loopItem isKindOfClass:[ChatParticipantItem class]]) {
            item = loopItem;
            break;
        }
    }

    
    if(!item)
        return;
    
    int allCount = (int) self.broadcast.participants.count;
    NSString *membersCountString = [NSString stringWithFormat:NSLocalizedString(@"Group.MembersCount", nil), allCount, allCount == 1 ? @"" : @"s"];
    item.membersCount = [[NSAttributedString alloc] initWithString:membersCountString attributes:[UserInfoContainerView attributsForInfoPlaceholderString]];
    
    int onlineCount = [[BroadcastManager sharedManager] getOnlineCount:self.broadcast.n_id];
    NSString *onlineCountString = [NSString stringWithFormat:NSLocalizedString(@"Group.OnlineCount", nil), onlineCount];
    item.onlineCount = [[NSAttributedString alloc] initWithString:onlineCountString attributes:[UserInfoContainerView attributsForInfoPlaceholderString]];
}

- (void)kickParticipantByItem:(ChatParticipantItem *)item {
    [self.broadcast removeParticipant:item.user.n_id];
    
    
    
    [self.tableView removeItem:item];

    
    [self reloadParticipants];
    
    [Notification perform:BROADCAST_STATUS data:@{KEY_CHAT_ID:@(self.broadcast.n_id)}];
    [Notification perform:BROADCAST_UPDATE_TITLE data:@{KEY_BROADCAST:self.broadcast}];
}

@end
