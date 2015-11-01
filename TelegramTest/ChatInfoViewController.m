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





@implementation ChatBottomView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        weak();
        
        self.wantsLayer = YES;
        
        self.button= [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Conversation.Delete", nil) tapBlock:^{
            
           
            [[Telegram rightViewController].messagesViewController deleteDialog:weakSelf.conversation callback:^{
                [weakSelf.button setLocked:NO];
            } startDeleting:^ {
                [weakSelf.button setLocked:YES];
            }];
        }];
        
        [self.button.textButton setTextColor:[NSColor redColor]];
        
        [self.button setFrame:NSMakeRect(100, 15, frameRect.size.width - 200, 42)];
        
       // self.backgroundColor = [NSColor blueColor];
        
        [self addSubview:self.button];

    }
    
    return self;
}

-(void)redrawRow {
    [self.button.textButton setStringValue:_conversation.type == DialogTypeChat ? NSLocalizedString(@"Conversation.DeleteAndExit", nil) : (_conversation.chat.isAdmin ? NSLocalizedString(@"Profile.DeleteChannel", nil) : NSLocalizedString(@"Profile.LeaveChannel", nil))];
    
    [self.button sizeToFit];
}

@end


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
        
    }
    return self;
}


-(void)loadView {
    [super loadView];
    
    
    
    _headerItem = [[ChatHeaderItem alloc] init];
    _bottomItem = [[ChatBottomItem alloc] init];
    
    self.type = ChatInfoViewControllerNormal;
    
    [self setCenterBarViewText:NSLocalizedString(@"Profile.Info", nil)];
    
    _bottomView = [[ChatBottomView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 42)];

    
    
    
    _headerView = [[ChatInfoHeaderView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 450)];
    

    _tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    [_tableView setTm_delegate:self];
    [_tableView.containerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.view addSubview:_tableView.containerView];
    
    
}


-(void)buildFirstItem {
    [self.tableView reloadData];
}

-(void)setType:(ChatInfoViewControllerType)type {
    _type = type;
    [self.headerView setType:type];
    [self buildRightView];
}

