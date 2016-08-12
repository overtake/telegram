//
//  TGAudioGlobalController.m
//  Telegram
//
//  Created by keepcoder on 27/05/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGAudioGlobalController.h"
#import "TGTimer.h"
#import "TGAudioGlobalController.h"
#import "AudioHistoryFilter.h"
#import "MP3HistoryFilter.h"
#import "TGAudioPlayerWindow.h"
@interface TGAudioGlobalController ()<TGAudioPlayerDelegate> {
    TGTimer *_progressTimer;
}
@property (nonatomic,strong) NSArray *items;
@property (nonatomic,assign) TGAudioPlayerGlobalState playerState;
@property (nonatomic,assign) NSTimeInterval currentTime;

@property (nonatomic,assign) TGAudioPlayerGlobalStyle style;


@property (nonatomic,strong) DownloadEventListener *downloadEventListener;

@property (nonatomic,strong) NSMutableArray *eventListeners;


@end

@implementation TGAudioGlobalController

-(instancetype)init {
    if(self = [super init]) {
        _eventListeners = [[NSMutableArray alloc] init];
        _filterClass = [MP3HistoryFilter class];
        
    }
    
    return self;
}

-(void)show:(TL_conversation *)conversation navigation:(TMNavigationController *)navigation {
    if(_conversation == conversation)
        return;
    
    _navigationController = navigation;
    
    _conversation = conversation;
    [self updateWithItem:nil];
    _currentItem = nil;
    [_playerList setController:nil];

}

-(void)show:(TL_conversation *)conversation navigation:(TMNavigationController *)navigation currentItem:(MessageTableItemAudioDocument *)currentItem {
    if(_conversation == conversation)
        return;
    
    _navigationController = navigation;
    _autoStart = YES;
    _conversation = conversation;
    [self updateWithItem:currentItem];
    
    self.currentItem = currentItem;
    [_playerList setController:self];
    
    
}

-(void)setRepeat:(BOOL)repeat {
    _repeat = repeat;
}

-(void)hide {
    [self stopPlayer];
    [self.currentItem.downloadItem removeEvent:_downloadEventListener];
    _downloadEventListener = nil;
    [_playerList setController:nil];
    _conversation = nil;
    [_eventListeners removeAllObjects];
    [_navigationController hideInlinePlayer:nil];
    [Notification perform:UPDATE_MESSAGE_ITEM data:@{KEY_MESSAGE_ID:@(_currentItem.message.n_id),KEY_PEER_ID:@(_currentItem.message.peer_id)}];
    _currentItem = nil;
}

-(TGAudioPlayerGlobalState)pState {
    return _playerState;
}

-(void)show:(TL_conversation *)conversation playerState:(TGAudioPlayerGlobalState)playerState navigation:(TMNavigationController *)navigation {
    [self show:conversation navigation:navigation];
    [self setPlayerState:playerState];
    
}

-(void)setFilterClass:(Class)filterClass {
    _filterClass = filterClass;
    _playerList.filterClass = filterClass;
}

-(void)setPlayerList:(TGAudioPlayerListView *)playerList {
    _playerList = playerList;
    
    _playerList.filterClass = _filterClass;
    
    _playerList.controller = self;
    
    [self updateWithItem:_currentItem];
    
    weak();
    
    [_playerList setChangedAudio:^(MessageTableItemAudioDocument *audioItem) {
        [weakSelf setCurrentItem:audioItem];
    }];
}

-(void)setProgressView:(TGAudioProgressView *)progressView {
    _progressView = progressView;
    
    weak();
    
    [_progressView setProgressCallback:^(float progress) {
        
        if(!weakSelf.currentItem)
            return;
        
        if(globalAudioPlayer() && globalAudioPlayer().delegate == self && (self.currentItem.downloadItem == nil || self.currentItem.downloadItem.downloadState == DownloadStateCompleted)) {
            weakSelf.currentTime = globalAudioPlayer().duration * (progress/100);
            
            if(weakSelf.playerState == TGAudioPlayerGlobalStatePlaying) {
                [globalAudioPlayer() playFromPosition:weakSelf.currentTime];
            }
        }
        
    }];
}

