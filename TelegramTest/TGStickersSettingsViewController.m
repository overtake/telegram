//
//  TGStickersSettingsViewController.m
//  Telegram
//
//  Created by keepcoder on 11.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGStickersSettingsViewController.h"
#import "GeneralSettingsDescriptionRowItem.h"
#import "GeneralSettingsBlockHeaderView.h"
#import "TGImageView.h"
#import "EmojiViewController.h"
#import "TGMessagesStickerImageObject.h"
#import "TGStickerPackModalView.h"
#import "ComposeActionStickersBehavior.h"
#import "TGMovableTableView.h"



@interface TGStickerPackRowItem : TMRowItem
@property (nonatomic,strong) NSDictionary *pack;
@property (nonatomic,strong) NSAttributedString *title;
@property (nonatomic,strong) TGMessagesStickerImageObject *imageObject;
@property (nonatomic,strong) TLInputStickerSet *inputSet;
@property (nonatomic,strong) TL_stickerSet *set;
@end


@interface TGStickerPackRowView : TMRowView
@property (nonatomic,strong) TMTextField *titleField;
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TMView *imageContainerView;

@property (nonatomic,strong) BTRButton *deletePack;
@property (nonatomic,strong) NSImageView *reorderPack;
@property (nonatomic,strong) BTRButton *disablePack;


@property (nonatomic,strong) TMView *separator;

-(void)setEditable:(BOOL)editable animated:(BOOL)animated;

@property (nonatomic,weak) TGStickersSettingsViewController *controller;
@end

@interface TGStickersSettingsViewController ()<TGMovableTableDelegate>
@property (nonatomic,strong) TGMovableTableView *tableView;
@property (nonatomic,assign) BOOL needSaveOrder;

-(void)removeStickerPack:(TGStickerPackRowItem *)item;

@end


@implementation TGStickerPackRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _pack = object;
        
        NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
        
        _set = object[@"set"];
        
        NSArray *stickers = object[@"stickers"];
        
        TL_document *sticker;
        
        if(stickers.count > 0)
        {
            sticker = stickers[0];
            
            TL_documentAttributeSticker *s_attr = (TL_documentAttributeSticker *) [sticker attributeWithClass:[TL_documentAttributeSticker class]];
            
            _inputSet = s_attr.stickerset;
            
            NSImage *placeholder = [[NSImage alloc] initWithData:sticker.thumb.bytes];
            
            if(!placeholder)
                placeholder = [NSImage imageWithWebpData:sticker.thumb.bytes error:nil];
            
            _imageObject = [[TGMessagesStickerImageObject alloc] initWithLocation:sticker.thumb.location placeHolder:placeholder];
            
            _imageObject.imageSize = strongsize(NSMakeSize(sticker.thumb.w, sticker.thumb.h), 35);
        }
        
        NSRange range = [attrs appendString:_set.title withColor:TEXT_COLOR];
        
        [attrs setFont:TGSystemMediumFont(13) forRange:range];
        
        [attrs appendString:@"\n" withColor:[NSColor whiteColor]];
        
        range = [attrs appendString:[NSString stringWithFormat:NSLocalizedString(@"Stickers.StickersCount", nil),stickers.count] withColor:GRAY_TEXT_COLOR];
        
        [attrs setFont:TGSystemFont(13) forRange:range];
        
        _title = attrs;
        
    }
    
    return self;
}

-(NSUInteger)hash {
    return [[_pack[@"set"] valueForKey:@"n_id"] longValue];
}

@end



@implementation TGStickerPackRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {

        
        _titleField = [TMTextField defaultTextField];
        
        [[_titleField cell] setTruncatesLastVisibleLine:YES];
        
        [self addSubview:_titleField];
        
        _imageContainerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 35, 35)];
        
        [self addSubview:_imageContainerView];
        
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 35, 35)];
        
        [_imageContainerView addSubview:_imageView];
        
        weak();
        
        _deletePack = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ModernMenuDeleteIcon().size.width, image_ModernMenuDeleteIcon().size.height)];
        [_deletePack setImage:image_ModernMenuDeleteIcon() forControlState:BTRControlStateNormal];
        
        [_deletePack addBlock:^(BTRControlEvents events) {
            [weakSelf.controller removeStickerPack:(TGStickerPackRowItem *)[weakSelf rowItem]];
        } forControlEvents:BTRControlEventClick];
        
        [self addSubview:_deletePack];
        
        _reorderPack = imageViewWithImage(image_AudioPlayerList());
        
        [self addSubview:_reorderPack];
        
        
        _separator = [[TMView alloc] initWithFrame:NSMakeRect(30, 0, NSWidth(frameRect) - 60, DIALOG_BORDER_WIDTH)];
        _separator.backgroundColor = DIALOG_BORDER_COLOR;
        [self addSubview:_separator];

    }
    
    return self;
}


