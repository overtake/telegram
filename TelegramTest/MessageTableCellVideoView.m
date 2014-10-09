//
//  MessageTableCellVideoView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/13/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellVideoView.h"
#import "TMCircularProgress.h"
#import "TGTimer.h"
#import "TGPeer+Extensions.h"
#import "TMMediaController.h"
#import "TMPreviewVideoItem.h"
#import "FileUtils.h"


@implementation VideoTimeView

- (void) drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithRoundedRect:NSMakeRect(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2) xRadius:5 yRadius:5];
    
    [NSColorFromRGBWithAlpha(0x00000, 0.4) set];
    [path fill];
    
    [self.string drawAtPoint:NSMakePoint(7, 4)];
    
}

@end

@interface MessageTableCellVideoView()
@property (nonatomic, strong) BTRButton *playButton;
@property (nonatomic,strong) BTRButton *downloadButton;
@property (nonatomic, strong) VideoTimeView *videoTimeView;

@end

@implementation MessageTableCellVideoView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        weak();
        
        self.imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
        [self.imageView setRoundSize:4];
        [self.imageView setBlurRadius:60];
        [self.imageView setTapBlock:^{
            if(![weakSelf.item isset]) {
                if([weakSelf.item canDownload]) {
                    [weakSelf startDownload:NO downloadItemClass:[DownloadVideoItem class]];
                }
                
            } else {
                [weakSelf open];
            }
        }];
        [self setProgressToView:self.imageView];
        [self.containerView addSubview:self.imageView];
        
        self.playButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_VideoPlay().size.width, image_VideoPlay().size.height)];
        [self.playButton setBackgroundImage:image_VideoPlay() forControlState:BTRControlStateNormal];
      //  [self.playButton setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateNormal];
        
        [self.playButton addBlock:^(BTRControlEvents events) {
            if(![weakSelf.item isset]) {
                if([weakSelf.item canDownload]) {
                    [weakSelf startDownload:NO downloadItemClass:[DownloadVideoItem class]];
                }
            } else {
                [weakSelf open];
            }
        } forControlEvents:BTRControlEventMouseDownInside];
        [self.imageView addSubview:self.playButton];
        [self.playButton setCenterByView:self.imageView];
        [self.playButton setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
        
        self.videoTimeView = [[VideoTimeView alloc] initWithFrame:NSMakeRect(10, 10, 0, 0)];
        [self.imageView addSubview:self.videoTimeView];
        
        [self setProgressFrameSize:image_VideoPlay().size];
        
        [self setProgressStyle:TMCircularProgressDarkStyle];
    }
    return self;
}

- (void)open {
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:self.item.message.n_id media:self.item.message peer_id:self.item.message.peer_id];
    
    TMPreviewVideoItem *item = [[TMPreviewVideoItem alloc] initWithItem:previewObject];
    if(item) {
        [[TMMediaController controller] show:item];
    }
}

- (void)setCellState:(CellState)cellState {
    [super setCellState:cellState];
    
    float playAlpha = 1.0;
    
    if(cellState == CellStateSending) {
        playAlpha = 0.0f;
        
        
        
    }
    
    if(cellState == CellStateNormal) {
        
        playAlpha = 1.0f;
        
        [self.playButton setBackgroundImage:image_VideoPlay() forControlState:BTRControlStateNormal];
        [self.playButton setBackgroundImage:image_VideoPlay() forControlState:BTRControlStateHover];
    }
    
    if(cellState == CellStateDownloading) {
        
        playAlpha = 0.0f;
        
    }
    
    if(cellState == CellStateNeedDownload) {
        
        playAlpha = 1.0f;

        [self.playButton setBackgroundImage:image_Download() forControlState:BTRControlStateNormal];
        [self.playButton setBackgroundImage:nil forControlState:BTRControlStateHover];
    }
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0.1];
        [[self.playButton animator] setAlphaValue:playAlpha];
    } completionHandler:^{
        [[self.playButton animator] setHidden:playAlpha == 0.0f];
    }];
    
}


- (void) setItem:(MessageTableItemVideo *)item {
    [super setItem:item];
    
    [self updateDownloadState];
   
    
    
    [self.imageView setFrameSize:item.blockSize];
    
    self.imageView.object = item.imageObject;
    
    [self setProgressContainerVisibility:NO];
    [self updateVideoTimeView];
}




- (void)updateVideoTimeView {
    [self.videoTimeView setFrameSize:((MessageTableItemVideo *)self.item).videoTimeSize];
    [self.videoTimeView setString:((MessageTableItemVideo *)self.item).videoTimeAttributedString];
    [self.videoTimeView setNeedsDisplay:YES];
}

- (void)onStateChanged:(SenderItem *)item {
    [super onStateChanged:item];
    
    if(item == self.item.messageSender) {
        [(MessageTableItemVideo *)self.item rebuildTimeString];
        [self updateVideoTimeView];
    }
}



@end