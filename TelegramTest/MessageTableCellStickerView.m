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
#import "TGStickerPackModalView.h"
#import "TGStickerPreviewModalView.h"
#import "TGModernESGViewController.h"
#import "SpacemanBlocks.h"
@interface MessageTableCellStickerView ()
{
    SMDelayedBlockHandle _longHandle;
}
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
    
    {
        
        TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [self.item.message.media.document attributeWithClass:TL_documentAttributeSticker.class];
        
        if(![attr.stickerset isKindOfClass:[TL_inputStickerSetEmpty class]]) {
            

            if([TGModernESGViewController setWithId:attr.stickerset.n_id] == nil) {
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


-(void)mouseDown:(NSEvent *)theEvent {
    
    if(self.isEditable)
        [super mouseDown:theEvent];
    else if(![self.containerView mouse:[self.containerView convertPoint:[theEvent locationInWindow] fromView:nil] inRect:self.imageView.frame]) {
        [super mouseDown:theEvent];
    } else {
        _longHandle = perform_block_after_delay(0.3, ^{
            
            TGStickerPreviewModalView *preview = [[TGStickerPreviewModalView alloc] init];
            
            [preview setSticker:self.item.message.media.document];
            
            [preview show:self.window animated:YES];
            
            
        });
    }
    
    
    
    
}


-(void)mouseUp:(NSEvent *)theEvent {
    
    cancel_delayed_block(_longHandle);
    
    if(self.isEditable)
        [super mouseUp:theEvent];
    else  if([self.containerView mouse:[self.containerView convertPoint:[theEvent locationInWindow] fromView:nil] inRect:self.imageView.frame] ) {
        
        if(theEvent.clickCount == 1) {
            TL_documentAttributeSticker *attr = (TL_documentAttributeSticker *) [self.item.message.media.document attributeWithClass:TL_documentAttributeSticker.class];
            
            if(![attr.stickerset isKindOfClass:[TL_inputStickerSetEmpty class]]) {
                
                NSArray *modals = [TMViewController modalsView];
                
                [modals enumerateObjectsUsingBlock:^(TGModalView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if([obj isKindOfClass:[TGStickerPackModalView class]]) {
                        [obj close:NO];
                    }
                    
                }];
                
                TL_stickerSet *set = [TGModernESGViewController setWithId:attr.stickerset.n_id];
                NSMutableArray *stickers = (NSMutableArray *) [TGModernESGViewController stickersWithId:attr.stickerset.n_id];
                if(set && stickers.count > 0) {
                    
                    TGStickerPackModalView *modalView = [[TGStickerPackModalView alloc] init];
                    
                    modalView.canSendSticker = YES;
                    [modalView setStickerPack:[TL_messages_stickerSet createWithSet:set packs:nil documents:stickers] forMessagesViewController:self.messagesViewController];

                    [modalView show:self.window animated:YES];
                } else
                    add_sticker_pack_by_name(attr.stickerset);
            }
        }

        
    }
}

-(void)setCellState:(CellState)cellState animated:(BOOL)animated {
    [super setCellState:cellState animated:animated];
    
}

- (void) setItem:(MessageTableItemSticker *)item {
    
    [super setItem:item];
    [self.imageView setFrameSize:item.blockSize];
    
    [self updateCellState:NO];
    
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
