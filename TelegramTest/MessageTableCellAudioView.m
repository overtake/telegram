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
#import "TMCircularProgress.h"
#import "MessageTableItemAudio.h"
#import "TGWaveformView.h"
#import "TGTimer.h"
#import "NSStringCategory.h"

#define OFFSET 75.0f


@interface MessageTableCellAudioView ()
@property (nonatomic,strong) TGWaveformView *waveformView;
@end

@implementation MessageTableCellAudioView


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        weak();
        
        self.playerButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 3, 38, 38)];
        [self.playerButton setBackgroundImage:image_VoicePlay() forControlState:BTRControlStateNormal];
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
        
        self.durationView = [[TMTextField alloc] initWithFrame:NSMakeRect(self.playerButton.frame.size.width + 8, 0, 100, 20)];
        [self.durationView setEnabled:NO];
        [self.durationView setBordered:NO];
        [self.durationView setEditable:NO];
        [self.durationView setDrawsBackground:NO];
        [self.durationView setStringValue:@"00:00 / 00:00"];
       
        [self.durationView setFont:TGSystemFont(12)];
        [self.durationView setTextColor:NSColorFromRGB(0xbebebe)];
        [self.containerView addSubview:self.durationView];
        [self.durationView sizeToFit];
        
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        [self setProgressStyle:TMCircularProgressLightStyle];
        [self.progressView setProgressColor:[NSColor whiteColor]];
        [self setProgressFrameSize:NSMakeSize(34, 34)];
        
        [self setProgressToView:self.playerButton];
        
       
        
        _waveformView = [[TGWaveformView alloc] initWithFrame:NSMakeRect(0, 0, 200, 32)];
        
        [self.containerView addSubview:_waveformView];
        
    }
    return self;
}


-(void)setCurrentTime:(NSTimeInterval)currentTime {
    [super setCurrentTime:currentTime];
    
    __block float duration;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^{
        duration = [globalAudioPlayer() duration];
    } synchronous:YES];
    
    if(duration == 0.0f) {
        duration = 0.01f;
    }
    
    [self setDurationTextFieldString:[NSString stringWithFormat:@"%@ / %@", [NSString durationTransformedValue:floor(self.currentTime)], self.item.duration]];
    
    _waveformView.progress = ceil((self.currentTime / duration) * 100.0f);
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
    
    [_waveformView setWaveform:item.waveform.count > 0 ? item.waveform : item.emptyWaveform];
    
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

- (void)uploadProgressHandler:(SenderItem *)item animated:(BOOL)animation {
    [super uploadProgressHandler:item animated:animation];
    _waveformView.progress = item.progress;
}

- (void)downloadProgressHandler:(DownloadItem *)item {
    [super downloadProgressHandler:item];
    _waveformView.progress = item.progress;
}



-(void)drawRect:(NSRect)dirtyRect {
    
//    if(!self.item.message.readedContent && !self.item.messageSender && (!self.item.downloadItem || self.item.downloadItem.downloadState == DownloadStateCompleted) && globalAudioPlayer().delegate != self.item) {
//        [NSColorFromRGB(0x4ba3e2) setFill];
//        
//        NSBezierPath *path = [NSBezierPath bezierPath];
//        
//        [path appendBezierPathWithRoundedRect:NSMakeRect(NSMinX(self.containerView.frame) + NSWidth(self.playerButton.frame) + 45, NSMinY(self.containerView.frame) +  NSMinY(self.durationView.frame) + 4, 6, 6) xRadius:3 yRadius:3];
//        
//        [path fill];
//    }
}

- (void)setCellState:(CellState)cellState {
    [super setCellState:cellState];

    [self.stateTextField setHidden:YES];
    
    if(cellState == CellStateDownloading || cellState == CellStateSending || cellState == CellStateNeedDownload) {
        _waveformView.defaultColor = DIALOG_BORDER_COLOR;
        _waveformView.progressColor = NSColorFromRGB(0x4ca2e0);
    }
    
    
    
    if(self.item.state == AudioStateWaitPlaying) {
        _waveformView.defaultColor = !self.item.message.readedContent ? NSColorFromRGB(0x4ca2e0) : DIALOG_BORDER_COLOR;
        _waveformView.progressColor = NSColorFromRGB(0x3dd16e);
    }
    
    if(self.item.state == AudioStatePaused || self.item.state == AudioStatePlaying) {
        _waveformView.defaultColor = DIALOG_BORDER_COLOR;
        _waveformView.progressColor = NSColorFromRGB(0x4ca2e0);
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
            [_waveformView setProgress:0];
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

-(void)mouseUp:(NSEvent *)theEvent {
    
    [super mouseUp:theEvent];
    NSPoint pos = [self.containerView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSRect rect = _waveformView.frame;
    
    rect.size.height+=6;
    rect.origin.y-=3;
    
    if(self.acceptTimeChanger) {
        self.acceptTimeChanger = NO;
        [self changeTime:pos rect:rect];
    }
    
}


-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    NSPoint pos = [self.containerView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSRect rect = _waveformView.frame;
    
    rect.size.height = 6;
    rect.origin.y-=3;
    
    self.acceptTimeChanger = NSPointInRect(pos, rect) && [globalAudioPlayer() isEqualToPath:self.item.path] && !globalAudioPlayer().isPaused;
    
    if(self.acceptTimeChanger) {
        [self changeTime:pos rect:rect];
        [self pause];
    }
}

-(void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    NSPoint pos = [self.containerView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSRect rect = _waveformView.frame;
    
    rect.size.height = 6;
    rect.origin.y-=3;
    
    if(self.acceptTimeChanger) {
        [self changeTime:pos rect:rect];
        
        [self pause];
    }
}

- (void)changeTime:(NSPoint)pos rect:(NSRect)rect {
    
    float x0 = pos.x -rect.origin.x;
    float percent = x0/rect.size.width;
    
    __block int duration;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^{
        duration = (float)[globalAudioPlayer() duration];
    } synchronous:YES];
    
    self.currentTime =  percent * [globalAudioPlayer() duration];
    
    [self play:self.currentTime];
    
    [self setNeedsDisplay:YES];
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
    [_waveformView setFrameSize:NSMakeSize(item.blockSize.width - (NSMaxX(self.playerButton.frame) + 8), 20)];
    int c = roundf((NSHeight(self.containerView.frame) - NSHeight(self.durationView.frame))/2);
    [_waveformView setFrameOrigin:NSMakePoint(NSMaxX(self.playerButton.frame) + 8, roundf((NSHeight(self.containerView.frame) - NSHeight(_waveformView.frame))/2) + 6)];
    [self.durationView setFrameOrigin:NSMakePoint(NSMaxX(self.playerButton.frame) + 6, c - NSHeight(self.durationView.frame) + 2)];
 
    if(item.state != AudioStatePlaying && item.state != AudioStatePaused)
        [self updateCellState];
    else {
        self.cellState = self.cellState;
        if(item.state != AudioStatePaused)
            [self startTimer];
    }
    
    
}

@end