-(void)mouseDown:(NSEvent *)theEvent {
    
    TGMovableTableView *tableView = ((TGMovableTableView *)[self rowItem].table);
   
    if([self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_reorderPack.frame] && [[self rowItem] isEditable]) {
        [tableView startMoveItemAtIndex:[tableView indexOfObject:[self rowItem]]];
    } else {
        if(![[self rowItem] isEditable]) {
            [tableView.mdelegate selectionDidChange:[tableView indexOfObject:[self rowItem]] item:[self rowItem]];
        }
    }
}

-(void)redrawRow {
    [super redrawRow];
    
    TGStickerPackRowItem *item = (TGStickerPackRowItem *) [self rowItem];
    
    [_titleField setAttributedStringValue:item.title];
    
    [_titleField sizeToFit];
    
    [_titleField setCenterByView:self];
    
    [_imageView setFrameSize:item.imageObject.imageSize];
    _imageView.object = item.imageObject;
    
    [_deletePack setHidden:(item.set.flags & (1 << 2)) == (1 << 2)];
    
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_titleField setFrameOrigin:NSMakePoint(80, 8)];
    [_titleField setFrameSize:NSMakeSize(newSize.width - 140, NSHeight(_titleField.frame))];
    [_deletePack setCenteredYByView:_deletePack.superview];
    [_reorderPack setCenteredYByView:_deletePack.superview];
    [_imageContainerView setCenteredYByView:_imageContainerView.superview];
    [self updatePositionAnimated:NO];
    
}

-(void)setEditable:(BOOL)editable animated:(BOOL)animated {
    
    [self updatePositionAnimated:animated];
}


-(void)updatePositionAnimated:(BOOL)animated {
    
    TMRowItem *item = [self rowItem];
    
    id deleteView = animated ? [_deletePack animator] : _deletePack;
    id titleView = animated ?[_titleField animator] : _titleField;
    id imageView = animated ? [_imageContainerView animator] : _imageContainerView;
    id separatorView = animated ? [_separator animator] : _separator;
    id reoderView = animated ? [_reorderPack animator] : _reorderPack;
    
    int defImageX = roundf((30 -NSWidth(_imageContainerView.frame))/2) + 30;
    
    
    int defTitleX = item.isEditable ? 80  + NSWidth(_deletePack.frame) - 2: 80-2;
    
    [deleteView setFrameOrigin:NSMakePoint(item.isEditable ? 10 : - NSWidth(_deletePack.frame), NSMinY(_deletePack.frame))];
    [titleView setFrameOrigin:NSMakePoint(defTitleX , NSMinY(_titleField.frame))];
    [imageView setFrameOrigin:NSMakePoint(item.isEditable ? defImageX + NSWidth(_deletePack.frame)  : defImageX, NSMinY(_imageContainerView.frame))];
    
    [_reorderPack setFrameOrigin:NSMakePoint(NSWidth(self.frame) - 30 - NSWidth(_reorderPack.frame), roundf((NSHeight(self.frame) - NSHeight(_reorderPack.frame))/2))];
    
    [reoderView setAlphaValue:item.isEditable ? 1 : 0];
    [deleteView setAlphaValue:item.isEditable ? 1 : 0];
    
    [separatorView setFrame:NSMakeRect(defTitleX, 0, NSWidth(self.frame) - defTitleX - 30, DIALOG_BORDER_WIDTH)];
}

-(void)drawRect:(NSRect)dirtyRect {
    
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
    [_separator setHidden:self.dragInSuperView];

}

@end




@implementation TGStickersSettingsViewController


