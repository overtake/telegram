//
//  TGStickerPackEmojiController.m
//  Telegram
//
//  Created by keepcoder on 08.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGStickerPackEmojiController.h"
#import "TGAllStickersTableView.h"
#import "TGImageView.h"
#import "TGMessagesStickerImageObject.h"
#import "TGTransformScrollView.h"
#import "SpacemanBlocks.h"
#import "TGHorizontalTableView.h"
#import "TGModernESGViewController.h"
#import "TGGifKeyboardView.h"

@interface TGPackItem : NSObject
@property (nonatomic,strong) TGImageObject *imageObject;
@property (nonatomic,assign) long packId;
@property (nonatomic,assign) BOOL selected;
@property (nonatomic,strong) NSImage *image;
@end

@implementation TGPackItem

-(id)initWithObject:(TLDocument *)obj {
    if( self = [super init]) {
        TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *)[obj attributeWithClass:[TL_documentAttributeSticker class]];
        _packId = attr.stickerset.n_id;
        _imageObject = [[TGMessagesStickerImageObject alloc] initWithLocation:obj.thumb.location placeHolder:nil];
        _imageObject.imageSize = strongsize(NSMakeSize(obj.thumb.w, obj.thumb.h), 28);
    }
    
    return self;
}

@end


@protocol TGStickerPackButtonDelegate <NSObject>
-(void)removeScrollEvent;
-(void)addScrollEvent;
-(void)didSelected:(id)button scrollToPack:(BOOL)scrollToPack selectItem:(BOOL)selectItem disableAnimation:(BOOL)disableAnimation;

@end

@interface TGStickerPackView : PXListViewCell
@property (nonatomic,assign,setter=setSelected:) BOOL isSelected;
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) id <TGStickerPackButtonDelegate> delegate;
@property (nonatomic,strong) TMView *separator;
@property (nonatomic,strong) TGPackItem *packItem;
@end




@implementation TGStickerPackView


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

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(0, NSHeight(self.frame) - DIALOG_BORDER_WIDTH, NSWidth(self.frame), DIALOG_BORDER_WIDTH));
}


-(void)setPackItem:(TGPackItem *)packItem {
    
    _packItem = packItem;
    
    if(packItem.imageObject) {
        [self.imageView setFrameSize:packItem.imageObject.imageSize];
        [self.imageView setCenterByView:self];
        self.imageView.object = packItem.imageObject;
    } else if(packItem.image) {
        [self.imageView setFrameSize:packItem.image.size];
        [self.imageView setCenterByView:self];
        [self.imageView setImage:packItem.image];
    }
    
    [self setSelected:packItem.selected];

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
    
    [_delegate didSelected:self.packItem scrollToPack:YES selectItem:YES disableAnimation:NO];
}

@end

@interface TGStickerPackEmojiController () <TGStickerPackButtonDelegate,PXListViewDelegate> {
    SMDelayedBlockHandle _handle;
}
//@property (nonatomic,strong) TGTransformScrollView *scrollView;
//@property (nonatomic,strong) TMView *packsContainerView;
@property (nonatomic,strong) TGPackItem *selectedItem;
@property (nonatomic,strong) TGHorizontalTableView *tableView;
@property (nonatomic,strong) NSMutableArray *packs;
@property (nonatomic, strong) TGGifKeyboardView *gifContainer;


@end

@implementation TGStickerPackEmojiController

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {

       
        
        
        _packs = [NSMutableArray array];
        
        _tableView = [[TGHorizontalTableView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect), 44)];
        _tableView.delegate = self;
        
        [self addSubview:_tableView];
        
        weak();
        
        _stickers = [[TGAllStickersTableView alloc] initWithFrame:NSMakeRect(0, NSHeight(_tableView.frame), NSWidth(frameRect), NSHeight(frameRect) - 44)];
        [_stickers load:NO];
        [_stickers setDidNeedReload:^{
            [weakSelf reload:NO];
        }];
        
       [self addSubview:_stickers.containerView];
        
        _gifContainer = [[TGGifKeyboardView alloc] initWithFrame:NSMakeRect(0, NSHeight(_tableView.frame), NSWidth(frameRect), NSHeight(frameRect) - 44)];
        [self addSubview:_gifContainer];
        [_gifContainer setHidden:YES];
        
        
        [self addScrollEvent];
        
    }
    
    return self;
}

