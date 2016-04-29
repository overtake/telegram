//
//  TGInlineBotHintView.m
//  Telegram
//
//  Created by keepcoder on 29/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGInlineBotHintView.h"
#import "TGHorizontalTableView.h"

@interface TGInlineTopItem : TMRowItem

@end

@implementation TGInlineTopItem

@end


@interface TGInlineTopView : PXListViewCell
@property (nonatomic,strong) TLUser *user;
@property (nonatomic,strong) TMAvatarImageView *photoView;
@end

@implementation TGInlineTopView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _photoView = [TMAvatarImageView standartHintAvatar];
        [self addSubview:_photoView];
        
        [self setCenterByView:self];
    }
    
    return self;
}

-(void)setUser:(TLUser *)user {
    _user = user;
    [_photoView setUser:user];
}

@end

@interface TGInlineBotHintView ()
@property (nonatomic,strong) TGHorizontalTableView *tableView;
@property (nonatomic,strong) NSMutableArray *list;
@end

@implementation TGInlineBotHintView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _tableView = [[TGHorizontalTableView alloc] initWithFrame:self.bounds];
        
        [self addSubview:_tableView];
    }
    
    return self;
}

-(void)showTopInlineBots:(NSArray *)peers {
    
    [_list removeAllObjects];
    [_tableView reloadData];
    
    [peers enumerateObjectsUsingBlock:^(TL_topPeer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TLUser *user = [[UsersManager sharedManager] find:obj.peer.user_id];
        
        if(user) {
            [_list addObject:user];
        }
        
    }];
    
    [_tableView reloadData];
    
}


- (NSUInteger)numberOfRowsInListView:(PXListView*)aListView {
    return _list.count;
}
- (CGFloat)listView:(PXListView*)aListView heightOfRow:(NSUInteger)row {
    return 40;
}
- (CGFloat)listView:(PXListView*)aListView widthOfRow:(NSUInteger)row {
    return 40;
}
- (PXListViewCell*)listView:(PXListView*)aListView cellForRow:(NSUInteger)row {
    
    TGInlineTopView *cell = (TGInlineTopView *) [aListView dequeueCellWithReusableIdentifier:NSStringFromClass([TGInlineTopView class])];
    
    if(!cell) {
        cell = [[TGInlineTopView alloc] initWithFrame:NSMakeRect(0, 0, [self listView:aListView widthOfRow:row], [self listView:aListView heightOfRow:row])];
    }
    
    [cell setUser:_list[row]];
    
    return cell;
}


@end
