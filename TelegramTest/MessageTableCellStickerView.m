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
#import "TGStickerPreviewModalView.h"
@interface MessageTableCellStickerView ()
@property (nonatomic,strong) TGImageView *imageView;
@end

@implementation MessageTableCellStickerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        
        [self.containerView addSubview:self.imageView];
        
        
    }
    return self;
}


- (NSMenu *)contextMenu {
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Sticker menu"];
    
    weak();
    
    if(![StickersPanelView hasSticker:self.item.message.media.document])
    {
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.AddCustomSticker", nil) withBlock:^(id sender) {
            [StickersPanelView addLocalSticker:[TL_outDocument createWithN_id:weakSelf.item.message.media.document.n_id access_hash:weakSelf.item.message.media.document.access_hash date:weakSelf.item.message.media.document.date mime_type:weakSelf.item.message.media.document.mime_type size:weakSelf.item.message.media.document.size thumb:weakSelf.item.message.media.document.thumb dc_id:weakSelf.item.message.media.document.dc_id file_path:@"" attributes:weakSelf.item.message.media.document.attributes]];
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
        [weakSelf performSelector:@selector(saveAs:) withObject:weakSelf];
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

        TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [self.item.message.media.document attributeWithClass:TL_documentAttributeSticker.class];
        
        if(![attr.stickerset isKindOfClass:[TL_inputStickerSetEmpty class]]) {
            
            TL_stickerSet *set = [EmojiViewController setWithId:attr.stickerset.n_id];
            NSMutableArray *stickers = (NSMutableArray *) [EmojiViewController stickersWithId:attr.stickerset.n_id];
            if(set && stickers.count > 0) {
                TGStickerPackModalView *modalView = [[TGStickerPackModalView alloc] init];
                
                [modalView setStickerPack:[TL_messages_stickerSet createWithSet:set packs:nil documents:stickers]];
                modalView.canSendSticker = YES;
                [modalView show:self.window animated:YES];
            } else
                add_sticker_pack_by_name(attr.stickerset);
        }
    }
}

-(void)setCellState:(CellState)cellState {
    [super setCellState:cellState];
    
}

- (void) setItem:(MessageTableItemSticker *)item {
    
    [super setItem:item];
    [self.imageView setFrameSize:item.blockSize];
    
    [self updateCellState];
    
    self.imageView.object = item.imageObject;
  
}


-(void)setEditable:(BOOL)editable animated:(BOOL)animated
{
    [super setEditable:editable animated:animated];
    self.imageView.isNotNeedHackMouseUp = editable;
}

-(void)dealloc {
    
}


@end
