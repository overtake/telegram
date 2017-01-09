//
//  TGRecentSearchTableView.m
//  Telegram
//
//  Created by keepcoder on 14.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGRecentSearchTableView.h"
#import "TGRecentSearchRowView.h"
#import "TGRecentMoreItem.h"
#import "TGRecentHeaderItem.h"
@interface TGRecentSearchTableView () <TMTableViewDelegate>
@property (nonatomic,strong) TMView *border;
@property (nonatomic,strong) NSArray *topCategories;
@property (nonatomic,strong) NSArray *recentPeers;
@end

@implementation TGRecentSearchTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.tm_delegate = self;
        
        _border = [[TMView alloc] initWithFrame:NSMakeRect(NSWidth(frameRect) - DIALOG_BORDER_WIDTH, 0, DIALOG_BORDER_WIDTH, NSHeight(frameRect))];
        _border.backgroundColor = DIALOG_BORDER_COLOR;
        
        [self.containerView addSubview:_border];
    }
    
    return self;
}

#define MAX_RECENT_ITEMS 20

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_border setFrame:NSMakeRect(NSWidth(self.containerView.frame) - DIALOG_BORDER_WIDTH, 0, DIALOG_BORDER_WIDTH, NSHeight(self.containerView.frame))];
}



-(void)reloadItems {
    [self removeAllItems:NO];
    [self reloadData];
    
    NSArray *top = @[NSStringFromClass([TL_topPeerCategoryCorrespondents class]),NSStringFromClass([TL_topPeerCategoryBotsPM class]),NSStringFromClass([TL_topPeerCategoryGroups class]),NSStringFromClass([TL_topPeerCategoryChannels class])];
    
    
    NSMutableArray *copy = [_topCategories mutableCopy];
    
    
    
    
    [copy sortUsingComparator:^NSComparisonResult(TL_topPeerCategoryPeers*  _Nonnull obj1, TL_topPeerCategoryPeers *  _Nonnull obj2) {
        
        NSUInteger index1 = [top indexOfObject:[obj1.category className]];
        NSUInteger index2 = [top indexOfObject:[obj2.category className]];
        
        return index1 > index2 ? NSOrderedDescending : index1 < index2 ? NSOrderedAscending : NSOrderedSame;
        
    }];
    
    if(copy.count > 0 && [[copy[0] category] isKindOfClass:[TL_topPeerCategoryCorrespondents class]]) {
        TL_topPeerCategoryPeers *correspondents = copy[0];
        
        NSArray *items;
        NSArray *moreItems;
        
        if(correspondents.peers.count > 5) {
            items = [correspondents.peers subarrayWithRange:NSMakeRange(0, 5)];
            moreItems = [correspondents.peers subarrayWithRange:NSMakeRange(5, correspondents.peers.count - 5)];
        } else {
            items = correspondents.peers;
        }
        
        NSString *header = [NSString stringWithFormat:@"%@",correspondents.category.className];
        TGRecentHeaderItem *headerItem = [[TGRecentHeaderItem alloc] initWithObject:NSLocalizedString(header, nil)];
        
        
        NSMutableArray *moreConverted = [NSMutableArray array];
        
        
        TL_conversation * (^create_conversation)(id object) = ^TL_conversation *(id object) {
            
            TL_conversation *conversation;
            
            if([object isKindOfClass:[TLUser class]]) {
                conversation = [[DialogsManager sharedManager] find:[(TLUser *)object n_id]];
                if(!conversation)
                    return [[DialogsManager sharedManager] createDialogForUser:object];
            } else if([object isKindOfClass:[TLChat class]]) {
                conversation = [[DialogsManager sharedManager] find:[(TLChat *)object n_id]];
                if(!conversation)
                    return [[DialogsManager sharedManager] createDialogForChat:object];
            }
            
            return conversation;
            
        };
        
        [moreItems enumerateObjectsUsingBlock:^(TL_topPeer *peer, NSUInteger midx, BOOL * _Nonnull stop) {
            
            
            id object = [peer.peer isKindOfClass:[TL_peerUser class]] ? [[UsersManager sharedManager] find:peer.peer.user_id] : [[ChatsManager sharedManager] find:peer.peer.chat_id > 0 ? peer.peer.chat_id : peer.peer.channel_id];
            
            
            TL_conversation *conversation = create_conversation(object);
            
            if(conversation) {
                TGRecentSearchRowItem *item = [[TGRecentSearchRowItem alloc] initWithObject:conversation];
                item.disableRemoveButton = YES;
                item.disableBottomSeparator = midx == moreItems.count-1;
                
                [moreConverted addObject:item];
            }
            
        }];
        
        headerItem.otherItems = moreConverted;
        headerItem.isMore = NO;
        
        [self addItem:headerItem tableRedraw:NO];
        
        [items enumerateObjectsUsingBlock:^(TL_topPeer *peer, NSUInteger pidx, BOOL * _Nonnull stop) {
            
            id object = [peer.peer isKindOfClass:[TL_peerUser class]] ? [[UsersManager sharedManager] find:peer.peer.user_id] : [[ChatsManager sharedManager] find:peer.peer.chat_id > 0 ? peer.peer.chat_id : peer.peer.channel_id];
            
            TL_conversation *conversation = create_conversation(object);
            
            if(conversation) {
                TGRecentSearchRowItem *item = [[TGRecentSearchRowItem alloc] initWithObject:conversation];
                item.disableRemoveButton = YES;
                item.disableBottomSeparator = pidx == items.count-1;
                
                [self addItem:item tableRedraw:NO];
            }
            
            
            
        }];
        
    }
    
    
    
    if(_recentPeers.count > 0) {
        NSArray *conversations = [[Storage manager] conversationsWithIds:_recentPeers];
        conversations = [conversations sortedArrayUsingComparator:^NSComparisonResult(TL_conversation *obj1, TL_conversation *obj2) {
            
            NSNumber *idx1 = @([_recentPeers indexOfObject:@(obj1.peer_id)]);
            NSNumber *idx2 = @([_recentPeers indexOfObject:@(obj2.peer_id)]);
            
            return [idx1 compare:idx2];
            
        }];
        NSMutableArray *items = [NSMutableArray array];
        NSMutableArray *moreItems = [NSMutableArray array];
        __block int less = 0;
        [conversations enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL *stop) {
            
            if(obj.type == DialogTypeChat && obj.chat.isDeactivated)
                return;
            
            TGRecentSearchRowItem *item = [[TGRecentSearchRowItem alloc] initWithObject:obj];
            
            if(![self isItemInList:item]) {
                if (less < 5) {
                    [items addObject:item];
                } else {
                    [moreItems addObject:item];
                }
            }
            less++;
            
        }];
        
        if((self.count > 0 && items.count > 0) || moreItems.count > 0) {
            TGRecentHeaderItem *headerItem = [[TGRecentHeaderItem alloc] initWithObject:NSLocalizedString(@"Recent.Recent", nil)];
            headerItem.otherItems = moreItems;
            headerItem.isMore = NO;
        
            [self addItem:headerItem tableRedraw:NO];
        }
        
        [self insert:items startIndex:self.count tableRedraw:NO];
        
        
    }
    
    NSArray *unread = [[DialogsManager sharedManager] unreadList];
    
    if (unread.count > 0) {
        
        NSMutableArray *items = [NSMutableArray array];

        NSMutableArray *moreItems = [NSMutableArray array];
        
        TGRecentHeaderItem *headerItem = [[TGRecentHeaderItem alloc] initWithObject:NSLocalizedString(@"Recent.UnreadChats", nil)];
        [items addObject:headerItem];
        __block int less = 0;
        [unread enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL *stop) {
            TGRecentSearchRowItem *item = [[TGRecentSearchRowItem alloc] initWithObject:obj];
            item.disableRemoveButton = YES;
            if(![self isItemInList:item]) {
                if (less < 5) {
                    [items addObject:item];
                } else {
                    [moreItems addObject:item];
                }
            }
            less++;
            
        }];
        
        headerItem.otherItems = moreItems;
        headerItem.isMore = NO;
        
        
        [self insert:items startIndex:self.count tableRedraw:NO];

    }
    
    [self reloadData];
}




