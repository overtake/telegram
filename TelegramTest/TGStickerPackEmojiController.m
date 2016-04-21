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
#import "SpacemanBlocks.h"

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
@property (nonatomic,strong) TMView *separator;
@end




@implementation TGStickerPackButton


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(2, 2, 28, 28)];
        [_imageView setCenterByView:self];
        [self addSubview:_imageView];
        
        _separator = [[TMView alloc] initWithFrame:NSMakeRect(0, 2, NSWidth(frameRect), 2)];
        
        weak();
        
        [_separator setDrawBlock:^{
            if(weakSelf.isSelected) {
                [LINK_COLOR set];
                
                NSRectFill(NSMakeRect(0, 0, NSWidth(weakSelf.frame), 2));
            }
        }];
         [_separator setAlphaValue:0.0f];
        
        [self addSubview:_separator];
    }
    
    return self;
}




-(void)setSelected:(BOOL)isSelected {
    
    BOOL oldSelected = _isSelected;
    
    _isSelected = isSelected;
    
    if(oldSelected == YES && _isSelected == NO) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [[_separator animator] setAlphaValue:0.0];
        } completionHandler:^{
            [_separator setNeedsDisplay:YES];
        }];
        
    } else if(oldSelected == NO && _isSelected == YES) {
        [_separator setAlphaValue:0.0f];
        [_separator setNeedsDisplay:YES];
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [[_separator animator] setAlphaValue:1.0f];
        } completionHandler:^{
            
        }];
        
    }
   
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
    [_delegate didSelected:self scrollToPack:YES selectItem:YES];
}

@end

@interface TGStickerPackEmojiController () <TGStickerPackButtonDelegate> {
    SMDelayedBlockHandle _handle;
}
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
        
        _scrollView = [[TGTransformScrollView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect), 44)];
        
        
        [self addSubview:_scrollView];
        
        _packsContainerView = [[TMView alloc] initWithFrame:_scrollView.bounds];
        
        weak();
        
        [_packsContainerView setDrawBlock:^{
            [DIALOG_BORDER_COLOR set];
            NSRectFill(NSMakeRect(0, NSHeight(weakSelf.packsContainerView.frame) - DIALOG_BORDER_WIDTH, NSWidth(weakSelf.packsContainerView.frame), DIALOG_BORDER_WIDTH));
        }];
        
        _scrollView.documentView = _packsContainerView;
        
        
        _stickers = [[TGAllStickersTableView alloc] initWithFrame:NSMakeRect(0, NSHeight(_scrollView.frame), NSWidth(frameRect), NSHeight(frameRect) - 44)];
        
        
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

    
    @try {
        
        NSUInteger idx = MIN([_stickers rowsInRect:[_stickers visibleRect]].location,_stickers.count-1);
        
        id fItem;
        
        while (![fItem = [_stickers itemAtPosition:idx] isKindOfClass:NSClassFromString(@"TGAllStickersTableItem")] && fItem) {
            idx++;
        }
        
        
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
    @catch (NSException *exception) {
        
    }
    

    
}

-(void)removeAllItems {
    [_stickers removeAllItems:YES];
    
    [_packsContainerView removeAllSubviews];
    
}

-(void)reload {
    [self reload:YES];
}

-(void)reload:(BOOL)reloadStickers {
    

    if(reloadStickers)
        [_stickers load:NO];
    
    NSDictionary *stickers = [_stickers allStickers];

    
    NSMutableArray *sets = [[NSMutableArray alloc] init];
    
    [[_stickers sets] enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
        
        id sticker = [stickers[@(obj.n_id)] firstObject];
       
        if(sticker)
            [sets addObject:sticker];
    }];
    
    [self drawWithStickers:sets];
    
    
    [self.stickers scrollToBeginningOfDocument:nil];
    if(_packsContainerView.subviews.count > 0 && reloadStickers)
        [self didSelected:_packsContainerView.subviews[0] scrollToPack:NO selectItem:YES];
    

}

-(void)drawWithStickers:(NSArray *)stickers {
    
    [_packsContainerView removeAllSubviews];
    
    [self setSelectedItem:nil];
    
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
        button.imageView.image = image_StickerSettings();
        [button.imageView setContentMode:BTRViewContentModeCenter];
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
    
    if(self.selectedItem.packId == -2)
        return;
    
    if(button.packId == -2) {
        
        
        [self selectItem:button];
        
        [[EmojiViewController instance] close];
        
        TGStickersSettingsViewController *settingViewController = [[TGStickersSettingsViewController alloc] initWithFrame:NSZeroRect];
        
        settingViewController.action = [[ComposeAction alloc] initWithBehaviorClass:NSClassFromString(@"ComposeActionStickersBehavior")];
        
        settingViewController.action.editable = YES;
        
        [self.stickers.messagesViewController.navigationViewController pushViewController:settingViewController animated:YES];
        
        
        [self.scrollView.clipView scrollRectToVisible:NSZeroRect animated:NO];
   
        
       
        
        return;
    }
    
    [self removeScrollEvent];
    
    if(selectItem) {
        [self selectItem:button];
    }
    
//    cancel_delayed_block(_handle);
//    
//    if(_handle)
//        _handle = nil;
//    
    
    void (^block)(BOOL animated) = ^(BOOL animated){
        NSRect rect = NSMakeRect(MAX(NSMinX(button.frame) - (NSWidth(_scrollView.frame) - NSWidth(button.frame))/2.0f,0), NSMinY(button.frame), NSWidth(_scrollView.frame), NSHeight(_packsContainerView.frame));
        [self.scrollView.clipView scrollRectToVisible:rect animated:selectItem];
    };
    
    
    
    
//    _handle = perform_block_after_delay(0.01, ^{
//        _handle = nil;
//
//    });
//    
    
    
   // if(!NSContainsRect(_scrollView.clipView.documentVisibleRect, button.frame)) {
    
  //  }
    
    
    if(scrollToPack)
        [_stickers scrollToStickerPack:button.packId completionHandler:^{
            block(YES);
            [self addScrollEvent];
        }];
    else {
        block(YES);
        [self addScrollEvent];
    }
    
    
    
    
}

@end