-(void)setCurrentItem:(MessageTableItemAudioDocument *)audioItem {
    
    [_currentItem.downloadItem removeEvent:_downloadEventListener];
    
    if(_currentItem == audioItem && audioItem)
    {
        [self playOrPause];
        return;
    }
    
    [_currentItem.downloadItem removeEvent:_downloadEventListener];
    
    _currentItem = audioItem;
    
    _currentItem.state = TGAudioPlayerGlobalStateWaitPlaying;
    
    [self updateWithItem:_currentItem];

    
    if(!_currentItem)
        return;
    
    
   [self.eventListeners enumerateObjectsUsingBlock:^(id  <TGAudioPlayerGlobalDelegate> obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj respondsToSelector:@selector(playerDidChangeItem:)])
            [obj playerDidChangeItem:audioItem];
        
    }];
    
    self.currentTime = 0;
    
    [self globalNotify:audioItem];
    
    [_progressView setDownloadProgress:0];
    
    if([_currentItem isset]) {
        [_progressView setDisableChanges:NO];
        [self play:self.currentTime];
    } else {
        [_currentItem startDownload:NO force:YES];
        [self updateDownloadListener];
        [self stopPlayer];
    }
    
    
    
    
}

-(void)globalNotify:(MessageTableItemAudioDocument *)audioItem {
    
    static NSUserNotification *sNotify;
    
    if(sNotify) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:sNotify];
    }
    
    
    sNotify = [[NSUserNotification alloc] init];
    
    NSString *name = audioItem.nameAttributedString.string;
    
    
    NSArray *items = [name componentsSeparatedByString:@"\n"];
    
    if(items.count > 0)
        sNotify.title = items[0];
    else
        sNotify.title = @"Unknown Artist";
    if(items.count > 1)
        sNotify.informativeText = items[1];
    
    
    
    NSImage *image = [self.playerList getAlbumImageFromItem:audioItem];
    @try {
        if(image) {
            [sNotify setValue:image forKey:@"_identityImage"];
        }
    } @catch (NSException *exception) {
        
    }
    
    
    
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:sNotify];
    
    
}


-(void)updateWithItem:(MessageTableItemAudioDocument *)item {
    
    [_playerList setSelectedId:_currentItem.message.randomId];
    
}


+(TGAudioGlobalController *)globalController:(TMNavigationController *)nav {
    return [TGAudioPlayerWindow controller] ? [TGAudioPlayerWindow controller] : nav.inlineController;
}

-(void)updateDownloadListener {
    
    
    if(_currentItem.downloadItem && _currentItem.downloadItem.downloadState != DownloadStateCompleted) {
        
        [_progressView setDisableChanges:YES];
        
        weak();
        
        [self.progressView setDownloadProgress:_currentItem.downloadItem.progress];
        
        
        [_currentItem.downloadItem removeEvent:_downloadEventListener];
        
        _downloadEventListener = [[DownloadEventListener alloc] init];
        
        [_currentItem.downloadItem addEvent:_downloadEventListener];
        
        
        [_downloadEventListener setCompleteHandler:^(DownloadItem * item) {
            
            [ASQueue dispatchOnMainQueue:^{
                
                [weakSelf.progressView setDisableChanges:NO];
                
                [weakSelf.progressView setDownloadProgress:0];
                
                [weakSelf play:weakSelf.currentTime];
                
                [weakSelf.playerList reloadData];
                
                [weakSelf updateWithItem:weakSelf.currentItem];
                
            }];
            
        }];
        
        [_downloadEventListener setProgressHandler:^(DownloadItem * item) {
            
            [ASQueue dispatchOnMainQueue:^{
                
                [weakSelf.progressView setDownloadProgress:item.progress];
                
            }];
        }];
        
    } else {
        [_progressView setDisableChanges:NO];
    }
}


-(void)clear {
    [self stopPlayer];
    [_playerList setController:nil];
}

-(void)setPlayerState:(TGAudioPlayerGlobalState)playerState {
    _currentItem.state = playerState;
    _playerState = playerState;
    
    [self notifyAllListeners];
    
}

