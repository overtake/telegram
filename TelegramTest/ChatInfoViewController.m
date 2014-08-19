//
//  ChatInfoViewController.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/9/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ChatInfoViewController.h"
#import "ChatInfoHeaderView.h"
#import "ChatParticipantItem.h"
#import "ChatParticipantRowView.h"
#import "HackUtils.h"
#import "UserInfoContainerView.h"



@implementation ChatHeaderItem
- (NSObject *)itemForHash {
    return @"header";
}
+ (NSUInteger)hash:(NSObject *)object {
    return [object hash];
}
@end


@implementation ChatBottomItem
- (NSObject *)itemForHash {
    return @"bottom";
}
+ (NSUInteger)hash:(NSObject *)object {
    return [object hash];
}
@end

@interface ChatInfoViewController ()

@end

@implementation ChatInfoViewController

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        
        _tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
        [_tableView setTm_delegate:self];
        [_tableView.containerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self.view addSubview:_tableView.containerView];
     
        _headerItem = [[ChatHeaderItem alloc] init];
        _bottomItem = [[ChatBottomItem alloc] init];
        
        TMBackButton *backButton = [[TMBackButton alloc] initWithFrame:NSZeroRect string:NSLocalizedString(@"Conversation.Back", nil)];
        
        self.leftNavigationBarView = [[TMView alloc] initWithFrame:backButton.bounds];
        [self.leftNavigationBarView addSubview:backButton];
        self.type = ChatInfoViewControllerNormal;
        
        
        TMButton *center = [[TMButton alloc] initWithFrame:NSMakeRect(0, 0, 400, 200)];
        [center setTarget:self selector:@selector(navigationGoBack)];
        self.centerNavigationBarView = center;
        center.acceptCursor = NO;
        _headerView = [[ChatInfoHeaderView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 330)];
        
        [Notification addObserver:self selector:@selector(chatStatusNotification:) name:CHAT_STATUS];
    }
    return self;
}

- (void)navigationGoBack {
    [[Telegram rightViewController] navigationGoBack];
}

- (void)buildRightView {
    TMView *view = [[TMView alloc] init];
    
    [_headerView setType:self.type];
    
    int width = 0;
    
    TMTextButton *button;
    
    if(self.type == ChatInfoViewControllerNormal) {
        
        button = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Edit", nil)];
        [button setTapBlock:^{
            self.type = ChatInfoViewControllerEdit;
            [self buildRightView];
        }];
        [view addSubview:button];
        
        
        
        TMTextButton *exitButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Conversation.DeleteAndExit", nil)];
        
        
        [exitButton setTapBlock:^{
            [[[Telegram rightViewController] messagesViewController] deleteDialog:self.chat.dialog];
        }];
        
        
        [exitButton setFrameOrigin:NSMakePoint(button.bounds.size.width + 10, exitButton.frame.origin.y)];
        
        [view addSubview:exitButton];

        width = exitButton.frame.size.width+10;
        
    } else {
        
        
        
        button = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Save", nil)];
        
        
        
        [button setTapBlock:^{
            [self save];
        }];
        [view addSubview:button];
        
        
        
       TMTextButton *cancelButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
        [cancelButton setFrameOrigin:NSMakePoint(button.bounds.size.width + 10, button.frame.origin.y)];
        weakify();
        
        [cancelButton setTapBlock:^{
            strongSelf.type = ChatInfoViewControllerNormal;
            [self buildRightView];
        }];
        [view addSubview:cancelButton];
        
        width = cancelButton.frame.size.width+10;
        
        [view setFrameSize:NSMakeSize(cancelButton.frame.origin.x + cancelButton.bounds.size.width, cancelButton.bounds.size.height)];
        
    }
    
    width+= button.frame.size.width;

    [view setFrameSize:NSMakeSize(width, button.frame.size.height)];
    [self setRightNavigationBarView:view];
}

- (void)save {
    dispatch_block_t block = ^{
        self.type = ChatInfoViewControllerNormal;
        [self buildRightView];
    };
    
    if(![_headerView.title isEqualToString:self.chat.title]) {
        [MessageSender sendStatedMessage:[TLAPI_messages_editChatTitle createWithChat_id:self.chat.n_id title:_headerView.title] successHandler:^(RPCRequest *request, id response) {
            block();
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            block();
        }];
        return;
    }
    block();
}

- (void)loadView {
    [super loadView];
    
    [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    if([_headerView.nameTextField becomeFirstResponder])
        [_headerView.nameTextField setCursorToEnd];
}

- (void)chatStatusNotification:(NSNotification *)notify {
    if([[notify.userInfo objectForKey:KEY_CHAT_ID] intValue] == self.chat.n_id) {
        [self reloadParticipants];
    }
}

- (void)setChat:(TGChat *)chat {
    self->_chat = chat;
    [_tableView scrollToBeginningOfDocument:_tableView];
    [_tableView.scrollView scrollToPoint:NSMakePoint(0, 0) animation:NO];
    
    
    
    self.fullChat = [[FullChatManager sharedManager] find:chat.n_id];
    
    [_headerView setController:self];
    [_headerView reload];
    
    
   // [_tableView.con setFrameOrigin:NSMakePoint(_tableView.frame.origin.x, _headerView.frame.size.height)];
    
    [_tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:0]];
    
    [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:0] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    [self reloadParticipants];
    
    self.type = ChatInfoViewControllerNormal;
    [self buildRightView];
}

