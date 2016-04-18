//
//  TGAudioController.m
//  Telegram
//
//  Created by keepcoder on 04/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGAudioController.h"
#import "TGAudioPlayerWindow.h"

@interface TGAudioController () <TGAudioPlayerDelegate>
@property (nonatomic,assign) AudioState audioState;
@end

@implementation TGAudioController

-(void)playOrPause {
    
    if(_audioState == AudioStateWaitPlaying) {
        self.currentTime = 0;
        [self play:0];
        
        return;
    }
    if(_audioState == AudioStatePaused) {
        self.audioState = AudioStatePlaying;
        [self play:self.currentTime];
        return;
    }
    if(_audioState == AudioStatePlaying) {
        self.audioState = AudioStatePaused;
        [self.progressTimer invalidate];
        _progressTimer = nil;
        [self pause];
        return;
    }
}

-(void)stop {
    [self stopPlayer];
}

- (void)audioPlayerDidFinishPlaying:(TGAudioPlayer *)audioPlayer {
    [ASQueue dispatchOnMainQueue:^{
        [self stopPlayer];
    }];
    
}
- (void)audioPlayerDidStartPlaying:(TGAudioPlayer *)audioPlayer {
    
}


-(void)play:(NSTimeInterval)fromPosition {
    
    [TGAudioPlayerWindow pause];
    
    [globalAudioPlayer() stop];
    [globalAudioPlayer().delegate audioPlayerDidFinishPlaying:globalAudioPlayer()];
    setGlobalAudioPlayer([TGAudioPlayer audioPlayerForPath:_path]);
    
    if(globalAudioPlayer()) {
        [globalAudioPlayer() setDelegate:self];
        [globalAudioPlayer() playFromPosition:fromPosition];
        
        self.audioState = AudioStatePlaying;
        [self startTimer];
    }
}

- (void)pause {
    [globalAudioPlayer() pause];
    
    [self.progressTimer invalidate];
    _progressTimer = nil;
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
    
    _progress = ceil((self.currentTime / duration) * 100.0f);
    
    [self.delegate audioControllerUpdateProgress:_progress];
}

- (void)startTimer {
    if(!self.progressTimer) {
        _progressTimer = [[TGTimer alloc] initWithTimeout:1.0f/60.0f repeat:YES completion:^{
            
            if(_audioState != AudioStatePlaying) {
                [_progressTimer invalidate];
                _progressTimer = nil;
            }
            
            self.currentTime = [globalAudioPlayer() currentPositionSync:YES];
            
            if(self.currentTime > 0.0f) {
                [self.delegate audioControllerSetNeedDisplay];
            }
            
        } queue:dispatch_get_current_queue()];
        
        [self.progressTimer start];
    }
}

-(void)setAudioState:(AudioState)audioState {
    _audioState = audioState;
    
    [self.delegate audioControllerSetNeedDisplay];
}

- (void)stopPlayer {
    [self.progressTimer invalidate];
    _progressTimer = nil;
    setGlobalAudioPlayer(nil);
    
    self.currentTime = 0;
    
    self.audioState = AudioStateWaitPlaying;
    
    [self.delegate audioControllerSetNeedDisplay];
    
    [TGAudioPlayerWindow resume];
}


-(void)setPath:(NSString *)path  {
    _audioState = AudioStateWaitPlaying;
    _path = path;
}

-(AudioState)state {
    return _audioState;
}

@end
