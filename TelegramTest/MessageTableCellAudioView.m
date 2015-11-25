//
//  MessageTableCellAudioView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 24.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellAudioView.h"
#import <Quartz/Quartz.h>
#import "TMMediaController.h"
#import "TLPeer+Extensions.h"
#import "TMPreviewDocumentItem.h"
#import "DownloadAudioItem.h"
#import "TMCircularProgress.h"
#import "MessageTableItemAudio.h"

#import "TGTimer.h"
#import "NSStringCategory.h"

#define OFFSET 75.0f

@implementation MessageTableCellAudioView




- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        weak();
        
        self.playerButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 3, 37, 37)];
     //   [self.playerButton setOpacityHover:YES];
        [self.playerButton setBackgroundImage:image_VoicePlay() forControlState:BTRControlStateNormal];
    //    [self.playerButton setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateNormal];
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
        
        self.durationView = [[TMTextField alloc] initWithFrame:NSMakeRect(self.playerButton.frame.size.width + 8, 20, 100, 20)];
        [self.durationView setEnabled:NO];
        [self.durationView setBordered:NO];
        [self.durationView setEditable:NO];
        [self.durationView setDrawsBackground:NO];
        [self.durationView setStringValue:@"00:00 / 00:00"];
        [self.durationView sizeToFit];
        [self.durationView setFont:TGSystemFont(12)];
        [self.durationView setTextColor:NSColorFromRGB(0xbebebe)];
        [self.containerView addSubview:self.durationView];
        
        
        self.stateTextField = [[TMTextField alloc] initWithFrame:NSZeroRect];
        [self.stateTextField setEnabled:NO];
        [self.stateTextField setBordered:NO];
        [self.stateTextField setEditable:NO];
        [self.stateTextField setDrawsBackground:NO];
        [self.stateTextField setFont:TGSystemFont(12)];
        [self.stateTextField setTextColor:NSColorFromRGB(0xbebebe)];

        
        [self.containerView addSubview:self.stateTextField];
        
        
        
        
        [self.progressView setImage:image_DownloadIconGrey() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelGrayIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelGrayIcon() forState:TMLoaderViewStateUploading];
        
        [self setProgressStyle:TMCircularProgressLightStyle];
        
        [self setProgressFrameSize:NSMakeSize(34, 34)];
        
        [self setProgressToView:self.playerButton];
        
        
        
    }
    return self;
}


- (NSRect)progressRect {
    return NSMakeRect(self.containerView.frame.origin.x + self.playerButton.frame.size.width + 10, NSMinY(self.playerButton.frame) + NSHeight(self.playerButton.frame) - 22, [self progressWidth], 3);
}


- (void)cancelDownload {
    [super cancelDownload];

    self.item.state = AudioStateWaitDownloading;
    self.cellState = CellStateNeedDownload;
}

- (void)updateCellState {
    MessageTableItemAudio *item = (MessageTableItemAudio *)self.item;
    
    
    if(item.messageSender) {
        self.item.state = AudioStateUploading;
        [self setStateTextFieldString:[NSString stringWithFormat:NSLocalizedString(@"Audio.Uploading", nil), [NSString sizeToTransformedValuePretty:self.item.size]]];
        self.cellState = CellStateSending;
        return;
    }
    
    if(item.downloadItem && item.downloadItem.downloadState != DownloadStateCompleted && item.downloadItem.downloadState != DownloadStateWaitingStart) {
        self.item.state = item.downloadItem.downloadState == DownloadStateCanceled ? AudioStateWaitDownloading : AudioStateDownloading;
        self.cellState = item.downloadItem.downloadState == DownloadStateCanceled ? CellStateCancelled : CellStateDownloading;
        
        if(self.item.state == AudioStateDownloading) {
            [self setStateTextFieldString:[NSString stringWithFormat:NSLocalizedString(@"Audio.Downloading", nil), [NSString sizeToTransformedValuePretty:self.item.size]]];
        }
       
    } else  if(![self.item isset]) {
        self.item.state = AudioStateWaitDownloading;
        self.cellState = CellStateNeedDownload;
        
    } else {
        self.item.state = globalAudioPlayer().delegate == self.item ? (globalAudioPlayer().isPaused ? AudioStatePaused : AudioStatePlaying) : AudioStateWaitPlaying;
        self.cellState = CellStateNormal;
    }
    
    
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    if(!self.item.message.readedContent && !self.item.messageSender && (!self.item.downloadItem || self.item.downloadItem.downloadState == DownloadStateCompleted) && globalAudioPlayer().delegate != self.item) {
        [NSColorFromRGB(0x4ba3e2) setFill];
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        
        [path appendBezierPathWithRoundedRect:NSMakeRect(NSMinX(self.containerView.frame) + NSWidth(self.durationView.frame) + 3, NSMinY(self.containerView.frame) +  NSMinY(self.durationView.frame) + 4, 6, 6) xRadius:3 yRadius:3];
        
        [path fill];
    }
}

