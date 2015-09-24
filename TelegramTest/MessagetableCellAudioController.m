//
//  MessagetableCellAudioController.m
//  Telegram
//
//  Created by keepcoder on 17.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessagetableCellAudioController.h"
#import "TGAudioPlayerWindow.h"

@implementation MessagetableCellAudioController

- (void)cancelDownload {
    [super cancelDownload];
    
    self.item.state = AudioStateWaitDownloading;
    self.cellState = CellStateNeedDownload;
}

-(float)progressWidth {
    return MAX(150, MIN(self.item.blockSize.width, self.item.message.media.audio.duration * 30));
}



NSImage *blueBackground() {
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

 NSImage *grayBackground() {
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

NSImage *playImage() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, image_PlayIconWhite().size.width + 5, image_PlayIconWhite().size.height+1);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        
        [image_PlayIconWhite() drawInRect:NSMakeRect(5, 0, image_PlayIconWhite().size.width, image_PlayIconWhite().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        
     //   [image_PlayIconWhite() drawInRect:NSMakeRect(5, 0, image_PlayIconWhite().size.width, image_PlayIconWhite().size.height)];
        
        [image unlockFocus];
    });
    return image;
}

NSImage *voicePlay() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, image_VoicePlay().size.width + 5, image_VoicePlay().size.height+1);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        
        [image_VoicePlay() drawInRect:NSMakeRect(5, 0, image_VoicePlay().size.width, image_VoicePlay().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
        
        [image unlockFocus];
    });
    return image;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect rect = [self progressRect];
    [NSColorFromRGB(0xebebeb) set];
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
    [self.durationView setFrameSize:NSMakeSize(NSWidth(self.containerView.frame) - NSMinX(self.durationView.frame) - NSWidth(self.stateTextField.frame), NSHeight(self.durationView.frame))];
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
    [self.stateTextField setFrameOrigin:NSMakePoint(NSMaxX(self.durationView.frame) + 10, self.durationView.frame.origin.y - 2)];
}



-(void)play:(NSTimeInterval)fromPosition {
    
    [TGAudioPlayerWindow pause];
    
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
    
    [TGAudioPlayerWindow resume];
}


@end
