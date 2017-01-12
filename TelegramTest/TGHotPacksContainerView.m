//
//  TGHotPacksContainerView.m
//  Telegram
//
//  Created by keepcoder on 09/09/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGHotPacksContainerView.h"
#import "TGAllStickersTableView.h"
#import "TGTextLabel.h"
#import "TGModernESGViewController.h"
#import "TGStickerPackModalView.h"
#import "TGGeneralRowItem.h"

@interface TGHotStickerPackItem : TGAllStickersTableItem
@property (nonatomic,strong) TL_stickerSet *set;
@property (nonatomic,assign) long randKey;
@property (nonatomic,assign) BOOL isUnread;

@end

@interface TGHotStickerPackView : TGAllStickerTableItemView
@property (nonatomic,strong) id<SDisposable> packDisposable;
@end


@implementation TGHotStickerPackItem

-(id)initWithObject:(NSArray *)object packId:(long)packId {
    if(self = [super initWithObject:object packId:packId]) {
        _randKey = rand_long();
    }
    
    return self;
}

-(Class)viewClass {
    return TGHotStickerPackView.class;
}

-(NSUInteger)hash {
    

    
    return self.randKey;
}

@end


@implementation TGHotStickerPackView

-(void)redrawRow {
    [super redrawRow];
    
    TGHotStickerPackItem *item = (TGHotStickerPackItem *)self.rowItem;
    
    [_packDisposable dispose];
    
    if(item.stickers.count == 1 && item.set.n_count > 1) {
        
        [[TGModernESGViewController stickersSignal:item.set progress:NO] startWithNext:^(NSArray<TL_document *> * stickers) {
            
            if(stickers.count > 1) {
                
                [item.stickers addObjectsFromArray:[stickers subarrayWithRange:NSMakeRange(1, MIN(stickers.count -1,4))]];
                
                TGAllStickersTableItem *copy = [[TGAllStickersTableItem alloc] initWithObject:item.stickers packId:item.packId];
                
                item.objects = copy.objects;
                TGHotStickerPackItem *testItem = (TGHotStickerPackItem *)self.rowItem;
                
                if(testItem.set.n_id == item.set.n_id) {
                    [self redrawRow];
                }
                
            }
            
        }];
    }
}

@end

@interface TGHotHeaderItem : TMRowItem

@property (nonatomic,strong) TL_stickerSetCovered *covered;
@property (nonatomic,assign) BOOL isUnread;
@property (nonatomic,assign) long randKey;
@property (nonatomic,strong) NSAttributedString *title;
@property (nonatomic,strong) NSAttributedString *textCount;
@property (nonatomic,strong) id <SDisposable> dispose;

@end

@interface TGHotHeaderItemView : TMRowView
@property (nonatomic,strong) TGTextLabel *textLabel;
@property (nonatomic,strong) TGTextLabel *textCount;
@property (nonatomic,strong) BTRButton *addView;
@property (nonatomic,strong) NSProgressIndicator *progress;
@property (nonatomic,strong) TMView *unreadCircle;
@end



@implementation TGHotHeaderItem

-(id)initWithObject:(TL_stickerSetCovered *)object {
    if(self = [super initWithObject:object]) {
        _covered = object;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        [attr appendString:object.set.title withColor:TEXT_COLOR];
        [attr setFont:TGSystemMediumFont(13) forRange:attr.range];
        self.title = [attr copy];
        
        NSMutableAttributedString *count = [[NSMutableAttributedString alloc] init];
        
        [count appendString:[NSString stringWithFormat:NSLocalizedString(@"Stickers.StickersCount", nil),object.set.n_count] withColor:GRAY_TEXT_COLOR];
        [count setFont:TGSystemFont(13) forRange:count.range];
        
        _textCount = [count copy];
        
        _randKey = rand_long();
    }
    
    return self;
}

-(NSUInteger)hash {
    return _randKey;
}

-(Class)viewClass {
    return [TGHotHeaderItemView class];
}

-(int)height {
    return 30;
}

@end


