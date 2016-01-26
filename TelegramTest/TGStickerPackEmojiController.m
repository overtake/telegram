//
//  TGStickerPackEmojiController.m
//  Telegram
//
//  Created by keepcoder on 08.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGStickerPackEmojiController.h"
#import "EmojiViewController.h"
#import "TGAllStickersTableView.h"
#import "TGImageView.h"
#import "TGMessagesStickerImageObject.h"
#import "TGTransformScrollView.h"


@protocol TGStickerPackButtonDelegate <NSObject>
-(void)removeScrollEvent;
-(void)addScrollEvent;
-(void)didSelected:(id)button scrollToPack:(BOOL)scrollToPack selectItem:(BOOL)selectItem;

@end

@interface TGStickerPackButton : TMView
@property (nonatomic,assign,setter=setSelected:) BOOL isSelected;
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) id <TGStickerPackButtonDelegate> delegate;
@property (nonatomic,assign) long packId;
@end




@implementation TGStickerPackButton


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(2, 2, 28, 28)];
        [_imageView setCenterByView:self];
        [self addSubview:_imageView];
    }
    
    return self;
}


-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(_isSelected) {
        [LINK_COLOR set];
        
        NSRectFill(NSMakeRect(0, 0, NSWidth(dirtyRect), DIALOG_BORDER_WIDTH));
    }
    
}

-(void)setSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    
    [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)theEvent {
    
    [_delegate didSelected:self scrollToPack:YES selectItem:YES];
}

@end

@interface TGStickerPackEmojiController () <TGStickerPackButtonDelegate>
@property (nonatomic,strong) TGTransformScrollView *scrollView;
@property (nonatomic,strong) TMView *packsContainerView;
@property (nonatomic,strong) TGStickerPackButton *selectedItem;

@end

@implementation TGStickerPackEmojiController

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _scrollView = [[TGTransformScrollView alloc] initWithFrame:NSMakeRect(0, NSHeight(frameRect) - 44, NSWidth(frameRect), 44)];
        
        
        [self addSubview:_scrollView];
        
        _packsContainerView = [[TMView alloc] initWithFrame:_scrollView.bounds];
        
        weak();
        
        [_packsContainerView setDrawBlock:^{
            [DIALOG_BORDER_COLOR set];
            NSRectFill(NSMakeRect(0, 0, NSWidth(weakSelf.packsContainerView.frame), DIALOG_BORDER_WIDTH));
        }];
        
        _scrollView.documentView = _packsContainerView;
        
        
        _stickers = [[TGAllStickersTableView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect), NSHeight(frameRect) - 44)];
        
        
        [_stickers setDidNeedReload:^{
           
            [weakSelf reload:NO];
            
        }];
        
        [self addSubview:_stickers.containerView];
        
        [self addScrollEvent];
        
    }
    
    return self;
}