-(BOOL)loadRecentSearchItems:(BOOL)draw {
    
    
    
    if(![Storage isInitialized])
        return NO;
    
    
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
        
        @try {
            _recentPeers = [transaction objectForKey:@"peerIds" inCollection:RECENT_SEARCH];
            _topCategories = [transaction objectForKey:@"categories" inCollection:TOP_PEERS];
            
            
            [_topCategories enumerateObjectsUsingBlock:^(TL_topPeerCategoryPeers *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj.peers sortUsingComparator:^NSComparisonResult(TL_topPeer *obj1, TL_topPeer *obj2) {
                    return obj1.rating < obj2.rating ? NSOrderedDescending : obj1.rating > obj2.rating ? NSOrderedAscending : NSOrderedSame;
                }];
            }];
        } @catch (NSException *exception) {
            
        }
          
        
    }];
    
    [MessageSender syncTopCategories:^(NSArray *categories) {
        
        _topCategories = categories;
        
        if(draw) {
            [self reloadItems];
        }
        
    }];;
    
    _recentPeers = [_recentPeers subarrayWithRange:NSMakeRange(0, MIN(_recentPeers.count,MAX_RECENT_ITEMS))];
    
    if(draw)
        [self reloadItems];
    
    return self.count > 0;
    
}

-(BOOL)removeItem:(TGRecentSearchRowItem *)item {
    
//    
//    [RPCRequest sendRequest:[TLAPI_contacts_resetTopPeerRating createWithCategory:<#(TLTopPeerCategory *)#> peer:<#(TLInputPeer *)#>] successHandler:<#^(id request, id response)successHandler#> errorHandler:<#^(id request, RpcError *error)errorHandler#>]
    
    __block  NSMutableArray *peerIds;
    
    NSUInteger count = [self count];
    
    __block int next_peer_id = 0;
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
        
        peerIds = [transaction objectForKey:@"peerIds" inCollection:RECENT_SEARCH];
        
        [peerIds removeObject:@(item.conversation.peer_id)];
        
        [transaction setObject:peerIds forKey:@"peerIds" inCollection:RECENT_SEARCH];
        
        if(count == MAX_RECENT_ITEMS && peerIds.count >= MAX_RECENT_ITEMS) {
            next_peer_id = [peerIds[MAX_RECENT_ITEMS-1] intValue];
        }
        
    }];
    
    
    
    dispatch_block_t rm = ^{
        self.defaultAnimation = NSTableViewAnimationEffectFade;
        
        [super removeItem:item tableRedraw:YES];
        
        self.defaultAnimation = NSTableViewAnimationEffectNone;
        
        
        if(peerIds.count == 0) {
            StandartViewController *controller = (StandartViewController *) [[Telegram leftViewController] currentTabController];
            if([controller isKindOfClass:[StandartViewController class]]) {
                [(StandartViewController *)controller searchByString:@""];
            }
        }
    };
    
    
    rm();
    
    if(next_peer_id != 0) {
        
        NSArray *list = [[Storage manager] conversationsWithIds:@[@(next_peer_id)]];
        
        if(list.count == 1) {
            self.defaultAnimation = NSTableViewAnimationEffectFade;
            [self addItem:[[TGRecentSearchRowItem alloc] initWithObject:list[0]] tableRedraw:YES];
            self.defaultAnimation = NSTableViewAnimationEffectNone;
            
        }
        
    }
    return YES;
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return item.height;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}
- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [self cacheViewForClass:item.viewClass identifier:item.identifier withSize:NSMakeSize(NSWidth(self.frame), item.height)];
}
- (void)selectionDidChange:(NSInteger)row item:(TGRecentSearchRowItem *) item {
    
    if([item isKindOfClass:[TGRecentSearchRowItem class]]) {
        TL_conversation *conv = [[DialogsManager sharedManager] find:item.conversation.peer_id];
        
        if(!conv)
        {
            conv = item.conversation;
            conv.top_message = 0;
            conv.fake = YES;
            [[DialogsManager sharedManager] add:@[conv]];
        }
        
        
        [appWindow().navigationController showMessagesViewController:conv];
        [[Telegram leftViewController] resignFirstResponder];
        
    } else if([item isKindOfClass:[TGRecentHeaderItem class]]) {
        
        TGRecentHeaderItem *headerItem = (TGRecentHeaderItem *)item;
        
        if(!headerItem.isMore) {
            self.defaultAnimation = NSTableViewAnimationEffectFade;
            [self insert:[headerItem otherItems] startIndex:[self indexOfItem:item]+6 tableRedraw:YES];
            self.defaultAnimation = NSTableViewAnimationEffectNone;
            
            [[Telegram leftViewController].conversationsViewController becomeFirstResponder];
        } else {
            self.defaultAnimation = NSTableViewAnimationEffectFade;

            [headerItem.otherItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self removeItem:obj tableRedraw:YES];
            }];
            self.defaultAnimation = NSTableViewAnimationEffectNone;
        }
        
        headerItem.isMore = !headerItem.isMore;

        
        if(headerItem.otherItems.count > 0) {
            
            TGRecentSearchRowItem *last = [self itemAtPosition:[self indexOfItem:item] + 5];
            
            last.disableBottomSeparator = headerItem.isMore;
            
            [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:5] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
        
        
        [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self positionOfItem:headerItem]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
       
    }
    
}


-(BOOL)acceptsFirstResponder {
    return NO;
}


- (BOOL)selectionWillChange:(NSInteger)row item:(TGRecentSearchRowItem *) item {
    
    if([item isKindOfClass:[TGRecentSearchRowItem class]]) {
        if([[Telegram rightViewController] isModalViewActive]) {
            [[Telegram rightViewController] modalViewSendAction:item.conversation];
            return NO;
        }
    }
    
    return [item isKindOfClass:[TGRecentSearchRowItem class]] || [item isKindOfClass:[TGRecentHeaderItem class]];
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}



@end