-(void)loadView {
    [super loadView];
    
    [self setCenterBarViewText:NSLocalizedString(@"Sticker.StickerSettings", nil)];
    
    _tableView = [[TGMovableTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView];
    
    _tableView.mdelegate = self;
    
    
    
}


-(void)stickersNeedFullReload:(NSNotification *)notification {
    [self reload];
}

-(void)stickersNeedReorder:(NSNotification *)notification {
    
    [self reload];
}

-(void)stickersNewPackAdded:(NSNotification *)notification {
    TL_messages_stickerSet *set = notification.userInfo[KEY_STICKERSET];
    
    TGStickerPackRowItem *item = [[TGStickerPackRowItem alloc] initWithObject:@{@"set":set.set,@"stickers":set.documents}];
    
    [_tableView insertItem:item atIndex:0];
    
}




-(void)didUpdatedEditableState {
    [super didUpdatedEditableState];
    
    [_tableView enumerateAvailableRowViewsUsingBlock:^(__kindof TMRowView *rowView, TMRowItem *rowItem, NSInteger row) {
        
        TGStickerPackRowView *view = (TGStickerPackRowView *)rowView;
        
        [rowItem setEditable:self.action.isEditable];
        
        [view setEditable:rowItem.isEditable animated:YES];
        
    }];
    
    if(!self.action.isEditable && _needSaveOrder) {
        dispatch_after_seconds(0.2, ^{
             [self saveOrder];
        });
       
    }
}

-(void)saveOrder {
    NSMutableArray *reoder = [NSMutableArray array];
    
    [_tableView enumerateAvailableRowViewsUsingBlock:^(__kindof TMRowView *rowView, TMRowItem *rowItem, NSInteger row) {
        
        TGStickerPackRowItem *item = (TGStickerPackRowItem *)rowItem;
        
        [reoder addObject:@(item.set.n_id)];
        
    }];
    
    [Notification perform:STICKERS_REORDER data:@{KEY_ORDER:reoder}];
    
    [RPCRequest sendRequest:[TLAPI_messages_reorderStickerSets createWithOrder:reoder] successHandler:^(id request, id response) {
        
        
    } errorHandler:^(id request, RpcError *error) {
        
        
        
    }];
    
    _needSaveOrder = NO;

}

-(void)viewWillAppear:(BOOL)animated {
    
    [self setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionStickersBehavior class]]];

    
    [super viewWillAppear:animated];
    
    _needSaveOrder = NO;
    
    [Notification addObserver:self selector:@selector(stickersNeedFullReload:) name:STICKERS_ALL_CHANGED];
    [Notification addObserver:self selector:@selector(stickersNeedReorder:) name:STICKERS_REORDER];
    [Notification addObserver:self selector:@selector(stickersNewPackAdded:) name:STICKERS_NEW_PACK];
    
    [self reload];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [Notification removeObserver:self];
    
    if(_needSaveOrder) {
        [self saveOrder];
    }
}

-(void)reload {
    NSMutableArray *packSets = [NSMutableArray array];
    
    NSArray *sets = [EmojiViewController allSets];
    
    
    [sets enumerateObjectsUsingBlock:^(TL_stickerSet *set, NSUInteger setIdx, BOOL * _Nonnull setStop) {
        NSDictionary *val = @{@"stickers":[EmojiViewController stickersWithId:set.n_id],@"set":set};
        
        [packSets addObject:val];
    }];
    
    
    
    [self reloadDataWithPacks:packSets];
}


-(void)reloadDataWithPacks:(NSArray *)packs {
    
    [_tableView removeAllItems];
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
 
    [packs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        TGStickerPackRowItem *item = [[TGStickerPackRowItem alloc] initWithObject:obj];
        item.editable = self.action.isEditable;
        [items addObject:item];
        
    }];
    
    
    [_tableView addItems:items];
    
    
}

-(void)removeStickerPack:(TGStickerPackRowItem *)item {
    
    
    
    confirm(appName(), [NSString stringWithFormat:NSLocalizedString(@"Stickers.RemoveStickerAlert", nil),[item.pack[@"set"] title]], ^{
        
        [self showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_messages_uninstallStickerSet createWithStickerset:item.inputSet] successHandler:^(id request, id response) {
            
            
            [_tableView removeItemAtIndex:[_tableView indexOfObject:item] animated:YES];
            
            [EmojiViewController reloadStickers];
            
            [self hideModalProgress];
            
        } errorHandler:^(id request, RpcError *error) {
            [self hideModalProgress];
        } timeout:10];
        
    }, nil);
    
}


-(void)tableViewDidChangeOrder {
    
    
    _needSaveOrder = YES;
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return  [item isKindOfClass:[GeneralSettingsBlockHeaderItem class]] ? ((GeneralSettingsBlockHeaderItem *)item).height : 50;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[GeneralSettingsBlockHeaderItem class]]) {
        return [[GeneralSettingsBlockHeaderView alloc] initWithFrame:NSZeroRect];
    }
    
    TGStickerPackRowView *view = [[TGStickerPackRowView alloc] initWithFrame:NSZeroRect];
    
    view.controller = self;
    
    return view;
}

- (void)selectionDidChange:(NSInteger)row item:(TGStickerPackRowItem *) item {
    
    if([item isKindOfClass:[TGStickerPackRowItem class]]) {
        TGStickerPackModalView *modalView = [[TGStickerPackModalView alloc] init];
       
        [modalView setStickerPack:[TL_messages_stickerSet createWithSet:item.pack[@"set"] packs:nil documents:[item.pack[@"stickers"] mutableCopy]]];
        
        [modalView show:self.view.window animated:YES];
    }
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}
- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}

@end
