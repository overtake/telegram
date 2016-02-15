//
//  TGRecordedAudioPrevew.m
//  Telegram
//
//  Created by keepcoder on 14/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGRecordedAudioPreview.h"
#import "TGWaveformView.h"
#import "TL_documentAttributeAudio+Extension.h"
#import "NSNumber+NumberFormatter.h"
#import "TGAudioPlayerWindow.h"
#import "MessageTableItemAudio.h"
#import "TGTimer.h"
@interface TGRecordedAudioPreview ()<TGAudioPlayerDelegate>
@property (nonatomic,strong) TGWaveformView *waveformView;
@property (nonatomic,strong) BTRButton *playOrPauseButton;

@property (nonatomic,strong) TMTextField *durationField;

@property (nonatomic,assign) AudioState audioState;

@property (nonatomic,strong) TGTimer *progressTimer;


@property (nonatomic,assign) NSTimeInterval currentTime;
@end

@implementation TGRecordedAudioPreview

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _waveformView = [[TGWaveformView alloc] initWithFrame:NSMakeRect(30, 10, 150, 20)];
        
        _waveformView.defaultColor = [NSColor whiteColor];
        
        [_waveformView setCenteredYByView:self];
        
        [self addSubview:_waveformView];
        
        _playOrPauseButton = [[BTRButton alloc] initWithFrame:NSMakeRect(5, 5, 20, 20)];
        
        [_playOrPauseButton setImage:image_TempAudioPreviewPlay() forControlState:BTRControlStateNormal];
        
        [_playOrPauseButton setCenteredYByView:self];
        
        
        weak();
        [_playOrPauseButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf playOrPause];
            
        } forControlEvents:BTRControlEventClick];
        
        [self addSubview:_playOrPauseButton];
        
        _durationField = [TMTextField defaultTextField];
        
        [_durationField setFont:TGSystemFont(13)];
        [_durationField setTextColor:[NSColor whiteColor]];
        
        [self addSubview:_durationField];
        
        self.wantsLayer = YES;
        self.layer.cornerRadius = 4;
        
        self.layer.backgroundColor = NSColorFromRGB(0x1893ef).CGColor;
        
    }
    
    return self;
}

-(void)playOrPause {
    
    if(_audioState == AudioStateWaitPlaying) {
         self.currentTime = 0;
        [self setNeedsDisplay:YES];
        [self play:0];
        
        return;
    }
    if(_audioState == AudioStatePaused) {
        self.audioState = AudioStatePlaying;
        [globalAudioPlayer() reset];
        [self startTimer];
        return;
    }
    if(_audioState == AudioStatePlaying) {
        self.audioState = AudioStatePaused;
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        [self pause];
        return;
    }
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
    setGlobalAudioPlayer([TGAudioPlayer audioPlayerForPath:_audio_file]);
    
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
    self.progressTimer = nil;
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
    
    [self updateDurationField];
    
    _waveformView.progress = ceil((self.currentTime / duration) * 100.0f);
}

- (void)startTimer {
    if(!self.progressTimer) {
        self.progressTimer = [[TGTimer alloc] initWithTimeout:1.0f/60.0f repeat:YES completion:^{
            
            if(_audioState != AudioStatePlaying) {
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

-(void)setAudioState:(AudioState)audioState {
    _audioState = audioState;
    
    [self updateDurationField];
    
    [self.playOrPauseButton setImage:_audioState == AudioStatePlaying ? image_TempAudioPreviewPause() : image_TempAudioPreviewPlay() forControlState:BTRControlStateNormal];
    
    if(_audioState == AudioStatePlaying || _audioState == AudioStatePaused) {
        _waveformView.defaultColor = NSColorFromRGB(0xced9e0);
        _waveformView.progressColor = [NSColor whiteColor];
    } else {
        _waveformView.defaultColor = [NSColor whiteColor];
    }
}

- (void)stopPlayer {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    setGlobalAudioPlayer(nil);
    
    self.currentTime = 0;
    
     self.audioState = AudioStateWaitPlaying;
    
    [self setNeedsDisplay:YES];
    
    [TGAudioPlayerWindow resume];
}


-(void)setAudio_file:(NSString *)audio_file  audioAttr:(TL_documentAttributeAudio *)audioAttr {
    
    _audioState = AudioStateWaitPlaying;
    _audio_file = audio_file;
    _audioAttr = audioAttr;
    _waveformView.waveform = audioAttr.arrayWaveform;
    
    [self updateDurationField];
    
}


-(void)updateDurationField {
    
    if(_audioState == AudioStatePlaying || _audioState == AudioStatePaused) {
        [_durationField setStringValue:[NSString durationTransformedValue:_currentTime]];
    } else {
        [_durationField setStringValue:[NSString durationTransformedValue:_audioAttr.duration]];
    }
    
    [_durationField sizeToFit];
    
    [_durationField setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_durationField.frame) - 10, 0)];
    
    [_durationField setCenteredYByView:self];
}

@end
