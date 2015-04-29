/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioPlayer.h"

#import "ASQueue.h"

#import "TGOpusAudioPlayerAU.h"
#import "TGNativeAudioPlayer.h"

#import <AVFoundation/AVFoundation.h>

@interface TGAudioPlayer ()
{
    bool _audioSessionIsActive;
}

@end

@implementation TGAudioPlayer

+ (TGAudioPlayer *)audioPlayerForPath:(NSString *)path
{
    if (path == nil)
        return nil;
    
    if ([TGOpusAudioPlayerAU canPlayFile:path])
        return [[TGOpusAudioPlayerAU alloc] initWithPath:path];
    else
        return [[TGNativeAudioPlayer alloc] initWithPath:path];
}

static TGAudioPlayer *player;

TGAudioPlayer *globalAudioPlayer() {
    return player;
}

void setGlobalAudioPlayer(TGAudioPlayer *newPlayer) {
    player = newPlayer;
}

-(BOOL)isPaused {
    return YES;
}

-(BOOL)isEqualToPath:(NSString *)path {
    return NO;
}

- (void)play
{
    [self playFromPosition:-1.0];
}

- (void)playFromPosition:(NSTimeInterval)__unused position
{
}

- (void)pause
{
}

-(void)reset {
    [self playFromPosition:[self currentPositionSync:YES]];
}

- (void)stop
{
    
}
 
- (NSTimeInterval)currentPositionSync:(bool)__unused sync
{
    return 0.0;
}

- (NSTimeInterval)duration
{
    return 0.0;
}

+ (ASQueue *)_playerQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ASQueue alloc] initWithName:"org.telegram.audioPlayerQueue"];
    });
    
    return queue;
}

- (void)_beginAudioSession
{
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        if (!_audioSessionIsActive)
        {
          
            _audioSessionIsActive = true;
            [self _notifyStart];
        }
    }];
}

- (void)_endAudioSession
{
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        if (_audioSessionIsActive)
        {
            _audioSessionIsActive = false;
        }
    }];
}

- (void)_endAudioSessionFinal
{
    bool audioSessionIsActive = _audioSessionIsActive;
    _audioSessionIsActive = false;
    
    [[TGAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        if (audioSessionIsActive)
        {
           
        }
    }];
}

- (void)_notifyFinished
{
    id<TGAudioPlayerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)])
        [delegate audioPlayerDidFinishPlaying:self];
}

- (void)_notifyStart
{
    id<TGAudioPlayerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioPlayerDidStartPlaying:)])
        [delegate audioPlayerDidStartPlaying:self];
}

@end