@implementation TGHotHeaderItemView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textLabel = [[TGTextLabel alloc] init];
        [self addSubview:_textLabel];
        
        _textCount = [[TGTextLabel alloc] init];
        [self addSubview:_textCount];
        
        _addView = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 40, 20)];
        
        [_addView setTitle:NSLocalizedString(@"Stickers.AddFeatured", nil) forControlState:BTRControlStateNormal];
        [_addView setTitleFont:TGSystemMediumFont(13) forControlState:BTRControlStateNormal];
        [_addView setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
        
        [self addSubview:_addView];
        
        [_addView addTarget:self action:@selector(performAddRequest) forControlEvents:BTRControlEventClick];
        
        
        _progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        [_progress setStyle:NSProgressIndicatorSpinningStyle];
        
        [_progress setHidden:YES];
        
        [self addSubview:_progress];
        
        _unreadCircle = [[TMView alloc] initWithFrame:NSMakeRect(10, 0, 10, 10)];
        
        [_unreadCircle setDrawBlock:^{
            
            [BLUE_COLOR set];
            NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, 10, 10) xRadius:5 yRadius:5];
            [path fill];
            
        }];
        
        [self addSubview:_unreadCircle];
        
    }
    
    return self;
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
}


-(void)performAddRequest {
    
    weak();
    
    [weakSelf.addView setHidden:YES];
    [weakSelf.progress setHidden:NO];
    [weakSelf.progress startAnimation:weakSelf];
    
    TGHotHeaderItem *item = (TGHotHeaderItem *) weakSelf.rowItem;
    
    
    void (^complete)(BOOL success)  = ^(BOOL success) {
        
        [weakSelf.addView setHidden:NO];
        [weakSelf.progress setHidden:YES];
        [weakSelf.progress stopAnimation:weakSelf];
        
        if(success) {
            NSUInteger index = [item.table indexOfItem:item];
            
            TMTableView *table = item.table;
            
            table.defaultAnimation = NSTableViewAnimationEffectFade;
            [table removeItem:item tableRedraw:YES];
            [table removeItem:[table itemAtPosition:index] tableRedraw:YES];
            table.defaultAnimation = NSTableViewAnimationEffectNone;
        }
        
       
    };
    
    
    item.dispose = [[TGModernESGViewController stickersSignal:item.covered.set] startWithNext:^(id next) {
        
        [[MessageSender addStickerPack:[TL_messages_stickerSet createWithSet:item.covered.set packs:nil documents:next]] startWithNext:^(id next) {
            
            complete([next boolValue]);
            
        }];
        
    }];
    
}


-(void)redrawRow {
    [super redrawRow];
    
    
    TGHotHeaderItem *item = (TGHotHeaderItem *)self.rowItem;
    
    [self.addView setHidden:item.dispose != nil];
    [self.progress setHidden:item.dispose == nil];

    [_unreadCircle setHidden:!item.isUnread];
    
    [_textCount setText:item.textCount maxWidth:NSWidth(self.frame) - 60];
    [_textCount setFrameOrigin:NSMakePoint(10, 0)];
    
    [_textLabel setText:item.title maxWidth:NSWidth(self.frame) - 60];
    [_textLabel setFrameOrigin:NSMakePoint(item.isUnread ? 23 : 10,  NSHeight(_textCount.frame))];
    
    [_addView setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_addView.frame) -8, 0)];
    [_addView setCenteredYByView:self];
    
    [_progress setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_progress.frame) - 18, 0)];
    [_progress setCenteredYByView:self];

    
    [_unreadCircle setFrameOrigin:NSMakePoint(10 , NSMinY(_textLabel.frame) + 3)];

}

@end


@interface TGHotPacksContainerView () <TMTableViewDelegate>
@property (nonatomic,strong) NSMutableArray *waitingUnreadItems;
@property (nonatomic,strong) id<SDisposable> waitingSignal;
@end

@implementation TGHotPacksContainerView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {

        self.tm_delegate = self;
        _waitingUnreadItems = [NSMutableArray array];
        weak();
        
        [self.scrollView setScrollWheelBlock:^{
           
            [weakSelf updateReadItems];
            
        }];
    }
    
    return self;
}


