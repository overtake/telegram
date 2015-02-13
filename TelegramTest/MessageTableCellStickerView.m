//
//  MessagetableCellStickerView.m
//  Telegram
//
//  Created by keepcoder on 18.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellStickerView.h"
#import "TGImageView.h"
@interface MessageTableCellStickerView ()
@property (nonatomic,strong) TGImageView *imageView;
@end

@implementation MessageTableCellStickerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        weak();
        
        
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

    
    [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
        [self performSelector:@selector(saveAs:) withObject:self];
    }]];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    
    return menu;
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
