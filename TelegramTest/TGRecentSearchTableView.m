//
//  TGRecentSearchTableView.m
//  Telegram
//
//  Created by keepcoder on 14.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGRecentSearchTableView.h"
#import "TGRecentSearchRowView.h"
@interface TGRecentSearchTableView () <TMTableViewDelegate>
@property (nonatomic,strong) TMView *border;
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
    
    [_border setFrameSize:NSMakeSize(DIALOG_BORDER_WIDTH, NSHeight(self.containerView.frame))];
}

-(BOOL)loadRecentSearchItems {
    
    __block NSArray *peerIds;
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
        
        peerIds = [transaction objectForKey:@"peerIds" inCollection:RECENT_SEARCH];
        
    }];
    
    peerIds = [peerIds subarrayWithRange:NSMakeRange(0, MIN(peerIds.count,MAX_RECENT_ITEMS))];
    
    
    [self removeAllItems:NO];
    [self reloadData];
    
    [[Storage manager] conversationsWithIds:peerIds completeHandler:^(NSArray *list) {
        
        [list enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL *stop) {
            
            TGRecentSearchRowItem *item = [[TGRecentSearchRowItem alloc] initWithObject:obj];
            
            [self addItem:item tableRedraw:NO];
            
        }];
        
        [self reloadData];
        
    }];
    
    return peerIds.count > 0;
    
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
    
    if(next_peer_id != 0) {
        [[Storage manager] conversationsWithIds:@[@(next_peer_id)] completeHandler:^(NSArray *list) {
            
            rm();
            
            if(list.count == 1) {
                self.defaultAnimation = NSTableViewAnimationEffectFade;
                [self addItem:[[TGRecentSearchRowItem alloc] initWithObject:list[0]] tableRedraw:YES];
                self.defaultAnimation = NSTableViewAnimationEffectNone;
                
            }
            
        }];
    } else
        rm();
    
    
    return YES;
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return 50;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}
- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [self cacheViewForClass:[TGRecentSearchRowView class] identifier:@"TGRecentSearchRowView" withSize:NSMakeSize(NSWidth(self.frame), 50)];
}
- (void)selectionDidChange:(NSInteger)row item:(TGRecentSearchRowItem *) item {
    TL_conversation *conv = [[DialogsManager sharedManager] find:item.conversation.peer_id];
    
    if(!conv)
        conv = item.conversation;
    
    [[Telegram rightViewController] showByDialog:conv sender:self];
    
}
- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}


@end
