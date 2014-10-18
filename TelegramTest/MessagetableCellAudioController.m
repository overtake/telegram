//
//  MessagetableCellAudioController.m
//  Telegram
//
//  Created by keepcoder on 17.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessagetableCellAudioController.h"


@implementation MessagetableCellAudioController

- (void)cancelDownload {
    [super cancelDownload];
    
    self.item.state = AudioStateWaitDownloading;
    self.cellState = CellStateNeedDownload;
}

-(float)progressWidth {
    return MAX(200, MIN(250, self.item.message.media.audio.duration * 30));
}



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect rect = [self progressRect];
    [GRAY_BORDER_COLOR set];
    NSRectFill(rect) ;
    [NSBezierPath fillRect:rect];
    
    __block float duration;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^{
        duration = [globalAudioPlayer() duration];
    } synchronous:YES];
    
    if(duration == 0.0f) {
        duration = 0.01f;
    }
    
    //   if(!duration)
    //     duration = 1;
    
    if((self.item.state == AudioStatePlaying || self.item.state == AudioStatePaused) && globalAudioPlayer()) {
        float progress = MAX( MIN(self.currentTime / duration * [self progressWidth], [self progressWidth]), 0);
        
        [self setDurationTextFieldString:[NSString stringWithFormat:@"%@ / %@", [NSString durationTransformedValue:floor(self.currentTime)], self.item.duration]];
        
        NSRect progressRect = NSMakeRect(rect.origin.x, rect.origin.y, progress, rect.size.height);
        
        [NSColorFromRGB(0x44a2d6) set];
        NSRectFill( progressRect );
        [NSBezierPath fillRect:progressRect];
        
        
//        NSBezierPath *path = [NSBezierPath bezierPath];
//        
//        [path appendBezierPathWithArcWithCenter: NSMakePoint(rect.origin.x+progress, rect.origin.y+1)
//                                         radius: 3
//                                     startAngle: 0
//                                       endAngle: 360 clockwise:NO];
//        
//        [path fill];
        
    }
    
}

-(void)setDurationTextFieldString:(NSString *)string {
    [self.durationView setStringValue:string];
}


-(void)setCurrentTime:(NSTimeInterval)currentTime {
    
    __block float duration;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^{
        duration = [globalAudioPlayer() duration];
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
        duration = (float)[globalAudioPlayer() duration];
    } synchronous:YES];
    
    self.currentTime =  percent * [globalAudioPlayer() duration];
    
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
    
    
    self.acceptTimeChanger = NSPointInRect(pos, rect) && [globalAudioPlayer() isEqualToPath:self.item.path] && !globalAudioPlayer().isPaused;
    
    if(self.acceptTimeChanger) {
        [self changeTime:pos rect:rect];
        
        [self pause];
    }
}


- (void)setStateTextFieldString:(NSString *)string {
    [self.stateTextField setHidden:NO];
    [self.stateTextField setStringValue:string];
    [self.stateTextField sizeToFit];
    [self.stateTextField setFrameOrigin:NSMakePoint(self.durationView.frame.origin.x + self.durationView.frame.size.width, self.durationView.frame.origin.y - 2)];
}



-(void)play:(NSTimeInterval)fromPosition {
    
    [globalAudioPlayer() stop];
    [globalAudioPlayer().delegate audioPlayerDidFinishPlaying:globalAudioPlayer()];
    setGlobalAudioPlayer([TGAudioPlayer audioPlayerForPath:[self.item path]]);
    
    if(globalAudioPlayer()) {
        [globalAudioPlayer() setDelegate:self.item];
        [globalAudioPlayer() playFromPosition:fromPosition];
        
        self.item.state = AudioStatePlaying;
        self.cellState = self.cellState;
        [self startTimer];
    }
}

- (void)pause {
    [globalAudioPlayer() pause];
    
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
            
            self.currentTime = [globalAudioPlayer() currentPositionSync:YES];
            
            
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
    setGlobalAudioPlayer(nil);
    [self setDurationTextFieldString:self.item.duration];
    self.item.state = AudioStateWaitPlaying;
    self.cellState = CellStateNormal;
    
    [self setNeedsDisplay:YES];
}


@end
