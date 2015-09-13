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
@property (nonatomic,strong) TMTextButton *removeButton;
@property (nonatomic,weak) TGStickersSettingsViewController *controller;
@end

@interface TGStickersSettingsViewController ()<TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;


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
        
        [[_titleField cell] setTruncatesLastVisibleLine:NO];
        
        [self addSubview:_titleField];
        
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 35, 35)];
        
        [self addSubview:_imageView];
        
        _removeButton = [TMTextButton standartUserProfileButtonWithTitle:NSLocalizedString(@"Remove", nil)];
        
        [_removeButton setFont:TGSystemFont(14)];
        [_removeButton setTextColor:BLUE_UI_COLOR];
        
        [_removeButton sizeToFit];
        
        weak();
        
        [_removeButton setTapBlock:^ {
            
            [weakSelf.controller removeStickerPack:(TGStickerPackRowItem *)[weakSelf rowItem]];
            
        }];
        
        [_removeButton setCenterByView:self];
        [self addSubview:_removeButton];

    }
    
    return self;
}


-(void)redrawRow {
    [super redrawRow];
    
    TGStickerPackRowItem *item = (TGStickerPackRowItem *) [self rowItem];
    
    [_titleField setAttributedStringValue:item.title];
    
    [_titleField sizeToFit];
    
    [_titleField setCenterByView:self];
    
    
   
    [_imageView setFrameSize:item.imageObject.imageSize];
    _imageView.object = item.imageObject;
    
    
    [_removeButton setHidden:(item.set.flags & (1 << 2)) == (1 << 2)];
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_removeButton setFrameOrigin:NSMakePoint(newSize.width - 100 - NSWidth(_removeButton.frame), 17)];
    [_titleField setFrameOrigin:NSMakePoint(100, 8)];
    [_imageView setFrameOrigin:NSMakePoint( roundf((50 -NSWidth(_imageView.frame))/2) + 50, 5)];
}

-(void)drawRect:(NSRect)dirtyRect {
    
    [DIALOG_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(100, 0, NSWidth(dirtyRect) - 200, DIALOG_BORDER_WIDTH));
    
}

@end




@implementation TGStickersSettingsViewController


-(void)loadView {
    [super loadView];
    
    [self setCenterBarViewText:NSLocalizedString(@"Sticker.StickerSettings", nil)];
    
    _tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    _tableView.tm_delegate = self;
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *stickers = [EmojiViewController allStickers];
    
    
    NSMutableDictionary *packs = [[NSMutableDictionary alloc] init];
    
    NSArray *sets = [EmojiViewController allSets];
    
    [stickers enumerateObjectsUsingBlock:^(TL_document *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.class == TL_document.class) {
            
            TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [obj attributeWithClass:TL_documentAttributeSticker.class];
            
            if(attr) {
                NSMutableArray *p = [packs objectForKey:@(attr.stickerset.n_id)][@"stickers"];
                
                if(!p) {
                    p = [[NSMutableArray alloc] init];
                    
                    NSArray *f = [sets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",attr.stickerset.n_id]];
                    
                    id set;
                    
                    if(f.count == 1)
                        set = f[0];
                    else
                        set = [TL_stickerSet createWithFlags:4 n_id:0 access_hash:0 title:@"Great Minds" short_name:@"" n_count:0 n_hash:0];
                    
                    [packs setObject:@{@"stickers":p,@"set":set} forKey:@(attr.stickerset.n_id)];
                }
                
                [p addObject:obj];
                
            }
            
        }
    }];
    
    [self reloadDataWithPacks:packs.allValues];
}


-(void)reloadDataWithPacks:(NSArray *)packs {
    
    [_tableView removeAllItems:YES];
    
 
    [packs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        TGStickerPackRowItem *item = [[TGStickerPackRowItem alloc] initWithObject:obj];
        
        [_tableView insert:item atIndex:_tableView.count tableRedraw:NO];
        
    }];
    
    
    GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Stickers.StickersSetDescription", nil) height:YES flipped:150];
    
    [_tableView insert:description atIndex:_tableView.count tableRedraw:NO];
    
    [_tableView reloadData];
    
}

-(void)removeStickerPack:(TGStickerPackRowItem *)item {
    
    confirm(appName(), [NSString stringWithFormat:NSLocalizedString(@"Stickers.RemoveStickerAlert", nil),[item.pack[@"set"] title]], ^{
        
        [self showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_messages_uninstallStickerSet createWithStickerset:item.inputSet] successHandler:^(id request, id response) {
            
            _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
            
            [_tableView removeItem:item];
            
            _tableView.defaultAnimation = NSTableViewAnimationEffectNone;
            
            [EmojiViewController reloadStickers];
            
            [self hideModalProgress];
            
        } errorHandler:^(id request, RpcError *error) {
            [self hideModalProgress];
        } timeout:10];
        
    }, nil);
    
}


- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return  [item isKindOfClass:[GeneralSettingsBlockHeaderItem class]] ? ((GeneralSettingsBlockHeaderItem *)item).height : 50;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[GeneralSettingsBlockHeaderItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsBlockHeaderView class] identifier:@"GeneralSettingsBlockHeaderView"];
    }
    
    TGStickerPackRowView *view = (TGStickerPackRowView *)[_tableView cacheViewForClass:[TGStickerPackRowView class] identifier:@"TGStickerPackRowView" withSize:NSMakeSize(NSWidth(self.view.frame), 42)];
    
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