- (void)buildRightView {
    TMView *view = [[TMView alloc] init];
        
    int width = 0;
    
    TMTextButton *button;
    
    
    if((!self.chat.isAdmins_enabled || self.chat.isAdmin) || self.chat.isCreator) {
        if(self.type == ChatInfoViewControllerNormal) {
            
            button = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Edit", nil)];
            [button setTapBlock:^{
                self.type = ChatInfoViewControllerEdit;
                [self buildRightView];
            }];
            [view addSubview:button];
            
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
                
                [strongSelf.headerView.nameTextField setChat:nil];
                [strongSelf.headerView.nameTextField setChat:self.chat];
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
    } else {
        [self setRightNavigationBarView:nil];
    }
    
    
}

- (void)save {
    
    
    dispatch_block_t block = ^{
        self.type = ChatInfoViewControllerNormal;
        [self buildRightView];
    };
    
    if(![_headerView.title isEqualToString:self.chat.title] && _headerView.title.length > 0) {
        [RPCRequest sendRequest:[TLAPI_messages_editChatTitle createWithChat_id:self.chat.n_id title:_headerView.title] successHandler:^(RPCRequest *request, id response) {
            block();
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            block();
        }];
    } else {
        NSBeep();
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
     [self reloadParticipants];
    
    [Notification addObserver:self selector:@selector(chatStatusNotification:) name:CHAT_STATUS];
    [Notification addObserver:self selector:@selector(didChangeChatFlags:) name:CHAT_FLAGS_UPDATED];
}

-(void)didChangeChatFlags:(NSNotification *)notification {
    TLChat *chat = notification.userInfo[KEY_CHAT];
    
    if(self.chat == chat) {
        self.chat = chat;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Notification removeObserver:self];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
   
    
    if([_headerView.nameTextField becomeFirstResponder])
        [_headerView.nameTextField setCursorToEnd];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


-(void)_didStackRemoved {
    self.chat = nil;
    [self.tableView removeAllItems:NO];
    [self.tableView reloadData];
}

- (void)chatStatusNotification:(NSNotification *)notify {
    if([[notify.userInfo objectForKey:KEY_CHAT_ID] intValue] == self.chat.n_id) {
        [self reloadParticipants];
    }
}

- (void)setChat:(TLChat *)chat {
    self->_chat = chat;
    
    if(chat) {
        [self view];
        
        [_headerView setController:self];
    
        [_headerView reload];
        
        _bottomView.conversation = chat.dialog;
        
        [_tableView scrollToBeginningOfDocument:_tableView];
        [_tableView.scrollView scrollToPoint:NSMakePoint(0, 0) animation:NO];
        
        
        self.fullChat = [[FullChatManager sharedManager] find:chat.n_id];
        
        
        
        
        [_tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:0]];
        
        [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:0] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        [self reloadParticipants];
        
        self.type = ChatInfoViewControllerNormal;
        [self buildRightView];

    } else {
        _type = ChatInfoViewControllerNormal;
        [_tableView removeAllItems:NO];
        [_tableView reloadData];
    }
    
}

- (void)kickParticipantByItem:(ChatParticipantItem *)item {
    item.isBlocking = YES;
    
    weakify();
    
    [RPCRequest sendRequest:[TLAPI_messages_deleteChatUser createWithChat_id:self.chat.n_id user_id:item.user.inputUser] successHandler:^(RPCRequest *request, id response) {
        
         TLChatParticipants *participants = strongSelf.fullChat.participants;
        
        
        NSArray *participant = [participants.participants filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.user_id == %d",item.user.n_id]];
        
        if(participant.count == 1) {
            id object = participant[0];
            
            
            if(object)
                [participants.participants removeObject:object];
            
            [[Storage manager] insertFullChat:strongSelf.fullChat completeHandler:nil];
            
            strongSelf.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
            
            [strongSelf.tableView removeItem:item];
            
            strongSelf.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
            
            self.notNeedToUpdate = YES;

        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [[FullChatManager sharedManager] performLoad:strongSelf.chat.n_id callback:^(TLChatFull *fullChat) {
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
        return;
    }
    TLChatParticipants *participants = self.fullChat.participants;

    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int selfId = UsersManager.currentUserId;
    for(TLChatParticipant *participant in participants.participants) {
        ChatParticipantItem *item = [[ChatParticipantItem alloc] initWithObject:participant];
        item.isBlocking = ((ChatParticipantItem *)[_tableView itemByHash:item.hash]).isBlocking;
        item.isCanKicked = self.chat.isAdmins_enabled ? (participant.user_id != selfId && self.chat.isAdmin && ![participant isKindOfClass:[TL_chatParticipantCreator class]]) : (participant.user_id != selfId && participant.inviter_id == [UsersManager currentUserId]);
        item.viewController = self;
        [array addObject:item];
        
   
    }
    
    
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
    [_tableView reloadData];
}


//Table methods
- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    if([item isEqualTo:_headerItem]) {
        return _headerView.bounds.size.height;
    }  else if([item isKindOfClass:[ChatBottomItem class]]) {
        return 70;
    } else {
        return 50;
    }
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    if([item isEqualTo:_headerItem]) {
        return _headerView;
    } else if([item isEqualTo:_bottomItem]) {
        return _bottomView;
    } else {
        return [_tableView cacheViewForClass:[ChatParticipantRowView class] identifier:@"row"];
    }
}

- (void)selectionDidChange:(NSInteger)row item:(ChatParticipantItem *) item {
    
    TMViewController *infoViewController;
        
    infoViewController = [[UserInfoViewController alloc] initWithFrame:self.view.bounds];
    
    [(UserInfoViewController *)infoViewController setUser:item.user conversation:item.user.dialog];
    
    [self.navigationViewController pushViewController:infoViewController animated:YES];
    

}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return ![item isEqualTo:_headerItem] && ![item isEqualTo:_bottomItem];
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return ![item isEqualTo:_headerItem] && ![item isEqualTo:_bottomItem];
}

@end