- (void) addScrollEvent {
    id clipView = [[_stickers enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)notify {
    
    if(NSIsEmptyRect([_stickers visibleRect]))
        return;
    
    id fItem =  [_stickers itemAtPosition:MIN([_stickers rowsInRect:[_stickers visibleRect]].location,_stickers.count-1)];
    
    long packId = [[fItem valueForKey:@"packId"] longValue];
    
    if(packId != _selectedItem.packId) {
        [_packsContainerView.subviews enumerateObjectsUsingBlock:^(TGStickerPackButton *obj, NSUInteger idx, BOOL *stop) {
            
            if(obj.packId == packId) {
                [self didSelected:obj scrollToPack:NO selectItem:YES];
                
                
                *stop = YES;
            }
            
        }];
    }
    
}

-(void)removeAllItems {
    [_stickers removeAllItems:NO];
    [_stickers reloadData];
}

-(void)reload {
    [self reload:YES];
}

-(void)reload:(BOOL)reloadStickers {
    
    if(reloadStickers)
        [_stickers load:NO];
    
    NSArray *stickers = [_stickers allStickers];
    
    NSMutableDictionary *set = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *sets = [[NSMutableArray alloc] init];
    
    [stickers enumerateObjectsUsingBlock:^(TLDocument *obj, NSUInteger idx, BOOL *stop) {
        
        TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [obj attributeWithClass:[TL_documentAttributeSticker class]];
        
        if(!set[@(attr.stickerset.n_id)]) {
            set[@(attr.stickerset.n_id)] = obj;
            [sets addObject:obj];
        }
        
    }];
    
    
    [sets sortUsingComparator:^NSComparisonResult(TL_document *obj1, TL_document *obj2) {
        
        
        NSNumber *sidx = @([_stickers.sets indexOfObjectPassingTest:^BOOL(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
            
            TL_documentAttributeSticker *sticker = (TL_documentAttributeSticker *) [obj1 attributeWithClass:[TL_documentAttributeSticker class]];
            
            return sticker.stickerset.n_id == obj.n_id;
            
        }]);
        NSNumber *oidx = @([_stickers.sets indexOfObjectPassingTest:^BOOL(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
            
            TL_documentAttributeSticker *sticker = (TL_documentAttributeSticker *) [obj2 attributeWithClass:[TL_documentAttributeSticker class]];
            
            return sticker.stickerset.n_id == obj.n_id;
            
        }]);
        
        return [sidx compare:oidx];
        
        
    }];
    
    [self drawWithStickers:sets];
    
    
    [self.stickers scrollToBeginningOfDocument:nil];
    if(_packsContainerView.subviews.count > 0 && reloadStickers)
        [self didSelected:_packsContainerView.subviews[0] scrollToPack:NO selectItem:YES];
}

-(void)drawWithStickers:(NSArray *)stickers {
    
    [_packsContainerView removeAllSubviews];
    
    if(_stickers.hasRecentStickers) {
        stickers = [@[[[NSObject alloc] init]] arrayByAddingObjectsFromArray:stickers];
    }
    
    __block int x = 0;
    
    
    float itemWidth = MAX(roundf(NSWidth(self.frame)/(stickers.count + 1)),48);
    
    [stickers enumerateObjectsUsingBlock:^(TLDocument *obj, NSUInteger idx, BOOL *stop) {
        
        TGStickerPackButton *button = [[TGStickerPackButton alloc] initWithFrame:NSMakeRect(x, 0, itemWidth, 44)];
        
        if(obj.class != [NSObject class]) {
            TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *)[obj attributeWithClass:[TL_documentAttributeSticker class]];
            
            TGMessagesStickerImageObject *imageObject = [[TGMessagesStickerImageObject alloc] initWithLocation:obj.thumb.location placeHolder:nil];
            imageObject.imageSize = strongsize(NSMakeSize(obj.thumb.w, obj.thumb.h), 28);
            
            [button.imageView setFrameSize:imageObject.imageSize];
            
            [button.imageView setCenterByView:button];
            button.packId = attr.stickerset.n_id;
            button.delegate = self;
            
             button.imageView.object = imageObject;
            
        } else {
            button.packId = -1;
            button.delegate = self;
            [button.imageView setContentMode:BTRViewContentModeCenter];
            button.imageView.image = image_emojiContainer1();
        }
        
        
        
        if(_selectedItem != nil) {
            if(_selectedItem.packId == button.packId)
                [self selectItem:button];
        } else {
            if(idx == 0)
                [self selectItem:button];
        }
        
       
        
        [_packsContainerView addSubview:button];
        
        x+=itemWidth;
        
    }];
    
    if(self.stickers.sets.count > 1) {
        TGStickerPackButton *button = [[TGStickerPackButton alloc] initWithFrame:NSMakeRect(x, 0, itemWidth, 44)];
        
        button.packId = -2;
        button.delegate = self;
        [button.imageView setContentMode:BTRViewContentModeCenter];
        button.imageView.image = image_StickerSettings();
        
        [_packsContainerView addSubview:button];
        
         x+=itemWidth;
    }
    
    
    
    
    [_packsContainerView setFrameSize:NSMakeSize(x, NSHeight(_packsContainerView.frame))];
    
}


-(void)selectItem:(TGStickerPackButton *)button {
    [_selectedItem setSelected:NO];
    _selectedItem = button;
    [_selectedItem setSelected:YES];
}

-(void)didSelected:(TGStickerPackButton *)button scrollToPack:(BOOL)scrollToPack selectItem:(BOOL)selectItem {
    
    if(button.packId == -2) {
        
        if(selectItem) {
            [self selectItem:button];
        }
        
        TGStickersSettingsViewController *settingViewController = [[TGStickersSettingsViewController alloc] initWithFrame:NSZeroRect];
        
        [[EmojiViewController instance].messagesViewController.navigationViewController pushViewController:settingViewController animated:YES];
        
        [[EmojiViewController instance] close];
        
        return;
    }
    
    [self removeScrollEvent];
    
    if(selectItem) {
        [self selectItem:button];
    }
    
    if(!NSContainsRect(_scrollView.clipView.documentVisibleRect, button.frame)) {
        [self.scrollView.clipView scrollRectToVisible:button.frame animated:selectItem && !scrollToPack];
    }
    
    
    if(scrollToPack)
        [_stickers scrollToStickerPack:button.packId];
    
     [self addScrollEvent];
}

@end