- (void)kickParticipantByItem:(ChatParticipantItem *)item {
    item.isBlocking = YES;
    
    weakify();
    
    [MessageSender sendStatedMessage:[TLAPI_messages_deleteChatUser createWithChat_id:self.chat.n_id user_id:item.user.inputUser] successHandler:^(RPCRequest *request, id response) {
        TGChatParticipants *participants = strongSelf.fullChat.participants;
        id object = nil;
        for(TGChatParticipant *participant in participants.participants) {
            if(participant.user_id == item.user.n_id) {
                object = participant;
                break;
            }
        }
        
        if(object)
            [participants.participants removeObject:object];
        
        [[Storage manager] insertFullChat:strongSelf.fullChat completeHandler:nil];

        [strongSelf.tableView removeItem:item];
        
        self.notNeedToUpdate = YES;
      //  [Notification perform:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT_ID: @(strongSelf.fullChat.n_id), KEY_PARTICIPANTS: strongSelf.fullChat.participants}];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [[FullChatManager sharedManager] performLoad:strongSelf.chat.n_id callback:^{
            item.isBlocking = NO;
            [item redrawRow];
        }];
    }];
}

- (void)reloadParticipants {
    
    
    if([Telegram leftViewController].popover.isShown) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(_headerView.bounds.size.height)
                [self reloadParticipants];
        });
        return;
    }
    
    if(self.notNeedToUpdate) {
        self.notNeedToUpdate = NO;
        if(_tableView.count > 1) {
            [self buildFirstItem];
            TMRowItem *item = (TMRowItem *)[_tableView itemAtPosition:1];
            [item redrawRow];
        }
        return;
    }
    TGChatParticipants *participants = self.fullChat.participants;

    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int selfId = UsersManager.currentUserId;
    for(TGChatParticipant *participant in participants.participants) {
        ChatParticipantItem *item = [[ChatParticipantItem alloc] initWithObject:participant];
        item.isBlocking = ((ChatParticipantItem *)[_tableView itemByHash:item.hash]).isBlocking;
        item.isCanKicked = (participant.inviter_id == selfId || self.fullChat.participants.admin_id == selfId) && participant.user_id != selfId;
        item.viewController = self;
        [array addObject:item];
        
   
    }
    
//    if(!isNeedUpdate) {
//        return;
//    }
    
    [_tableView removeAllItems:NO];
    [_tableView addItem:_headerItem tableRedraw:NO];
    [_tableView insert:[array sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(ChatParticipantItem *obj1, ChatParticipantItem *obj2) {
        
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
    
    [_tableView addItem:_bottomItem tableRedraw:NO];
    [self buildFirstItem];
    [_tableView reloadData];
}

- (void)buildFirstItem {
    if(_tableView.count < 2)
        return;
    
    ChatParticipantItem *item;
    for(int i = 0; i < _tableView.count; i++) {
        ChatParticipantItem *loopItem = (ChatParticipantItem *)[_tableView itemAtPosition:i];
        if([loopItem isKindOfClass:[ChatParticipantItem class]]) {
            item = loopItem;
            break;
        }
    }
    
    if(!item)
        return;
    
    int allCount = self.chat.participants_count;
    NSString *membersCountString = [NSString stringWithFormat:NSLocalizedString(@"Group.MembersCount", nil), allCount, allCount == 1 ? @"" : @"s"];
    item.membersCount = [[NSAttributedString alloc] initWithString:membersCountString attributes:[UserInfoContainerView attributsForInfoPlaceholderString]];
    
    int onlineCount = [[FullChatManager sharedManager] getOnlineCount:self.chat.n_id];
    NSString *onlineCountString = [NSString stringWithFormat:NSLocalizedString(@"Group.OnlineCount", nil), onlineCount];
    item.onlineCount = [[NSAttributedString alloc] initWithString:onlineCountString attributes:[UserInfoContainerView attributsForInfoPlaceholderString]];
}

//Table methods
- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    if([item isEqualTo:_headerItem]) {
        return _headerView.bounds.size.height;
    }  else if([item isEqualTo:_bottomItem]) {
        return 40.f;
    } else {
        return 56.f;
    }
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    if([item isEqualTo:_headerItem]) {
        return _headerView;
    } else if([item isEqualTo:_bottomItem]) {
        return nil;
    } else {
        return [_tableView cacheViewForClass:[ChatParticipantRowView class] identifier:@"row"];
    }
}

- (void)selectionDidChange:(NSInteger)row item:(ChatParticipantItem *) item {
    [[Telegram rightViewController] showUserInfoPage:item.user];
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return ![item isEqualTo:_headerItem] && ![item isEqualTo:_bottomItem];
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return ![item isEqualTo:_headerItem] && ![item isEqualTo:_bottomItem];
}

@end
