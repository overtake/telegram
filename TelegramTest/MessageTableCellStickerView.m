//
//  MessagetableCellStickerView.m
//  Telegram
//
//  Created by keepcoder on 18.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellStickerView.h"
#import "TGImageView.h"
#import "StickersPanelView.h"
#import "EmojiViewController.h"
#import "TGStickerPackModalView.h"
@interface MessageTableCellStickerView ()
@property (nonatomic,strong) TGImageView *imageView;
@end

@implementation MessageTableCellStickerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        [self.imageView setWantsLayer:YES];
        
        [self setProgressToView:self.imageView];
        
        
        [self.containerView addSubview:self.imageView];
        
        [self setProgressStyle:TMCircularProgressDarkStyle];
        
        
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        
    }
    return self;
}


- (NSMenu *)contextMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Sticker menu"];
    
    if(![StickersPanelView hasSticker:self.item.message.media.document])
    {
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.AddCustomSticker", nil) withBlock:^(id sender) {
            [StickersPanelView addLocalSticker:[TL_outDocument createWithN_id:self.item.message.media.document.n_id access_hash:self.item.message.media.document.access_hash date:self.item.message.media.document.date mime_type:self.item.message.media.document.mime_type size:self.item.message.media.document.size thumb:self.item.message.media.document.thumb dc_id:self.item.message.media.document.dc_id file_path:@"" attributes:self.item.message.media.document.attributes]];
        }]];
        
        
    } else {
        
        TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [self.item.message.media.document attributeWithClass:TL_documentAttributeSticker.class];
        
        if(![attr.stickerset isKindOfClass:[TL_inputStickerSetEmpty class]]) {
            
           NSArray *check = [[EmojiViewController allSets] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",attr.stickerset.n_id]];
            
            if(check.count == 0) {
                [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.AddStickers", nil) withBlock:^(id sender) {
                    
                    add_sticker_pack_by_name(attr.stickerset);
                    
                }]];
            }
            
            
        }
        
        
        
    }
    
    [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
        [self performSelector:@selector(saveAs:) withObject:self];
    }]];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    
    return menu;
}



-(void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    
    if([self.containerView mouse:[self.containerView convertPoint:[theEvent locationInWindow] fromView:nil] inRect:self.imageView.frame]) {
        if([StickersPanelView hasSticker:self.item.message.media.document])
        {
            
            TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [self.item.message.media.document attributeWithClass:TL_documentAttributeSticker.class];
            
            if(![attr.stickerset isKindOfClass:[TL_inputStickerSetEmpty class]]) {
                
                TL_stickerSet *set = [EmojiViewController setWithId:attr.stickerset.n_id];
                NSMutableArray *stickers = (NSMutableArray *) [EmojiViewController stickersWithId:attr.stickerset.n_id];
                if(set && stickers.count > 0) {
                    TGStickerPackModalView *modalView = [[TGStickerPackModalView alloc] init];
                    
                    [modalView setStickerPack:[TL_messages_stickerSet createWithSet:set packs:nil documents:stickers]];
                    
                    [modalView show:self.window animated:YES];
                } else
                    add_sticker_pack_by_name(attr.stickerset);
                
                
                
            }
            
        }
    }
}

-(void)setCellState:(CellState)cellState {
    [super setCellState:cellState];
    
    [self.progressView setHidden:[self.item.message.media.document isExist]];
    
    [self.progressView setState:cellState];
    
    [self.progressView setCenterByView:self.imageView];
}

- (void) setItem:(MessageTableItemSticker *)item {
    
    
    
    [super setItem:item];
    
    
    [self.imageView setFrameSize:item.blockSize];
    
    [self updateCellState];
    
    self.imageView.object = item.imageObject;
    
    
}


-(void)setEditable:(BOOL)editable animation:(BOOL)animation
{
    [super setEditable:editable animation:animation];
    self.imageView.isNotNeedHackMouseUp = editable;
}


@end
