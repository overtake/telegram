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



-(int)topHash {
    __block int acc = 0;
    
    [_topCategories enumerateObjectsUsingBlock:^(TL_topPeerCategoryPeers *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [obj.peers enumerateObjectsUsingBlock:^(TL_topPeer *topPeer, NSUInteger idx, BOOL * _Nonnull stop) {
             acc = (acc * 20261) + abs(topPeer.peer.peer_id);
        }];
        
    }];
    
    return (int)(acc & 0x7FFFFFFF);
}

-(void)loadRemote {
    [RPCRequest sendRequest:[TLAPI_contacts_getTopPeers createWithFlags:(1 << 0) | (1 << 1) | (1 << 5) | (1 << 10) offset:0 limit:100 n_hash:self.topHash] successHandler:^(id request, TL_contacts_topPeers *response) {
        
        if(![response isKindOfClass:[TL_contacts_topPeersNotModified class]]) {
            [SharedManager proccessGlobalResponse:response];
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
                [transaction setObject:response.categories forKey:@"categories" inCollection:TOP_PEERS];
            }];
            
            [self reloadItems];
        }
        

        
    } errorHandler:^(id request, RpcError *error) {
        
    }];
}

-(void)reloadItems {
    [self removeAllItems:NO];
    [self reloadData];
    
    
    [_topCategories enumerateObjectsUsingBlock:^(TL_topPeerCategoryPeers *obj, NSUInteger cidx, BOOL * _Nonnull stop) {
        
        NSString *header = [NSString stringWithFormat:@"%@",obj.category.className];
        TGRecentHeaderItem *headerItem = [[TGRecentHeaderItem alloc] initWithObject:NSLocalizedString(header, nil)];
        
        [self addItem:headerItem tableRedraw:NO];
        
        
        NSArray *items;
        NSArray *moreItems;
        
        if(obj.peers.count > 3) {
            items = [obj.peers subarrayWithRange:NSMakeRange(0, 3)];
            moreItems = [obj.peers subarrayWithRange:NSMakeRange(3, obj.peers.count - 3)];
        } else {
            items = obj.peers;
        }
        
        NSMutableArray *moreConverted = [NSMutableArray array];
        
        [moreItems enumerateObjectsUsingBlock:^(TL_topPeer *peer, NSUInteger midx, BOOL * _Nonnull stop) {
            
            TL_conversation *conversation = [peer.peer isKindOfClass:[TL_peerUser class]] ? [[[UsersManager sharedManager] find:peer.peer.user_id] dialog] : [[[ChatsManager sharedManager] find:peer.peer.chat_id > 0 ? peer.peer.chat_id : peer.peer.channel_id] dialog];
            
            if(conversation) {
                TGRecentSearchRowItem *item = [[TGRecentSearchRowItem alloc] initWithObject:conversation];
                item.disableRemoveButton = YES;
                item.disableBottomSeparator = midx == moreItems.count-1;
                
                [moreConverted addObject:item];
            }
            
            
            
        }];
        
        [items enumerateObjectsUsingBlock:^(TL_topPeer *peer, NSUInteger pidx, BOOL * _Nonnull stop) {
            
            TL_conversation *conversation = [peer.peer isKindOfClass:[TL_peerUser class]] ? [[[UsersManager sharedManager] find:peer.peer.user_id] dialog] : [[[ChatsManager sharedManager] find:peer.peer.chat_id > 0 ? peer.peer.chat_id : peer.peer.channel_id] dialog];
            
            if(conversation) {
                TGRecentSearchRowItem *item = [[TGRecentSearchRowItem alloc] initWithObject:conversation];
                item.disableRemoveButton = YES;
                item.disableBottomSeparator = pidx == items.count-1 && !moreItems;
                
                [self addItem:item tableRedraw:NO];
            }
            
            
            
        }];
        
        if(moreConverted.count > 0) {
            [self addItem:[[TGRecentMoreItem alloc] initWithObject:moreConverted] tableRedraw:NO];
        }
        
        
    }];
    
    if(_recentPeers.count > 0) {
        
        
        
        NSArray *conversations = [[Storage manager] conversationsWithIds:_recentPeers];
        
        conversations = [conversations sortedArrayUsingComparator:^NSComparisonResult(TL_conversation *obj1, TL_conversation *obj2) {
            
            NSNumber *idx1 = @([_recentPeers indexOfObject:@(obj1.peer_id)]);
            NSNumber *idx2 = @([_recentPeers indexOfObject:@(obj2.peer_id)]);
            
            return [idx1 compare:idx2];
            
        }];
        NSMutableArray *items = [NSMutableArray array];
        
        [conversations enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL *stop) {
            
            if(obj.type == DialogTypeChat && obj.chat.isDeactivated)
                return;
            
            TGRecentSearchRowItem *item = [[TGRecentSearchRowItem alloc] initWithObject:obj];
            
            if(![self isItemInList:item])
                [items addObject:item];
            
        }];
        
        if(self.count > 0 && items.count > 0) {
            TGRecentHeaderItem *headerItem = [[TGRecentHeaderItem alloc] initWithObject:NSLocalizedString(@"Recent.Recent", nil)];
            
            [self addItem:headerItem tableRedraw:NO];
        }
        
        [self insert:items startIndex:self.count tableRedraw:NO];
        
        
    }
    
    [self reloadData];
}


-(BOOL)loadRecentSearchItems {
    
    [self loadRemote];
    
    if(![Storage isInitialized])
        return NO;
    
    
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
        
        _recentPeers = [transaction objectForKey:@"peerIds" inCollection:RECENT_SEARCH];
        _topCategories = [transaction objectForKey:@"categories" inCollection:TOP_PEERS];
        
    }];
    
    _recentPeers = [_recentPeers subarrayWithRange:NSMakeRange(0, MIN(_recentPeers.count,MAX_RECENT_ITEMS))];
    
    
    [self reloadItems];
    
    return self.count > 0;
    
}

-(BOOL)removeItem:(TGRecentSearchRowItem *)item {
    
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
        
    } else if([item isKindOfClass:[TGRecentMoreItem class]]) {
        
        
        self.defaultAnimation = NSTableViewAnimationEffectFade;
        [self insert:[(TGRecentMoreItem *)item otherItems] startIndex:[self indexOfItem:item] tableRedraw:YES];
        [self removeItem:item tableRedraw:YES];
        self.defaultAnimation = NSTableViewAnimationEffectNone;
        
        [[Telegram leftViewController].conversationsViewController becomeFirstResponder];
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
    
    return [item isKindOfClass:[TGRecentSearchRowItem class]] || [item isKindOfClass:[TGRecentMoreItem class]];
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}



@end