-(void)setEsgViewController:(TGModernESGViewController *)esgViewController {
    _esgViewController = esgViewController;
    _gifContainer.messagesViewController = esgViewController.messagesViewController;
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
            [_packs enumerateObjectsUsingBlock:^(TGPackItem *obj, NSUInteger idx, BOOL *stop) {
                
                if(obj.packId == packId) {
                    [self didSelected:obj scrollToPack:NO selectItem:YES disableAnimation:NO];
                    
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
    
    [_gifContainer clear];
    
   // [_packsContainerView removeAllSubviews];
    
}

-(void)reload {
    [self reload:YES];
}

-(void)reload:(BOOL)reloadStickers {
    
    
    if(!reloadStickers)
        [_packs removeAllObjects];
    
    
   if(reloadStickers) {
        id reload_block = _stickers.didNeedReload;
        [_stickers setDidNeedReload:nil];
        [_stickers reloadData];
        [_stickers setDidNeedReload:reload_block];
    }
    
    

    
    if(_packs.count == 0)
    {
        
        TGPackItem *gifpack = [[TGPackItem alloc] init];
        gifpack.packId = -3;
        gifpack.image = image_emojiContainer8();
        [_packs addObject:gifpack];
        
        if(_stickers.hasRecentStickers) {
            TGPackItem *recent = [[TGPackItem alloc] init];
            recent.packId = -1;
            recent.image = image_emojiContainer1();
            [_packs addObject:recent];
        }
        
        NSDictionary *stickers = [_stickers allStickers];
        
        [[_stickers sets] enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL *stop) {
            
            id sticker = [stickers[@(obj.n_id)] firstObject];
            
            if(sticker) {
                [_packs addObject:[[TGPackItem alloc] initWithObject:sticker]];
            }
            
        }];
        
        TGPackItem *settings = [[TGPackItem alloc] init];
        settings.packId = -2;
        settings.image = image_StickerSettings();
        [_packs addObject:settings];
    }
    
    
    
    [_tableView reloadData];
    
    
    [self.stickers scrollToBeginningOfDocument:nil];
    if(_packs.count > 0 && reloadStickers)
        [self didSelected:_packs[1] scrollToPack:NO selectItem:YES disableAnimation:YES];
    

}



-(void)selectItem:(TGPackItem *)item {
    [_selectedItem setSelected:NO];
    _selectedItem = item;
    [_selectedItem setSelected:YES];
    

}

-(void)didSelected:(TGPackItem *)packItem scrollToPack:(BOOL)scrollToPack selectItem:(BOOL)selectItem disableAnimation:(BOOL)disableAnimation {
    

    
    if(packItem.packId == -3 && _selectedItem.packId != -3)
        [_gifContainer prepareSavedGifvs];
    else if(_selectedItem.packId == -3 && packItem.packId != -3)
        [_gifContainer clear];
    
    [_gifContainer setHidden:packItem.packId != -3];
    [_stickers.containerView setHidden:packItem.packId == -3];
    
    if(selectItem) {
        
        TGStickerPackView *ocell = (TGStickerPackView *)[_tableView cellForRowAtIndex:[_packs indexOfObject:_selectedItem]];
        [ocell setSelected:NO];
        [self selectItem:packItem];
        TGStickerPackView *ncell = (TGStickerPackView *)[_tableView cellForRowAtIndex:[_packs indexOfObject:packItem]];
        [ncell setSelected:YES];
    }
    

    
    if(packItem.packId == -2) {
        
        
        [self.esgViewController forceClose];
        
        TGStickersSettingsViewController *settingViewController = [[TGStickersSettingsViewController alloc] initWithFrame:NSZeroRect];
        
        settingViewController.action = [[ComposeAction alloc] initWithBehaviorClass:NSClassFromString(@"ComposeActionStickersBehavior")];
        
        settingViewController.action.editable = YES;
        
        [self.esgViewController.messagesViewController.navigationViewController pushViewController:settingViewController animated:YES];
        

        return;
    }
    
    [self removeScrollEvent];
    
    
    

    
    void (^block)(BOOL animated) = ^(BOOL animated){
        
        NSRect prect = [_tableView rectOfRow:[_packs indexOfObject:packItem]];
        
        NSRect rect = NSMakeRect(MAX(NSMinX(prect) - (NSWidth(_tableView.frame) - NSWidth(prect))/2.0f,0), NSMinY(prect), NSWidth(_tableView.frame), NSHeight(_tableView.frame));
        [self.tableView.clipView scrollRectToVisible:rect animated:selectItem && animated completion:^(BOOL scrolled) {
           if(scrolled)
           {
               TGStickerPackView *ncell = (TGStickerPackView *)[_tableView cellForRowAtIndex:[_packs indexOfObject:packItem]];
               [ncell setSelected:YES];
           }
        }];
    };
    

    
    
    if(scrollToPack)
        [_stickers scrollToStickerPack:packItem.packId completionHandler:^{
            block(!disableAnimation);
            [self addScrollEvent];
        }];
    else {
        block(!disableAnimation);
        [self addScrollEvent];
    }
    
    
    
}

- (NSUInteger)numberOfRowsInListView:(PXListView*)aListView {
    return _packs.count;
}
- (CGFloat)listView:(PXListView*)aListView heightOfRow:(NSUInteger)row {
    return 44.0;
}
- (CGFloat)listView:(PXListView*)aListView widthOfRow:(NSUInteger)row {
    return MAX(roundf(NSWidth(self.frame)/(_packs.count + 1)),48);
}
- (PXListViewCell*)listView:(PXListView*)aListView cellForRow:(NSUInteger)row {
    
    TGStickerPackView *cell = (TGStickerPackView *) [aListView dequeueCellWithReusableIdentifier:NSStringFromClass([TGStickerPackView class])];
    
    if(!cell) {
        cell = [[TGStickerPackView alloc] initWithFrame:NSMakeRect(0, 0, [self listView:aListView widthOfRow:row], [self listView:aListView heightOfRow:row])];
    } 
    
    cell.delegate = self;
    
    [cell setPackItem:_packs[row]];
    
    return cell;
}

@end
