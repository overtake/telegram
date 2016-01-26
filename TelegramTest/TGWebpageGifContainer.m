//
//  TGWebpageGifContainer.m
//  Telegram
//
//  Created by keepcoder on 20.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageGifContainer.h"
#import "TGWebpageGifObject.h"
#import "TGModernAnimatedImagePlayer.h"

@interface TGWebpageGifContainer ()
@property (nonatomic,strong) TGModernAnimatedImagePlayer *animatedPlayer;
@property (nonatomic,strong) NSImageView *playImage;
@end

@implementation TGWebpageGifContainer

@synthesize loaderView = _loaderView;


static NSImage *gifPlayImage() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 48, 48);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGBWithAlpha(0x000000, 0.5) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        
        [image_PlayIconWhite() drawInRect:NSMakeRect(roundf((48 - image_PlayIconWhite().size.width)/2) + 2, roundf((48 - image_PlayIconWhite().size.height)/2) , image_PlayIconWhite().size.width, image_PlayIconWhite().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        [image unlockFocus];
    });
    return image;//image_VideoPlay();
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.playImage = imageViewWithImage(gifPlayImage());
        
        [self.imageView addSubview:self.playImage];
        
        [self.playImage setCenterByView:self.imageView];
        
    }
    
    return self;
}

-(void)setWebpage:(TGWebpageGifObject *)webpage {
    
    [super setWebpage:webpage];
    
    
    [self.descriptionField setFrame:NSMakeRect([self textX], 0, webpage.descSize.width , webpage.descSize.height )];
    
    [self.descriptionField setAttributedString:webpage.desc];
    
    
    [self.imageView setFrame:NSMakeRect(0, webpage.size.height - webpage.imageSize.height, webpage.imageSize.width, webpage.imageSize.height)];
    
    [self.playImage setCenterByView:self.imageView];
    
}


-(void)showPhoto {
    [self playAnimation];
}


- (void)playAnimation {
    
    TGWebpageGifObject *item = (TGWebpageGifObject *)self.webpage;
    
    if([item isset]) {
        
        weak();
        
        if(!self.animatedPlayer) {
            self.animatedPlayer = [[TGModernAnimatedImagePlayer alloc] initWithSize:self.imageView.frame.size path:item.path];
            [self.animatedPlayer setFrameReady:^(NSImage *image) {
                weakSelf.imageView.image = image;
            }];
            
            [self.playImage setHidden:YES];
            
            [self.animatedPlayer play];
            
        } else {
            [self animationDidStop:nil finished:YES];
        }
    } else {
        [self startDownload:YES];
    }
    
}

- (void)animationDidStart:(CAAnimation *)theAnimation {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    [self.animatedPlayer stop];
    self.animatedPlayer = nil;
    
    TGWebpageGifObject *item = (TGWebpageGifObject *)self.webpage;
    
    self.imageView.object = item.imageObject;
    [self.playImage setHidden:NO];
    
}


- (void)startDownload:(BOOL)cancel {
    
    TGWebpageGifObject *item = (TGWebpageGifObject *)self.webpage;
    
    [item startDownload:cancel force:YES];
    
    [self updateDownloadState];
}


-(void)updateDownloadState {
    
    weak();
    
    TGWebpageGifObject *item = (TGWebpageGifObject *)self.webpage;
    
    if(item.downloadItem) {
        
        
        [item.downloadListener setCompleteHandler:^(DownloadItem * item) {
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                
                [weakSelf downloadProgressHandler:item];
                
                dispatch_after_seconds(0.2, ^{
                    weakSelf.item.downloadItem = nil;
                    [self updateState:0];
                });
            }];
            
        }];
        
        [item.downloadListener setProgressHandler:^(DownloadItem * item) {
            
            [ASQueue dispatchOnMainQueue:^{
                [weakSelf downloadProgressHandler:item];
            }];
        }];
        
        [self updateState:TMLoaderViewStateDownloading];
        
    }
    
}

-(void)updateState:(TMLoaderViewState)state {
    
    TGWebpageGifObject *item = (TGWebpageGifObject *)self.webpage;
    
    
    [self.playImage setHidden:item.downloadItem != nil && item.downloadItem.downloadState != DownloadStateCompleted];
    
    if(!item.isset && item.downloadItem && item.downloadItem.downloadState != DownloadStateCompleted) {
        [self.loaderView removeFromSuperview];
        
        _loaderView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        
        [self.loaderView setStyle:TMCircularProgressDarkStyle];
        
        
        [self.imageView addSubview:self.loaderView];
        [self.loaderView setCenterByView:self.imageView];
        
        [self.loaderView setState:state];
        
        [self.loaderView setProgress:item.downloadItem.progress animated:NO];
        
        if(self.loaderView.currentProgress > 0) {
            [self.loaderView setProgress:self.loaderView.currentProgress animated:YES];
        }
        
        
        
    } else  {
        [self.loaderView removeFromSuperview];
    }
    
}

-(void)downloadProgressHandler:(DownloadItem *)item {
    [self.loaderView setProgress:item.progress animated:YES];
}

@end
