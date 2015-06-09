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
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(2, 2, 26, 26)];
        
        [self addSubview:_imageView];
    }
    
    return self;
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(!_isSelected) {
        [GRAY_BORDER_COLOR set];
        
        NSRectFill(dirtyRect);
    }
    
}

-(void)setSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    
    [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)theEvent {
    [_delegate didSelected:self scrollToPack:YES selectItem:NO];
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
        
        _scrollView = [[TGTransformScrollView alloc] initWithFrame:NSMakeRect(0, NSHeight(frameRect) - 30, NSWidth(frameRect), 30)];
        
        
        [self addSubview:_scrollView];
        
        _packsContainerView = [[TMView alloc] initWithFrame:_scrollView.bounds];
        
        _scrollView.documentView = _packsContainerView;
        
        
        _stickers = [[TGAllStickersTableView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect), NSHeight(frameRect) - 30)];
        
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

-(void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)notify {
    
    id fItem =  [_stickers itemAtPosition:MIN([_stickers rowsInRect:[_stickers visibleRect]].location+1,_stickers.count-1)];
    
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


-(void)reload {
    
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
    
    
    
    [self drawWithStickers:sets];
    
}

-(void)drawWithStickers:(NSArray *)stickers {
    
    [_packsContainerView removeAllSubviews];
    
    
    __block int x = 0;
    [_packsContainerView setFrameSize:NSMakeSize(stickers.count*30, NSHeight(_packsContainerView.frame))];
    
    
    
    [stickers enumerateObjectsUsingBlock:^(TLDocument *obj, NSUInteger idx, BOOL *stop) {
        
        
        TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *)[obj attributeWithClass:[TL_documentAttributeSticker class]];
        
        TGMessagesStickerImageObject *imageObject = [[TGMessagesStickerImageObject alloc] initWithLocation:obj.thumb.location placeHolder:nil];
        imageObject.imageSize = NSMakeSize(26, 26);
        
        TGStickerPackButton *button = [[TGStickerPackButton alloc] initWithFrame:NSMakeRect(x, 0, 30, 30)];
        button.packId = attr.stickerset.n_id;
        button.delegate = self;
        
        if(_selectedItem != nil) {
            if(_selectedItem.packId == button.packId)
                [self didSelected:button scrollToPack:NO selectItem:YES];
        } else {
            if(idx == 0)
                [self didSelected:button scrollToPack:NO selectItem: YES];
        }
        
        button.imageView.object = imageObject;
        
        [_packsContainerView addSubview:button];
        
        x+=30;
        
    }];
    
}


-(void)didSelected:(TGStickerPackButton *)button scrollToPack:(BOOL)scrollToPack selectItem:(BOOL)selectItem {
    
    if(selectItem)
    {
        [_selectedItem setSelected:NO];
        _selectedItem = button;
        [_selectedItem setSelected:YES];
    }
    
    [self.scrollView.clipView scrollRectToVisible:button.frame animated:selectItem && !scrollToPack];
    
    if(scrollToPack)
        [_stickers scrollToStickerPack:button.packId];
}

@end
