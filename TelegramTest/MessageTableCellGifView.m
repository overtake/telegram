//
//  MessageTableCellGifView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/4/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellGifView.h"
#import "TMGifImageView.h"
#import "ImageUtils.h"
#import "TMCircularProgress.h"
#import "MessageTableCellVideoView.h"
#import "GifAnimationLayer.h"
#import "TGImageView.h"
//#import "TelegramImageView.h"


@interface MessageTableCellGifView()

@property (nonatomic, strong) TGImageView *imageView;
@property (nonatomic, strong) GifAnimationLayer *gifAnimationLayer;
//@property (nonatomic, strong) TMGifImageView *gifImageView;
@property (nonatomic, strong) BTRButton *playButton;
@property (nonatomic, strong) BTRButton *downloadButton;
@property (nonatomic, strong) VideoTimeView *videoTimeView;
@property (nonatomic, assign) BOOL needOpenAfterDownload;

@end

@implementation MessageTableCellGifView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[TGImageView alloc] init];
        [self.imageView setFrameOrigin:NSMakePoint(0, 0)];
        [self.imageView setRoundSize:4];
        [self.imageView setBlurRadius:60];
        [self.containerView addSubview:self.imageView];
        [self setProgressToView:self.imageView];
        
        weak();
        
        __block dispatch_block_t block = ^{
            if(![weakSelf.item isset])
            {
                if([weakSelf.item canDownload]) {
                    weakSelf.needOpenAfterDownload = YES;
                    [weakSelf startDownload:NO downloadItemClass:[DownloadDocumentItem class]];
                }
                
            } else
            {
                if(!weakSelf.gifAnimationLayer.isAnimationRunning) {
                    [weakSelf playAnimation];
                } else {
                    [weakSelf animationDidStop:nil finished:YES];
                }
            }
        };

        
        [self.imageView setTapBlock:block];

        self.playButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_GIFPlay().size.width, image_GIFPlay().size.height)];
        [self.playButton setBackgroundImage:image_GIFPlay() forControlState:BTRControlStateNormal];
       // [self.playButton setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateNormal];
        [self.playButton addBlock:^(BTRControlEvents events) {
            block();
        } forControlEvents:BTRControlEventLeftClick];
        [self.playButton setCenterByView:self.imageView];
        [self.playButton setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
        [self.imageView addSubview:self.playButton];
        
        self.videoTimeView = [[VideoTimeView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
        [self.imageView addSubview:self.videoTimeView];
        
    }
    return self;
}

- (void)playAnimation {
    MessageTableItemGif *item = (MessageTableItemGif *)self.item;
    
    if([item isset]) {
        
        if(self.gifAnimationLayer) {
            [self.gifAnimationLayer removeAllAnimations];
            [self.gifAnimationLayer stopAnimating];
        } else {
            self.gifAnimationLayer = [GifAnimationLayer layer];
            [self.imageView.layer addSublayer:self.gifAnimationLayer];
        }
        [self.gifAnimationLayer setMasksToBounds:YES];
        [self.gifAnimationLayer setCornerRadius:4];
        [self.gifAnimationLayer setGifFilePath:item.path];
        [self.gifAnimationLayer setFrame:self.imageView.bounds];
        [self.gifAnimationLayer startAnimating];
        
        [self.gifAnimationLayer setOpacity:1];
        [self.gifAnimationLayer addAnimation:[TMAnimations fadeWithDuration:0.3 fromValue:0 toValue:1] forKey:@"opacity"];

        
        [self.playButton setHidden:YES];
    }
    
}

- (void)animationDidStart:(CAAnimation *)theAnimation {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.gifAnimationLayer stopAnimating];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.gifAnimationLayer.contents = nil;
    }];
    [self.gifAnimationLayer setOpacity:0];
    [self.gifAnimationLayer addAnimation:[TMAnimations fadeWithDuration:0.3 fromValue:1 toValue:0] forKey:@"opacity"];
    [CATransaction commit];
    [self.playButton setHidden:NO];
}


-(void)doAfterDownload {
    if(self.visibleRect.size.width > 0 && self.visibleRect.size.height > 0 && self.needOpenAfterDownload) {
        [self open];
    }
}

- (void)open {
    if(!self.gifAnimationLayer.isAnimationRunning) {
        [self playAnimation];
    } else {
        [self animationDidStop:nil finished:YES];
    }
}

- (void)resumeAnimation {
    [self.gifAnimationLayer resumeAnimating];
}

- (void)pauseAnimation {
    [self.gifAnimationLayer pauseAnimating];
}

- (void)setCellState:(CellState)cellState {
    [super setCellState:cellState];
    
    float playAlpha = 1.0;
    
    if(cellState == CellStateSending) {
        playAlpha = 0.0f;
    }
    
    if(cellState == CellStateNormal) {
        playAlpha = 1.0f;
        [self.playButton setBackgroundImage:image_GIFPlay() forControlState:BTRControlStateNormal];
    }
    
    if(cellState == CellStateDownloading) {
        playAlpha = 0.0f;
    }
    
    if(cellState == CellStateNeedDownload) {
        playAlpha = 1.0f;
        
        [self.playButton setBackgroundImage:image_Download() forControlState:BTRControlStateNormal];
        
    }
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0.1];
        [[self.playButton animator] setAlphaValue:playAlpha];
    } completionHandler:^{
        [[self.playButton animator] setHidden:playAlpha == 0.0f];
    }];
    
}

- (void) setItem:(MessageTableItemGif *)item {
    [super setItem:item];
    
    self.needOpenAfterDownload = NO;
    
    [self updateDownloadState];
    
    
    
    [self.gifAnimationLayer stopAnimating];
    self.gifAnimationLayer.contents = nil;

    
    [self.progressView setStyle:TMCircularProgressDarkStyle];
    
    // [self.progressView setCancelImage:image_MessageFileCancel()];
    
//    [self.gifImageView setFrameSize:item.blockSize];
//    [self.gifImageView setImage:item.cachedThumb isRounded:YES];
    
    [self.imageView setFrameSize:item.blockSize];
    
    if(item.cachedThumb) {
        [self.imageView setImage:item.cachedThumb];
    } else {
        self.imageView.object = item.imageObject;
    }
    
    
   
    [self setProgressContainerVisibility:NO];
    [self setProgressFrameSize:image_GIFPlay().size];
}



@end