-(void)updateReadItems {
    NSRange items = [self rowsInRect:self.visibleRect];
    
    for (NSUInteger i = items.location; i < items.length + items.location; i++) {
        
        TGHotStickerPackItem *item = [self itemAtPosition:i];
        
        if([item isKindOfClass:[TGHotStickerPackItem class]]) {
            if(item.isUnread) {
                
                
                if(NSHeight([self rowViewAtRow:item.rowId makeIfNecessary:NO].visibleRect) == item.height) {
                    [_waitingUnreadItems addObject:@(item.set.n_id)];
                }
                
            }
        }
                
    }
    
    [_waitingSignal dispose];
    
    if(_waitingUnreadItems.count > 0) {
        NSMutableArray *waiting = [_waitingUnreadItems mutableCopy];
        
        SSignal *signal = [[MTNetwork instance] requestSignal:[TLAPI_messages_readFeaturedStickers createWithN_id:waiting]];
        
        _waitingSignal = [[signal delay:2.0 onQueue:[ASQueue mainQueue]] startWithNext:^(id next) {
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
                
                NSMutableArray *unread = [transaction objectForKey:@"featuredUnreadSets" inCollection:STICKERS_COLLECTION];
                [unread removeObjectsInArray:waiting];
                [transaction setObject:unread forKey:@"featuredUnreadSets" inCollection:STICKERS_COLLECTION];
                
                
            }];
            
            if(self.window && !self.isHidden) {
                [self show];
            }
            
        }];
    }
    
}

-(void)show {
    
    [self clear:NO];
    
    __block NSArray *sets;
    __block NSArray *unread;
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        sets = [transaction objectForKey:@"featuredSets" inCollection:STICKERS_COLLECTION];
        unread = [transaction objectForKey:@"featuredUnreadSets" inCollection:STICKERS_COLLECTION];
    }];
    
    [self addItem:[[TGGeneralRowItem alloc] initWithHeight:5] tableRedraw:NO];
    
    [sets enumerateObjectsUsingBlock:^(TL_stickerSetCovered *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![TGModernESGViewController setWithId:obj.set.n_id]) {

            TGHotHeaderItem *header = [[TGHotHeaderItem alloc] initWithObject:obj];
            header.isUnread = [unread indexOfObject:@(obj.set.n_id)] != NSNotFound;
            [self addItem:header tableRedraw:NO];
            
            TGHotStickerPackItem *stickerItem = [[TGHotStickerPackItem alloc] initWithObject:obj.covers.count > 0 ? obj.covers : @[obj.cover] packId:obj.set.n_id];
            stickerItem.set = (TL_stickerSet *) obj.set;
            [self addItem:stickerItem tableRedraw:NO];
            
            stickerItem.isUnread = [unread indexOfObject:@(obj.set.n_id)] != NSNotFound;
        }
        
    }];
    
    [self addItem:[[TGGeneralRowItem alloc] initWithHeight:5] tableRedraw:NO];

    
    [self reloadData];
    
    int bp =0;
}

-(void)clear:(BOOL)redraw {
    [self removeAllItems:redraw];
    [_waitingSignal dispose];
    [_waitingUnreadItems removeAllObjects];
}

-(void)clear {
    [self clear:YES];
}


- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item
{
    return item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    TGAllStickerTableItemView *view = (TGAllStickerTableItemView *) [self cacheViewForClass:item.viewClass identifier:NSStringFromClass(item.viewClass) withSize:NSMakeSize(NSWidth(self.frame), item.height)];;
    return view;
}

- (void)selectionDidChange:(NSInteger)row item:(TGHotStickerPackItem *) item {
    
    if([item isKindOfClass:[TGHotStickerPackItem class]]) {
        [[TGModernESGViewController controller] forceClose];
        
        [[TGModernESGViewController stickersSignal:item.set] startWithNext:^(id next) {
            
            TGStickerPackModalView *modalView = [[TGStickerPackModalView alloc] init];
            [modalView show:appWindow() animated:YES stickerPack:[TL_messages_stickerSet createWithSet:item.set packs:nil documents:next] messagesController:appWindow().navigationController.messagesViewController];
        }];
    } else if([item isKindOfClass:[TGHotHeaderItem class]]) {
        int bp = 0;
    }
    
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}

-(id)previewModal {
    return [NSNull null];
}

@end
