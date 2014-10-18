//
//  MessageTableCellAudioView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 24.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTablecellAudioDocumentView.h"
#import <Quartz/Quartz.h>
#import "TMMediaController.h"
#import "TGPeer+Extensions.h"
#import "TMPreviewDocumentItem.h"
#import "DownloadAudioItem.h"
#import "TMCircularProgress.h"
#import "MessageTableItemAudio.h"

#import "TGTimer.h"
#import "NSStringCategory.h"

#define OFFSET 75.0f

@interface MessageTablecellAudioDocumentView()



@end

@implementation MessageTablecellAudioDocumentView


+ (void)stop {
    [globalAudioPlayer() stop];
    [globalAudioPlayer().delegate audioPlayerDidFinishPlaying:globalAudioPlayer()];
}


static NSImage *blueBackground() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 48, 48);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGB(0x4ba3e2) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        [image unlockFocus];
    });
    return image;
}

static NSImage *grayBackground() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 48, 48);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGB(0xf2f2f2) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        [image unlockFocus];
    });
    return image;
}

static NSImage *playImage() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, image_PlayIconWhite().size.width + 5, image_PlayIconWhite().size.height+1);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        
        [image_PlayIconWhite() drawInRect:NSMakeRect(5, 0, image_PlayIconWhite().size.width, image_PlayIconWhite().size.height)];
        
        [image unlockFocus];
    });
    return image;
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        weak();
        
        self.playerButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, blueBackground().size.width, blueBackground().size.height)];
        
        [self.playerButton addBlock:^(BTRControlEvents events) {
            
            if(weakSelf.item.state == AudioStateWaitPlaying) {
                if(weakSelf.item.isset) {
                    weakSelf.currentTime = 0;
                    [weakSelf setNeedsDisplay:YES];
                    [weakSelf play:0];
                } else {
                    if([weakSelf.item canDownload])
                        [weakSelf startDownload:YES];
                }
                return;
            }
            
            if(weakSelf.item.state == AudioStatePaused) {
                weakSelf.item.state = AudioStatePlaying;
                weakSelf.cellState = weakSelf.cellState;
                [globalAudioPlayer() reset];
                [weakSelf startTimer];
                return;
            }
            
            if(weakSelf.item.state == AudioStatePlaying) {
                weakSelf.item.state = AudioStatePaused;
                weakSelf.cellState = weakSelf.cellState;
                [weakSelf.progressTimer invalidate];
                weakSelf.progressTimer = nil;
                [weakSelf pause];
                return;
            }
            
        } forControlEvents:BTRControlEventClick];
        
        [self.containerView addSubview:self.playerButton];
        
        self.durationView = [[TMTextField alloc] initWithFrame:NSMakeRect(self.playerButton.frame.size.width + 8, NSMinY(self.playerButton.frame) + NSHeight(self.playerButton.frame) - 23, 100, 20)];
        [self.durationView setEnabled:NO];
        [self.durationView setBordered:NO];
        [self.durationView setEditable:NO];
        [self.durationView setDrawsBackground:NO];
        [self.durationView setStringValue:@"00:00 / 00:00"];
        [self.durationView sizeToFit];
        [[self.durationView cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.durationView setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        [self.durationView setTextColor:DARK_BLACK];
        [self.containerView addSubview:self.durationView];
        
        self.stateTextField = [[TMTextField alloc] initWithFrame:NSZeroRect];
        [self.stateTextField setEnabled:NO];
        [self.stateTextField setBordered:NO];
        [self.stateTextField setEditable:NO];
        [self.stateTextField setDrawsBackground:NO];
        [self.stateTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        [self.stateTextField setTextColor:NSColorFromRGB(0xbebebe)];
        
        
        [self.containerView addSubview:self.stateTextField];
        
        
        [self.progressView setImage:image_DownloadIconGrey() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelGrayIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelGrayIcon() forState:TMLoaderViewStateUploading];
        
        [self setProgressStyle:TMCircularProgressLightStyle];
        
        [self setProgressToView:self.playerButton];
        
    }
    return self;
}


- (NSRect)progressRect {
    return NSMakeRect(self.containerView.frame.origin.x + self.playerButton.frame.size.width + 10, NSMinY(self.playerButton.frame) + NSHeight(self.playerButton.frame) - 27, [self progressWidth], 3);
}

-(void)setDurationTextFieldString:(NSString *)string {
    [self.durationView setStringValue:self.item.duration];
    [self.durationView setFrameSize:NSMakeSize([self progressWidth] - self.stateTextField.frame.size.width , NSHeight(self.durationView.frame))];
}

- (void)setCellState:(CellState)cellState {
    //    if(self.cellState == cellState)
    //        return;
    [super setCellState:cellState];
    

    
    [self.progressView setState:cellState];
    
    if(self.item.state == AudioStateWaitPlaying || self.item.state == AudioStatePaused || self.item.state == AudioStatePlaying) {
        [self.playerButton setBackgroundImage:blueBackground() forControlState:BTRControlStateNormal];
    } else {
        [self.playerButton setBackgroundImage:grayBackground() forControlState:BTRControlStateNormal];
    }
    
    
    
    // [self.playerButton setHidden:self.item.state != AudioStateWaitPlaying || self.item.state != AudioStatePaused || self.item.state != AudioStatePlaying];
    
    
    switch (self.item.state) {
        case AudioStateWaitPlaying:
            [self.playerButton setImage:playImage() forControlState:BTRControlStateNormal];
            break;
            
        case AudioStatePaused:
            [self.playerButton setImage:playImage() forControlState:BTRControlStateNormal];
            break;
            
        case AudioStatePlaying:
            [self.playerButton setImage:image_DownloadPauseIconWhite() forControlState:BTRControlStateNormal];
            break;
            
        default:
            [self.playerButton setImage:nil forControlState:BTRControlStateNormal];
            break;
    }
    
    
    [self setNeedsDisplay:YES];
    
}


- (void)updateCellState {
    MessageTableItemAudio *item = (MessageTableItemAudio *)self.item;
    
    
    if(item.messageSender) {
        self.item.state = AudioStateUploading;
        self.cellState = CellStateSending;
        return;
    }
    
    if(item.downloadItem && item.downloadItem.downloadState != DownloadStateCompleted && item.downloadItem.downloadState != DownloadStateWaitingStart) {
        self.item.state = item.downloadItem.downloadState == DownloadStateCanceled ? AudioStateWaitDownloading : AudioStateDownloading;
        self.cellState = item.downloadItem.downloadState == DownloadStateCanceled ? CellStateCancelled : CellStateDownloading;

        
    } else  if(![self.item isset]) {
        self.item.state = AudioStateWaitDownloading;
        self.cellState = CellStateNeedDownload;
        
    } else {
        self.item.state = AudioStateWaitPlaying;
        self.cellState = CellStateNormal;
    }
    
    
}





- (void)setItem:(MessageTableItemAudioDocument *)item {
    [super setItem:item];
    
    item.cellView = self;
    
    self.acceptTimeChanger = NO;
    
    [self updateDownloadState];
    
    
    [self setStateTextFieldString:[NSString sizeToTransformedValuePretty:self.item.size]];
    
    [self setDurationTextFieldString:item.duration];
    
    [self.stateTextField setFrameOrigin:NSMakePoint(self.durationView.frame.origin.x + self.durationView.frame.size.width, self.durationView.frame.origin.y - 2)];
    
    if(item.state != AudioStatePlaying && item.state != AudioStatePaused)
        [self updateCellState];
    else {
        self.cellState = self.cellState;
        if(item.state != AudioStatePaused)
            [self startTimer];
    }
    
    
}


@end