-(void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    [self.progressView setCurrentProgress:(self.currentTime/globalAudioPlayer().duration) * 100];
    
    [self.eventListeners enumerateObjectsUsingBlock:^(id  <TGAudioPlayerGlobalDelegate> obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(playerDidChangeTime:)]) {
            [obj playerDidChangeTime:currentTime];
        }
    }];
}


-(void)play:(NSTimeInterval)fromPosition {
    
    
    [globalAudioPlayer() stop];
    if(globalAudioPlayer().delegate != self)
        [globalAudioPlayer().delegate audioPlayerDidFinishPlaying:globalAudioPlayer()];
    setGlobalAudioPlayer([TGAudioPlayer audioPlayerForPath:[_currentItem path]]);
    
    if(globalAudioPlayer()) {
        [globalAudioPlayer() setDelegate:self];
        [globalAudioPlayer() playFromPosition:fromPosition];
        [self startTimer];
    }
    
    self.playerState = TGAudioPlayerGlobalStatePlaying;

}

- (void)forcePause {
    [globalAudioPlayer() pause];
    self.playerState = TGAudioPlayerGlobalStatePaused;
    [_progressTimer invalidate];
    _progressTimer = nil;
}

- (void)startTimer {
    if(!_progressTimer) {
        _progressTimer = [[TGTimer alloc] initWithTimeout:1.0f/60.0f repeat:YES completion:^{
            
            if(globalAudioPlayer() == nil)
            {
                [_progressTimer invalidate];
                _progressTimer = nil;
            }
            
            if(_currentItem.state != TGAudioPlayerGlobalStatePlaying) {
                [_progressTimer invalidate];
                _progressTimer = nil;
            }
            
            self.currentTime = [globalAudioPlayer() currentPositionSync:YES];
            
            
            
        } queue:dispatch_get_current_queue()];
        
        [_progressTimer start];
    }
}

- (void)stopPlayer {
    [_progressTimer invalidate];
    _progressTimer = nil;
    setGlobalAudioPlayer(nil);
    self.playerState = TGAudioPlayerGlobalStateWaitPlaying;
    self.currentTime = 0;
    [_progressView setCurrentProgress:0];
    
}

-(void)nextTrack {
   [_playerList selectNext];
}

-(void)prevTrack {
   [_playerList selectPrev];
}

-(void)pause {
    if(self.playerState == TGAudioPlayerGlobalStatePlaying)
    {
        [self forcePause];
        [self setPlayerState:TGAudioPlayerGlobalStateForcePaused];
    }
    
}

-(void)resume {
    if(self.playerState == TGAudioPlayerGlobalStateForcePaused)
        [self play:self.currentTime];
}

-(void)playOrPause {
    
    
    if(!_currentItem) {
        [self nextTrack];
        return;
    }
    
    if(self.playerState == TGAudioPlayerGlobalStatePlaying) {
        [self pause];
    } else {
        [self play:self.currentTime];
    }
}

-(void)addEventListener:(id<TGAudioPlayerGlobalDelegate>)delegate {
    if([_eventListeners indexOfObject:delegate] == NSNotFound)
    {
        [_eventListeners addObject:delegate];
    }
}

-(void)removeEventListener:(id<TGAudioPlayerGlobalDelegate>)delegate {
    [_eventListeners removeObject:delegate];
}

-(void)notifyAllListeners {
    [_eventListeners enumerateObjectsUsingBlock:^(id<TGAudioPlayerGlobalDelegate> obj, NSUInteger idx, BOOL *stop) {
        [obj playerDidChangedState:self.currentItem playerState:self.playerState];
    }];
}




- (void)audioPlayerDidFinishPlaying:(TGAudioPlayer *)audioPlayer {
    if(self.playerState == TGAudioPlayerGlobalStatePlaying) {
        if(!_repeat)
            [self nextTrack];
        else {
            id item = self.currentItem;
            [self setCurrentItem:nil];
            [self setCurrentItem:item];
        }
    }
    
}
- (void)audioPlayerDidStartPlaying:(TGAudioPlayer *)audioPlayer {
    
}

@end
