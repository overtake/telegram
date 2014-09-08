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
#import "TGPeer+Extensions.h"
#import "TMPreviewDocumentItem.h"
#import "DownloadAudioItem.h"
#import "TMCircularProgress.h"
#import "MessageTableItemAudio.h"

#import "TGTimer.h"
#import "NSStringCategory.h"

#define OFFSET 75.0f

@interface MessageTableCellAudioView()

@property (nonatomic, strong) TMTextField *stateTextField;
@property (nonatomic, strong) MessageTableItemAudio *item;

@property (nonatomic, strong) BTRButton *playerButton;
@property (nonatomic, strong) TMTextField *durationView;
@property (nonatomic, assign) BOOL needPlayAfterDownload;
@property (nonatomic, strong) TGTimer *progressTimer;
@property (nonatomic, assign) float progress;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) BOOL acceptTimeChanger;

@end

@implementation MessageTableCellAudioView

static TGAudioPlayer *player;

+ (void)stop {
    [player stop];
    [player.delegate audioPlayerDidFinishPlaying:player];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        weak();
        
        self.playerButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 3, 40, 40)];
        [self.playerButton setFrameSize:image_VoiceMessagePlay().size];
        [self.playerButton setOpacityHover:YES];
        [self.playerButton setBackgroundImage:image_VoiceMessagePlay() forControlState:BTRControlStateNormal];
    //    [self.playerButton setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateNormal];
        [self.playerButton addBlock:^(BTRControlEvents events) {
            
            if(weakSelf.item.messageSender) {
                [weakSelf deleteAndCancel];
                return;
            }
            
            if(weakSelf.cellState == CellStateDownloading) {
                [weakSelf cancelDownload];
                return;
            }
            
            if(weakSelf.item.state == AudioStateWaitDownloading) {
                if([weakSelf.item canDownload])
                    [weakSelf startDownload:YES];
                return;
            }
            
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
                [player reset];
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
        
        self.durationView = [[TMTextField alloc] initWithFrame:NSMakeRect(self.playerButton.frame.size.width + 8, 15, 100, 20)];
        [self.durationView setEnabled:NO];
        [self.durationView setBordered:NO];
        [self.durationView setEditable:NO];
        [self.durationView setDrawsBackground:NO];
        [self.durationView setStringValue:@"00:00 / 00:00"];
        [self.durationView sizeToFit];
        [self.durationView setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        [self.durationView setTextColor:NSColorFromRGB(0xbebebe)];
        [self.containerView addSubview:self.durationView];
        
        
        self.stateTextField = [[TMTextField alloc] initWithFrame:NSZeroRect];
        [self.stateTextField setEnabled:NO];
        [self.stateTextField setBordered:NO];
        [self.stateTextField setEditable:NO];
        [self.stateTextField setDrawsBackground:NO];
        [self.stateTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        [self.stateTextField setTextColor:NSColorFromRGB(0xbebebe)];

        
        [self.containerView addSubview:self.stateTextField];
        
    }
    return self;
}

- (void)setStateTextFieldString:(NSString *)string {
    [self.stateTextField setHidden:NO];
    [self.stateTextField setStringValue:string];
    [self.stateTextField sizeToFit];
    [self.stateTextField setFrameOrigin:NSMakePoint(self.durationView.frame.origin.x + [self progressWidth] - self.stateTextField.bounds.size.width, self.durationView.frame.origin.y - 2)];
    
//    [self.stateTextField setTextColor:[NSColor redColor]];
//    [self.stateTextField setBackgroundColor:[NSColor redColor]];
//    NSLog(@"state %@", string);
}

- (void)cancelDownload {
    [super cancelDownload];

    self.item.state = AudioStateWaitDownloading;
    self.cellState = CellStateNeedDownload;
}

-(float)progressWidth {
    return MAX(160, MIN(205, self.item.message.media.audio.duration * 30));
}

- (NSRect)progressRect {
    return NSMakeRect(self.containerView.frame.origin.x + self.playerButton.frame.size.width + 10, self.containerView.frame.origin.y + 5, [self progressWidth], 2);
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
    
    NSRect rect = [self progressRect];
    [GRAY_BORDER_COLOR set];
    NSRectFill(rect) ;
    [NSBezierPath fillRect:rect];
    
    __block float duration;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^{
        duration = [player duration];
    } synchronous:YES];
    
    if(duration == 0.0f) {
        duration = 0.01f;
    }
    
 //   if(!duration)
   //     duration = 1;
    
    if((self.item.state == AudioStatePlaying || self.item.state == AudioStatePaused) && player) {
         float progress = MAX( MIN(self.currentTime / duration * [self progressWidth], [self progressWidth]), 0);
        
        [self.durationView setStringValue:[NSString stringWithFormat:@"%@ / %@", [NSString durationTransformedValue:floor(self.currentTime)], self.item.duration]];
        
        //NSLog(@"progress = %f, current: %f, duration:%d",progress,[player currentPositionSync:YES],self.item.message.media.audio.duration);
        NSRect progressRect = NSMakeRect(rect.origin.x, rect.origin.y, progress, rect.size.height);
        
        [NSColorFromRGB(0x44a2d6) set];
        NSRectFill( progressRect );
        [NSBezierPath fillRect:progressRect];
        
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        
        [path appendBezierPathWithArcWithCenter: NSMakePoint(rect.origin.x+progress, rect.origin.y+1)
                                         radius: 3
                                     startAngle: 0
                                       endAngle: 360 clockwise:NO];
        
        [path fill];
        
    }

}


-(void)setCurrentTime:(NSTimeInterval)currentTime {
    
    __block float duration;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^{
        duration = [player duration];
    } synchronous:YES];
    
    
    
    self->_currentTime = MAX(MIN(currentTime, duration), 0);
}