- (void)setCellState:(CellState)cellState {
//    if(self.cellState == cellState)
//        return;
    [super setCellState:cellState];
    
    if(cellState == CellStateCancelled) {
        
    }
    
    if(cellState == CellStateDownloading) {
        [self.stateTextField setHidden:NO]; 
    }
    
    if(cellState == CellStateNormal) {
       [self.stateTextField setHidden:YES];
    }
    
    if(cellState == CellStateSending) {
        [self.stateTextField setHidden:self.item.message.fwd_from_id == nil];
    }
    
    if(cellState == CellStateNeedDownload) {
        [self setStateTextFieldString:[NSString sizeToTransformedValuePretty:self.item.size]];
        [self.stateTextField setHidden:NO];
    }
    
    [self.progressView setState:cellState];
    
    if(self.item.state == AudioStateWaitPlaying || self.item.state == AudioStatePaused || self.item.state == AudioStatePlaying) {
        [self.playerButton setBackgroundImage:blueBackground() forControlState:BTRControlStateNormal];
    } else {
        [self.playerButton setBackgroundImage:grayBackground() forControlState:BTRControlStateNormal];
    }
    
    
    
    
    switch (self.item.state) {
        case AudioStateWaitPlaying:
            [self.playerButton setImage:voicePlay() forControlState:BTRControlStateNormal];
            break;
            
        case AudioStatePaused:
            [self.playerButton setImage:voicePlay() forControlState:BTRControlStateNormal];
            break;
            
        case AudioStatePlaying:
            [self.playerButton setImage:image_VoicePause() forControlState:BTRControlStateNormal];
            break;
            
        default:
            [self.playerButton setImage:nil forControlState:BTRControlStateNormal];
            break;
    }
    
    
    [self setNeedsDisplay:YES];
    
}

- (void)setStateTextFieldString:(NSString *)string {
    [self.stateTextField setHidden:NO];
    [self.stateTextField setStringValue:string];
    [self.stateTextField sizeToFit];
    [self.stateTextField setFrameOrigin:NSMakePoint(self.playerButton.frame.size.width + 10 + self.progressRect.size.width - self.stateTextField.frame.size.width, self.durationView.frame.origin.y - 2)];
}


- (NSMenu *)contextMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Audio menu"];
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    return menu;
}


- (void)setItem:(MessageTableItemAudio *)item {
    [super setItem:item];
    
    item.cellView = self;
    
    self.acceptTimeChanger = NO;
    
    [self updateDownloadState];
    
    [self.durationView setStringValue:item.duration];
    
    [self.durationView setFrameSize:NSMakeSize(80, NSHeight(self.durationView.frame))];
    
    if(item.state != AudioStatePlaying && item.state != AudioStatePaused)
        [self updateCellState];
    else {
        self.cellState = self.cellState;
        if(item.state != AudioStatePaused)
            [self startTimer];
    }
    

}

@end
