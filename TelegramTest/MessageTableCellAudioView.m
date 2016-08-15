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
#import "TGAudioPlayerWindow.h"
#import "TGTextLabel.h"
#import "AudioHistoryFilter.h"
@interface MessageTableCellAudioView ()<TGAudioPlayerGlobalDelegate>
@property (nonatomic,strong) TGWaveformView *waveformView;


@property (nonatomic, strong) BTRButton *playView;
@property (nonatomic, strong) TGTextLabel *durationView;
@property (nonatomic, assign) BOOL needPlayAfterDownload;
@property (nonatomic, strong) TGTimer *progressTimer;
@property (nonatomic, assign) float progress;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) BOOL acceptTimeChanger;


@end

@implementation MessageTableCellAudioView


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
       // self.containerView.isFlipped = YES;
        
        weak();
        
        _playView = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
        [_playView setBackgroundImage:image_VoicePlay() forControlState:BTRControlStateNormal];
        [_playView addBlock:^(BTRControlEvents events) {
            
            if(weakSelf.audioItem.state == TGAudioPlayerGlobalStateWaitPlaying) {
                if(weakSelf.item.isset) {
                    
                    [weakSelf.controller hide];
                    
                    TGAudioGlobalController *global = [[TGAudioGlobalController alloc] init];
                    global.filterClass = [AudioHistoryFilter class];
                    [global setReversed:YES];
                    
                    [global addEventListener:weakSelf];
                    
                    [weakSelf.messagesViewController.navigationViewController showInlinePlayer:global];
                    
                    [global show:weakSelf.item.message.conversation navigation:weakSelf.messagesViewController.navigationViewController currentItem:[[MessageTableItemAudioDocument alloc] initWithObject:weakSelf.item.message]];

                    
                } else {
                    [weakSelf checkOperation];
                }
                return;
            }
            if(weakSelf.audioItem.state == TGAudioPlayerGlobalStatePaused || weakSelf.audioItem.state == TGAudioPlayerGlobalStatePlaying) {
                
                [weakSelf.controller playOrPause];
                
                return;
            }
           
        } forControlEvents:BTRControlEventClick];

        [self.containerView addSubview:_playView];
        
        self.durationView = [[TGTextLabel alloc] init];
       
        [self.containerView addSubview:self.durationView];
        
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        [self setProgressStyle:TMCircularProgressLightStyle];
        [self.progressView setProgressColor:[NSColor whiteColor]];
        
        [self setProgressToView:_playView];
        
       
        
        _waveformView = [[TGWaveformView alloc] initWithFrame:NSMakeRect(0, 0, 200, 32)];
        
        [self.containerView addSubview:_waveformView];
        
        
        
        [self.containerView setDrawBlock:^{
           
            if(!self.item.message.readedContent && !weakSelf.item.messageSender && (!weakSelf.item.downloadItem || weakSelf.item.downloadItem.downloadState == DownloadStateCompleted) && globalAudioPlayer().delegate != weakSelf.audioItem && !weakSelf.item.message.chat.isChannel) {
                [BLUE_COLOR setFill];
                
                NSBezierPath *path = [NSBezierPath bezierPath];
                
                NSRect rect = NSMakeRect(NSWidth(_playView.frame) + NSWidth(weakSelf.durationView.frame) + self.item.defaultOffset + 3,  NSMinY(weakSelf.durationView.frame) + (NSHeight(weakSelf.durationView.frame)/2) -3, 6, 6);
                
                [path appendBezierPathWithRoundedRect:rect xRadius:3 yRadius:3];
                
                [path fill];
            }
            
        }];
        
    }
    return self;
}


-(void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    
    __block float duration;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^{
        duration = [globalAudioPlayer() duration];
    } synchronous:YES];
    
    if(duration == 0.0f) {
        duration = 0.01f;
    }
    
    MessageTableItemAudio *item = (MessageTableItemAudio *)self.item;
    
    ;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:[NSString stringWithFormat:@"%@ / %@", [NSString durationTransformedValue:floor(self.currentTime)], item.duration.string] withColor:GRAY_TEXT_COLOR];
    [attr setFont:TGSystemFont(12) forRange:attr.range];
    
    [self setDurationTextFieldString:attr];
    
    
    _waveformView.progress = ceil((self.currentTime / duration) * 100.0f);
    
}


- (void)cancelDownload {
    [super cancelDownload];

    self.audioItem.state = TGAudioPlayerGlobalStatePaused;
    self.cellState = CellStateNeedDownload;
}

-(TGAudioGlobalController *)controller {
    return [TGAudioGlobalController globalController:self.messagesViewController.navigationViewController];
}