-(void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSRect rect = [self progressRect];
    
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
        duration = (float)[player duration];
    } synchronous:YES];
    
    self.currentTime =  percent * [player duration];
    
     NSLog(@"%f, percent:%f",self.currentTime,percent );
    
    [self play:self.currentTime];
    
    
    [self setNeedsDisplay:YES];
}


-(void)mouseUp:(NSEvent *)theEvent {
   
    
    [super mouseUp:theEvent];
    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSRect rect = [self progressRect];
    
    rect.size.height+=6;
    rect.origin.y-=3;
    
    
    if(self.acceptTimeChanger) {
        self.acceptTimeChanger = NO;
        [self changeTime:pos rect:rect];
    }
    
}


-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSRect rect = [self progressRect];
    
    rect.size.height = 6;
    rect.origin.y-=3;

    
    self.acceptTimeChanger = NSPointInRect(pos, rect) && [player isEqualToPath:self.item.path] && !player.isPaused;
    
    if(self.acceptTimeChanger) {
        [self changeTime:pos rect:rect];
        
        [self pause];
    }
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
        self.item.state = AudioStateWaitPlaying;
        self.cellState = CellStateNormal;
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
        [self.stateTextField setHidden:NO];
    }
    
    if(cellState == CellStateNeedDownload) {
        [self setStateTextFieldString:[NSString sizeToTransformedValuePretty:self.item.size]];
        [self.stateTextField setHidden:NO];
    }
    
    switch (self.item.state) {
        case AudioStateWaitPlaying:
            [self.playerButton setBackgroundImage:image_VoiceMessagePlay() forControlState:BTRControlStateNormal];
            break;
            
        case AudioStatePaused:
            [self.playerButton setBackgroundImage:image_VoiceMessagePlay() forControlState:BTRControlStateNormal];
            break;
            
        case AudioStatePlaying:
            [self.playerButton setBackgroundImage:image_VoiceMessagePause() forControlState:BTRControlStateNormal];
            break;
            
        case AudioStateWaitDownloading:
            [self.playerButton setBackgroundImage:image_VoiceMessageDownload() forControlState:BTRControlStateNormal];
            break;
            
        case AudioStateUploading:
            [self.playerButton setBackgroundImage:image_VoiceMessageCancel() forControlState:BTRControlStateNormal];
            break;
            
        case AudioStateDownloading:
            [self.playerButton setBackgroundImage:image_VoiceMessageCancel() forControlState:BTRControlStateNormal];
            break;
            
        default:
            break;
    }

    
    [self setNeedsDisplay:YES];
    
}



- (void)setItem:(MessageTableItemAudio *)item {
    [super setItem:item];
    
    item.cellView = self;
    
    self.acceptTimeChanger = NO;
    
    [self updateDownloadState];
    
    [self.durationView setStringValue:item.duration];
    
    if(item.state != AudioStatePlaying && item.state != AudioStatePaused)
        [self updateCellState];
    else {
        self.cellState = self.cellState;
        if(item.state != AudioStatePaused)
            [self startTimer];
    }
    

}


-(void)onAddedListener:(SenderItem *)item {
    [super onAddedListener:item];
    
    [self onStateChanged:item];
}

-(void)onStateChanged:(SenderItem *)item {
    [super onStateChanged:item];
    
    if(item == self.item.messageSender) {
        [self updateCellState];
    }
}

-(void)onProgressChanged:(SenderItem *)item {
    [super onProgressChanged:item];
    if(item == self.item.messageSender) {
      
    }
}

-(void)updateDownloadState {
    weak();
    [self.item.downloadListener setCompleteHandler:^(DownloadItem * item) {
        
        weakSelf.item.downloadItem = nil;
        
        [weakSelf updateCellState];
        
      //  [weakSelf play:0];
        
    }];
    
    [self.item.downloadListener setProgressHandler:^(DownloadItem * item) {
        
    }];
    
    [self updateCellState];
}


- (void) startDownload:(BOOL)needPlay {
   
    [self.item startDownload:NO downloadItemClass:[DownloadAudioItem class] force:YES];

    
    [self updateDownloadState];
   
}

-(void)play:(NSTimeInterval)fromPosition {
    
    [player stop];
    [player.delegate audioPlayerDidFinishPlaying:player];
    player = [TGAudioPlayer audioPlayerForPath:[self.item path]];
    
    
    if(player) {
        [player setDelegate:self.item];
        [player playFromPosition:fromPosition];
        
        self.item.state = AudioStatePlaying;
        self.cellState = self.cellState;
        [self startTimer];
    }
}

- (void)pause {
    [player pause];
    
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

- (void)startTimer {
    if(!self.progressTimer) {
        self.progressTimer = [[TGTimer alloc] initWithTimeout:1.0f/60.0f repeat:YES completion:^{
            
            if(self.item.state != AudioStatePlaying) {
                [self.progressTimer invalidate];
                self.progressTimer = nil;
            }
            
             self.currentTime = [player currentPositionSync:YES];
            
            
            if(self.currentTime > 0.0f) {
                [self setNeedsDisplay:YES];
            }
           
            
        } queue:dispatch_get_current_queue()];
        
        [self.progressTimer start];
    }
}

- (void)stopPlayer {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    player = nil;
    [self.durationView setStringValue:self.item.duration];
    self.item.state = AudioStateWaitPlaying;
    self.cellState = CellStateNormal;
    
    [self setNeedsDisplay:YES];
}

@end