-(MessageTableItemAudioDocument *)currentItem {
    return self.controller.currentItem.message.channelMsgId == self.item.message.channelMsgId ? self.controller.currentItem : nil;
}

- (void)updateCellState:(BOOL)animated {
    
    MessageTableItemAudio *item = (MessageTableItemAudio *)self.item;
    
    
    [_waveformView setWaveform:item.waveform.count > 0 ? item.waveform : item.emptyWaveform];
    
    if(item.messageSender) {
        self.audioItem.state = TGAudioPlayerGlobalStateWaitPlaying;
        [self setCellState:CellStateSending animated:animated];
        return;
    }
    
    if(item.downloadItem && item.downloadItem.downloadState != DownloadStateCompleted && item.downloadItem.downloadState != DownloadStateWaitingStart) {
        [self setCellState:item.downloadItem.downloadState == DownloadStateCanceled ? CellStateCancelled : CellStateDownloading animated:animated];
        
       
    } else  if(![self.item isset]) {
        self.audioItem.state = TGAudioPlayerGlobalStateWaitPlaying;
        [self setCellState:CellStateNeedDownload animated:animated];
    } else {
        self.audioItem.state = self.currentItem ? self.currentItem.state : TGAudioPlayerGlobalStateWaitPlaying;
        self.cellState = CellStateNormal;
        [self setCellState:CellStateNormal animated:animated];
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




- (void)setCellState:(CellState)cellState animated:(BOOL)animated  {
    [super setCellState:cellState animated:animated];
    
    
    if(cellState == CellStateDownloading || cellState == CellStateSending || cellState == CellStateNeedDownload) {
        _waveformView.defaultColor = NSColorFromRGB(0xced9e0);
        _waveformView.progressColor = !self.item.message.chat.isChannel ? NSColorFromRGB(0x4ca2e0) : NSColorFromRGB(0xced9e0);
    }
    
    if(self.audioItem.state == TGAudioPlayerGlobalStatePaused) {
        _waveformView.defaultColor = !self.item.message.readedContent && !self.item.message.chat.isChannel ? NSColorFromRGB(0x4ca2e0) : NSColorFromRGB(0xced9e0);
        _waveformView.progressColor = NSColorFromRGB(0x4ca2e0);
    }
    
    if(self.audioItem.state == TGAudioPlayerGlobalStatePaused || self.audioItem.state == TGAudioPlayerGlobalStatePlaying) {
        _waveformView.defaultColor = NSColorFromRGB(0xced9e0);;
        _waveformView.progressColor = NSColorFromRGB(0x4ca2e0);
    }
    
        
    if(self.audioItem.state == TGAudioPlayerGlobalStateWaitPlaying || self.audioItem.state == TGAudioPlayerGlobalStatePaused || self.audioItem.state == TGAudioPlayerGlobalStatePlaying) {
        [_playView setBackgroundImage:blue_circle_background_image() forControlState:BTRControlStateNormal];
    } else {
        [_playView setBackgroundImage:blue_circle_background_image() forControlState:BTRControlStateNormal];
    }
    
    [_playView setImage:nil forControlState:BTRControlStateNormal];
    
    if(cellState == CellStateNormal) {
        switch (self.audioItem.state) {
            case TGAudioPlayerGlobalStateWaitPlaying:
                [_playView setImage:voice_play_image() forControlState:BTRControlStateNormal];
                [self.waveformView setProgress:0];
                break;
                
            case TGAudioPlayerGlobalStatePaused:
                [_playView setImage:voice_play_image() forControlState:BTRControlStateNormal];
                break;
                
            case TGAudioPlayerGlobalStatePlaying:
                [_playView setImage:image_VoicePause() forControlState:BTRControlStateNormal];
                break;
                
            default:
                [_playView setImage:nil forControlState:BTRControlStateNormal];
                break;
        }
    }
    
    [self.containerView setNeedsDisplay:YES];
    [self setNeedsDisplay:YES];
    
}

-(void)mouseUp:(NSEvent *)theEvent {
    
    [super mouseUp:theEvent];
    NSPoint pos = [self.containerView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSRect rect = _waveformView.frame;
    
    
    if(self.acceptTimeChanger) {
        self.acceptTimeChanger = NO;
        [self changeTime:pos rect:rect];
      //  [self play:self.currentTime];
    }
    
}


-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    NSPoint pos = [self.containerView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSRect rect = _waveformView.frame;
    
    self.acceptTimeChanger = NSPointInRect(pos, rect) && [globalAudioPlayer() isEqualToPath:self.item.path] && !globalAudioPlayer().isPaused;
    
    if(self.acceptTimeChanger) {
        [self changeTime:pos rect:rect];
       // [self pause];
    }
}

-(void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    
    NSPoint pos = [self.containerView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    
    if(pos.x > NSMinX(_waveformView.frame)) {
        NSRect rect = _waveformView.frame;
        
        if(self.acceptTimeChanger) {
            
            [self changeTime:pos rect:rect];
            
        }
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
    
    [self.controller addEventListener:self];
    
    self.acceptTimeChanger = NO;
    
    [self updateDownloadState:NO];
    
    
    [self.durationView setText:item.duration maxWidth:self.maxContentWidth];
    
    
    [_waveformView setFrameSize:NSMakeSize(150, 16)];
    
    int c = roundf((NSHeight(self.containerView.frame) - NSHeight(self.durationView.frame))/2);
    
    [_waveformView setFrameOrigin:NSMakePoint(NSMaxX(_playView.frame) + item.defaultOffset,   item.defaultContentOffset )];
    [self.durationView setFrameOrigin:NSMakePoint(NSMaxX(_playView.frame) + item.defaultOffset, item.defaultContentOffset + NSHeight(_waveformView.frame) + item.defaultContentOffset)];
 
    if(item.state != TGAudioPlayerGlobalStatePlaying && item.state != TGAudioPlayerGlobalStatePaused)
        [self updateCellState:NO];
    else {
        self.cellState = self.cellState;
    }
    
}

-(void)playerDidChangedState:(MessageTableItemAudioDocument *)item playerState:(TGAudioPlayerGlobalState)state {
    [self updateCellState:YES];
    
    if(item.message.n_id == self.item.message.n_id) {
        [self.audioItem tryReadContent];
    }
    
}
-(void)playerDidChangeItem:(MessageTableItemAudioDocument *)item {
    [self updateCellState:YES];
}
-(void)playerDidChangeTime:(NSTimeInterval)currentTime {
    
    if(self.currentItem.message.n_id == self.item.message.n_id) {
        self.currentTime = currentTime;
    }
}

-(void)dealloc {
    [self.controller removeEventListener:self];
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
    [super _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    if(!anim)
        _durationView.backgroundColor = color;
    else
        [_durationView pop_addAnimation:anim forKey:@"background"];
}


-(int)maxContentWidth {
    return self.item.blockSize.width - (NSMaxX(_playView.frame) + self.item.defaultOffset);
}

-(void)setDurationTextFieldString:(NSAttributedString *)string {
    [self.durationView setText:string maxWidth:self.maxContentWidth];
}


//
//-(void)play:(NSTimeInterval)fromPosition {
//    
//    [TGAudioPlayerWindow pause];
//    
//    [globalAudioPlayer() stop];
//    [globalAudioPlayer().delegate audioPlayerDidFinishPlaying:globalAudioPlayer()];
//    setGlobalAudioPlayer([TGAudioPlayer audioPlayerForPath:[self.item path]]);
//    
//    if(globalAudioPlayer()) {
//        [globalAudioPlayer() setDelegate:self.audioItem];
//        [globalAudioPlayer() playFromPosition:fromPosition];
//        
//        self.audioItem.state = TGAudioPlayerGlobalStatePlaying;
//        self.cellState = self.cellState;
//        [self startTimer];
//    }
//}
//
//- (void)pause {
//    [globalAudioPlayer() pause];
//    
//    [self.progressTimer invalidate];
//    self.progressTimer = nil;
//}
//
//- (void)startTimer {
//    if(!self.progressTimer) {
//        self.progressTimer = [[TGTimer alloc] initWithTimeout:1.0f/60.0f repeat:YES completion:^{
//            
//            if(self.audioItem.state != TGAudioPlayerGlobalStatePlaying) {
//                [self.progressTimer invalidate];
//                self.progressTimer = nil;
//            }
//            
//            self.currentTime = [globalAudioPlayer() currentPositionSync:YES];
//            
//            if(self.currentTime > 0.0f) {
//                [self setNeedsDisplay:YES];
//            }
//            
//        } queue:dispatch_get_current_queue()];
//        
//        [self.progressTimer start];
//    }
//}
//
//- (void)stopPlayer {
//    [self.progressTimer invalidate];
//    self.progressTimer = nil;
//    setGlobalAudioPlayer(nil);
//    [self setDurationTextFieldString:self.audioItem.duration];
//    self.audioItem.state = TGAudioPlayerGlobalStateWaitPlaying;
//    self.cellState = CellStateNormal;
//    
//    [self setNeedsDisplay:YES];
//    
//    [TGAudioPlayerWindow resume];
//}


-(MessageTableItemAudio *)audioItem {
    return (MessageTableItemAudio *)self.item;
}

@end
