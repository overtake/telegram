//
//  TGAudioPlayerWindow.m
//  Telegram
//
//  Created by keepcoder on 01.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGAudioPlayerWindow.h"
#import <AVFoundation/AVFoundation.h>
#import "TGAudioProgressView.h"
#import "ImageUtils.h"
#import "TGAudioPlayer.h"
#import "TGTimer.h"
#import "TGAudioPlayerListView.h"




@interface TGAudioPlayerContainerView : TMView
{
    NSTrackingArea *_trackingArea;
}

@property (nonatomic,strong) TGAudioPlayerWindow *controller;

@end

#define MINI_PHEIGHT 103
#define FULL_PHEIGHT 500

@implementation TGAudioPlayerContainerView

-(void)mouseEntered:(NSEvent *)theEvent {
    [_controller mouseEntered:theEvent];
}

-(void)mouseExited:(NSEvent *)theEvent {
    [_controller mouseExited:theEvent];
}

-(void)updateTrackingAreas
{
    if(_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    _trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:_trackingArea];
}


@end







@interface TGAudioPlayerWindow ()<TGAudioPlayerDelegate>
{
    BOOL _isVisibility;
    TGTimer *_progressTimer;
    TL_conversation *_conversation;
    
}
@property (nonatomic,strong) TGAudioPlayerContainerView *containerView;
@property (nonatomic,strong) TMView *windowContainerView;
@property (nonatomic,strong) TGAudioPlayerListView *playListContainerView;


@property (nonatomic,strong) BTRButton *closeButton;
@property (nonatomic,strong) BTRButton *pinButton;
@property (nonatomic,strong) BTRButton *playButton;
@property (nonatomic,strong) BTRButton *nextButton;
@property (nonatomic,strong) BTRButton *prevButton;
@property (nonatomic,strong) TGAudioProgressView *progressView;

@property (nonatomic,strong) BTRButton *showPlayListButton;
@property (nonatomic,strong) TMTextField *leftDurationField;
@property (nonatomic,strong) TMTextField *rightDurationField;
@property (nonatomic,strong) TMView *controlsContrainer;


@property (nonatomic,strong) TMTextField *nameTextField;
@property (nonatomic,strong) TMView *nameContainer;


@property (nonatomic,strong) NSArray *items;
@property (nonatomic,assign) TGAudioPlayerState playerState;
@property (nonatomic,assign) NSTimeInterval currentTime;

@property (nonatomic,assign) BOOL mouseInWindow;

@property (nonatomic,assign) TGAudioPlayerWindowState windowState;


@property (nonatomic,strong) DownloadEventListener *downloadEventListener;

@property (nonatomic,strong) NSMutableArray *eventListeners;

@property (nonatomic,assign) BOOL autoStart;

@end

@implementation TGAudioPlayerWindow




-(instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    if(self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen]) {
        [self initialize];
    }
    
    return self;
}

-(void)initialize {
    
    
    _eventListeners = [[NSMutableArray alloc] init];
    
    _windowContainerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth([self.contentView bounds]), MINI_PHEIGHT)];
    _windowContainerView.autoresizingMask = NSViewHeightSizable;
    
    _windowContainerView.isFlipped = YES;
    _windowContainerView.backgroundColor = NSColorFromRGB(0xf7f7f7);
    _windowContainerView.wantsLayer = YES;
    _windowContainerView.layer.cornerRadius = 4;
    
    [self.contentView addSubview:_windowContainerView];
    
    weakify();
    
    _containerView = [[TGAudioPlayerContainerView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_windowContainerView.frame), MINI_PHEIGHT)];
    _containerView.controller = self;
    _containerView.movableWindow = YES;
    
    [_windowContainerView addSubview:_containerView];
    
    _controlsContrainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_containerView.frame), NSHeight(_containerView.frame))];
    
    
    [_containerView addSubview:_controlsContrainer];
    
    
    _playListContainerView = [[TGAudioPlayerListView alloc] initWithFrame:NSMakeRect(0, MINI_PHEIGHT, NSWidth(_windowContainerView.frame), FULL_PHEIGHT - NSHeight(_containerView.frame))];

    _playListContainerView.backgroundColor = [NSColor whiteColor];
    
    
    [_playListContainerView setChangedAudio:^(MessageTableItemAudioDocument *audioItem) {
        [TGAudioPlayerWindow setCurrentItem:audioItem];
    }];
    
    [_windowContainerView addSubview:_playListContainerView];
    
    
   
    
    
    
    _playButton = [[BTRButton alloc] init];
    _prevButton = [[BTRButton alloc] init];
    _nextButton = [[BTRButton alloc] init];
    
    
    
    
    [_prevButton addBlock:^(BTRControlEvents events) {
        [strongSelf prevTrack];
    } forControlEvents:BTRControlEventMouseDownInside];
    
    [_nextButton addBlock:^(BTRControlEvents events) {
        [strongSelf nextTrack];
    } forControlEvents:BTRControlEventMouseDownInside];
    
    [_playButton addBlock:^(BTRControlEvents events) {
        
        [strongSelf playOrPause];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    
    [_playButton setBackgroundImage:image_AudioPlayerPlay() forControlState:BTRControlStateNormal];
    
    
    [_playButton setFrameSize:image_AudioPlayerPlay().size];
    
    [_playButton setCenterByView:_controlsContrainer];

    
    [_prevButton setBackgroundImage:image_AudioPlayerBack() forControlState:BTRControlStateNormal];
    
    [_prevButton setFrameSize:image_AudioPlayerBack().size];
    
    [_prevButton setFrameOrigin:NSMakePoint(NSMinX(_playButton.frame) - NSWidth(_prevButton.frame) - 25, NSMinY(_playButton.frame))];
    
    
    [_nextButton setBackgroundImage:image_AudioPlayerNext() forControlState:BTRControlStateNormal];
    
    [_nextButton setFrameSize:image_AudioPlayerNext().size];
    
    [_nextButton setFrameOrigin:NSMakePoint(NSMaxX(_playButton.frame) + 25, NSMinY(_playButton.frame))];
    
    
    
    
    [_nextButton setFrameOrigin:NSMakePoint(NSMinX(_nextButton.frame), NSHeight(_controlsContrainer.frame) - NSHeight(_nextButton.frame) - 20)];
    [_prevButton setFrameOrigin:NSMakePoint(NSMinX(_prevButton.frame), NSHeight(_controlsContrainer.frame) - NSHeight(_prevButton.frame) - 20)];
    [_playButton setFrameOrigin:NSMakePoint(NSMinX(_playButton.frame), NSHeight(_controlsContrainer.frame) - NSHeight(_playButton.frame) - 15)];
    
    [_controlsContrainer addSubview:_nextButton];
    [_controlsContrainer addSubview:_prevButton];
    [_controlsContrainer addSubview:_playButton];
    
    
    
    _progressView = [[TGAudioProgressView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_containerView.frame), 10)];
    
    [_progressView setProgressCallback:^(float progress) {
        
        if(!strongSelf.currentItem)
            return;
        
        if(globalAudioPlayer() && globalAudioPlayer().delegate == self && (self.currentItem.downloadItem == nil || self.currentItem.downloadItem.downloadState == DownloadStateCompleted)) {
            strongSelf.currentTime = globalAudioPlayer().duration * (progress/100);
            
            if(strongSelf.playerState == TGAudioPlayerStatePlaying) {
                [globalAudioPlayer() playFromPosition:strongSelf.currentTime];
            }
        }

    }];
    
    [_controlsContrainer addSubview:_progressView];
    
    
    
    _leftDurationField = [TMTextField defaultTextField];
    
    [_leftDurationField setStringValue:@"0:00"];
    
    
    [_leftDurationField setFont:TGSystemFont(13)];
    [_leftDurationField setTextColor:NSColorFromRGB(0x7F7F7F)];
    
    [_leftDurationField setFrame:NSMakeRect(10, 10, 50, 18)];
    
    [_containerView addSubview:_leftDurationField];

    
    
    _rightDurationField = [TMTextField defaultTextField];
    
    [_rightDurationField setStringValue:@"0:00"];
    
    
    [_rightDurationField setFont:TGSystemFont(13)];
    [_rightDurationField setTextColor:NSColorFromRGB(0x7F7F7F)];
    
    [_rightDurationField setFrame:NSMakeRect(NSMaxX(_containerView.frame) - 50, 10, 50, 18)];
    
    [_containerView addSubview:_rightDurationField];
    
    
    _nameContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 10, NSWidth(_containerView.frame) - 100, 40)];
    [_nameContainer setCenteredXByView:_containerView];
    
    
    _nameContainer.backgroundColor = NSColorFromRGB(0xf7f7f7);
    
    _nameTextField = [TMTextField defaultTextField];
    [_nameTextField setAlignment:NSCenterTextAlignment];
    _nameTextField.wantsLayer = YES;
    _nameTextField.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
    
    [_nameContainer addSubview:_nameTextField];
    
    [_containerView addSubview:_nameContainer];
    
    
    
    
    
    _closeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(15, NSHeight(_containerView.frame) - 20, image_AudioPlayerClose().size.width, image_AudioPlayerClose().size.height)];
    
    [_closeButton setBackgroundImage:image_AudioPlayerClose() forControlState:BTRControlStateNormal];
    
    [_containerView addSubview:_closeButton];
    
    [_closeButton addBlock:^(BTRControlEvents events) {
        
        [TGAudioPlayerWindow hide];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    
    
    _pinButton = [[BTRButton alloc] initWithFrame:NSMakeRect(35, NSHeight(_containerView.frame) - 20, image_AudioPlayerPin().size.width, image_AudioPlayerPin().size.height)];
    
    [_pinButton setBackgroundImage:image_AudioPlayerPin() forControlState:BTRControlStateNormal];
    
    [_containerView addSubview:_pinButton];
    
    [_pinButton addBlock:^(BTRControlEvents events) {
        
        [strongSelf setLevel:self.level == NSNormalWindowLevel ? NSScreenSaverWindowLevel : NSNormalWindowLevel];
        
        [strongSelf.pinButton setImage:self.level == NSNormalWindowLevel ? image_AudioPlayerPin() : image_AudioPlayerPinActive() forControlState:BTRControlStateNormal];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    
    
    _showPlayListButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(_containerView.frame) - 30, NSHeight(_containerView.frame) - 30, 25, 25)];
    
    [_showPlayListButton setImage:image_AudioPlayerList() forControlState:BTRControlStateNormal];
    
    [_showPlayListButton addBlock:^(BTRControlEvents events) {
        
        [strongSelf showOrHidePlayList];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    [_containerView addSubview:_showPlayListButton];
    
}



-(void)playOrPause {
    
    
    if(!_currentItem) {
        [self nextTrack];
        return;
    }
    
    if(self.playerState == TGAudioPlayerStatePlaying) {
        [self pause];
    } else {
        [self play:self.currentTime];
    }
}

-(void)showOrHidePlayList {
    self.windowState = _windowState == TGAudioPlayerWindowStateMini ? TGAudioPlayerWindowStatePlayList : TGAudioPlayerWindowStateMini;
}

-(void)setWindowState:(TGAudioPlayerWindowState)windowState {
    _windowState = windowState;
    
    if(_windowState == TGAudioPlayerWindowStatePlayList) {
        [_playListContainerView onShow];
    }
    
    [self updateWindowWithHeight:_windowState == TGAudioPlayerWindowStateMini ? MINI_PHEIGHT : FULL_PHEIGHT animate:YES];
}


-(void)updateWindowWithHeight:(float)height animate:(BOOL)animate {
    
    [self.showPlayListButton setImage:_windowState == TGAudioPlayerWindowStateMini ? image_AudioPlayerList() : image_AudioPlayerListActive() forControlState:BTRControlStateNormal];
    
    NSRect frame = [self frame];
    
    float dif = abs(frame.size.height - height);
    
    if(frame.size.height > height) {
        frame.origin.y+=dif;
    } else {
        frame.origin.y-=dif;
    }
    
    frame.size.height = height;
    
    [self setFrame:frame display:YES animate:animate];
}


-(void)playAnimationForName {
    
    [_nameTextField setFrameOrigin:NSMakePoint(0, NSMinY(_nameTextField.frame))];
    [_nameTextField pop_removeAllAnimations];
    
    
    if(NSWidth(_nameTextField.frame) > NSWidth(_nameContainer.frame) && !_mouseInWindow) {
        
        POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:@"slide"];
        
        int w = NSWidth(_nameContainer.frame) - NSWidth(_nameTextField.frame);
        
        animation.duration = ceil((float)abs(w)/24.0f);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        animation.toValue = @(w);
        
        animation.removedOnCompletion = YES;
        
        
        animation.property = [POPAnimatableProperty propertyWithName:@"slide" initializer:^(POPMutableAnimatableProperty *prop) {
            
            [prop setReadBlock:^(TMTextField *layer, CGFloat values[]) {
                values[0] = layer.frame.origin.x;
            }];
            
            [prop setWriteBlock:^(TMTextField *layer, const CGFloat values[]) {
                [layer setFrameOrigin:NSMakePoint(roundf(values[0]), NSMinY(layer.frame))];
            }];
            
           prop.threshold = 1;
        }];
        
        [_nameTextField pop_addAnimation:animation forKey:@"slide"];
       
    }
    
}




-(void)mouseEntered:(NSEvent *)theEvent {
    self.mouseInWindow = YES;
}

-(void)mouseExited:(NSEvent *)theEvent {
    self.mouseInWindow = NO;
}


-(void)setMouseInWindow:(BOOL)mouseInWindow {
    _mouseInWindow = mouseInWindow;
    [_progressView setShowDivider:mouseInWindow];
    if(mouseInWindow) {
       // [self makeKeyAndOrderFront:self];
    }
    [self playAnimationForName];
}

+(void)show:(TL_conversation *)conversation playerState:(TGAudioPlayerWindowState)state {
    [self instance].windowState = state;
    [self show:conversation];
    [self instance].autoStart = NO;
}

+(void)show:(TL_conversation *)conversation {
    [[self instance] show:conversation];
    [self instance].autoStart = YES;
    [[self instance] makeKeyAndOrderFront:nil];
    
}

+(MessageTableItemAudioDocument *)currentItem {
    return [self instance].currentItem;
}

+(void)hide {
    [[self instance] orderOut:nil];
    [self instance]->_windowState = TGAudioPlayerWindowStateMini;
    [[self instance] updateWindowWithHeight:MINI_PHEIGHT animate:NO];
}


-(void)show:(TL_conversation *)conversation {
    
    if([self isVisible] && _conversation == conversation)
        return;
    
    _conversation = conversation;
    [self updateWithItem:nil];
    _currentItem = nil;
    [_playListContainerView setConversation:_conversation];
    if(![self isVisible])
    {
        
        NSScreen *screen = [NSScreen mainScreen];
        [self setFrameOrigin:NSMakePoint(roundf((screen.frame.size.width - self.frame.size.width) / 2),
                                         roundf((screen.frame.size.height - self.frame.size.height) / 2))];
    }
}

+(TGAudioPlayerState)playerState {
    return [[self instance] playerState];
}

-(void)updateWithItem:(MessageTableItemAudioDocument *)item {
    
    [_nameTextField setAttributedStringValue:item.id3AttributedStringHeader];
    [_nameTextField sizeToFit];
    [_progressView setDownloadProgress:0];
    
    if(NSWidth(_nameTextField.frame) < NSWidth(_nameContainer.frame))
    {
        [_nameTextField setFrameSize:NSMakeSize(NSWidth(_nameContainer.frame), NSHeight(_nameTextField.frame))];
    }
    
    [_nameTextField setFrameOrigin:NSMakePoint(0, 0)];
    
    [self playAnimationForName];
    
    [_progressView setDownloadProgress:0];
    
    [_playListContainerView setSelectedId:_currentItem.message.randomId];
    
}


-(void)makeKeyAndOrderFront:(id)sender {
    [super makeKeyAndOrderFront:self];
    
    
    [self makeFirstResponder:_playListContainerView];
    
    
    _isVisibility = YES;
}

-(void)orderOut:(id)sender {
    [super orderOut:sender];
    _isVisibility = NO;
    [self.currentItem.downloadItem removeEvent:_downloadEventListener];
    _downloadEventListener = nil;
    [self clear];
}


-(void)clear {
    [self stopPlayer];
    [_playListContainerView setConversation:nil];
}

-(void)setPlayerState:(TGAudioPlayerState)playerState {
    _playerState = playerState;
    
    [self notifyAllListeners];
    
    [_playButton setBackgroundImage:playerState == TGAudioPlayerStatePlaying ? image_AudioPlayerPause() : image_AudioPlayerPlay() forControlState:BTRControlStateNormal];
}

-(void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    [self.progressView setCurrentProgress:(self.currentTime/globalAudioPlayer().duration) * 100];
    [_rightDurationField setStringValue:[NSString stringWithFormat:@"-%@",[NSString durationTransformedValue:globalAudioPlayer().duration - self.currentTime]]];
    [_leftDurationField setStringValue:[NSString stringWithFormat:@"%@",[NSString durationTransformedValue:self.currentTime]]];
}

-(void)play:(NSTimeInterval)fromPosition {
    
    self.playerState = TGAudioPlayerStatePlaying;
    
    [globalAudioPlayer() stop];
    if(globalAudioPlayer().delegate != self)
        [globalAudioPlayer().delegate audioPlayerDidFinishPlaying:globalAudioPlayer()];
    setGlobalAudioPlayer([TGAudioPlayer audioPlayerForPath:[_currentItem path]]);
    
    if(globalAudioPlayer()) {
        [globalAudioPlayer() setDelegate:self];
        [globalAudioPlayer() playFromPosition:fromPosition];
        
        _currentItem.state = AudioStatePlaying;
        [self startTimer];
    }
}

- (void)pause {
    [globalAudioPlayer() pause];
    self.playerState = TGAudioPlayerStatePaused;
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
            
            if(_currentItem.state != AudioStatePlaying) {
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
    _currentItem.state = AudioStateWaitPlaying;
    self.playerState = TGAudioPlayerStatePaused;
    self.currentTime = 0;
    [_progressView setCurrentProgress:0];
    
}

-(void)nextTrack {
    [_playListContainerView selectNext];
}

-(void)prevTrack {
    [_playListContainerView selectPrev];
}

+(void)pause {
    if([self instance].playerState == TGAudioPlayerStatePlaying)
    {
        [[self instance] pause];
        [[self instance] setPlayerState:TGAudioPlayerStateForcePaused];
    }
    
}

+(void)resume {
    if([self instance].playerState == TGAudioPlayerStateForcePaused)
        [[self instance] play:[self instance].currentTime];
}

+(BOOL)autoStart {
    return [self instance].autoStart;
}


+(void)addEventListener:(id<TGAudioPlayerWindowDelegate>)delegate {
    [[self instance] addEventListener:delegate];
}
+(void)removeEventListener:(id<TGAudioPlayerWindowDelegate>)delegate {
    [[self instance] removeEventListener:delegate];
}


-(void)addEventListener:(id<TGAudioPlayerWindowDelegate>)delegate {
    if([_eventListeners indexOfObject:delegate] == NSNotFound)
    {
        [_eventListeners addObject:delegate];
    }
}

-(void)removeEventListener:(id<TGAudioPlayerWindowDelegate>)delegate {
    [_eventListeners removeObject:delegate];
}

-(void)notifyAllListeners {
    [_eventListeners enumerateObjectsUsingBlock:^(id<TGAudioPlayerWindowDelegate> obj, NSUInteger idx, BOOL *stop) {
        [obj playerDidChangedState:self.currentItem playerState:self.playerState];
    }];
}


- (void)audioPlayerDidFinishPlaying:(TGAudioPlayer *)audioPlayer {
    if(self.playerState == TGAudioPlayerStatePlaying)
        [self nextTrack];
}
- (void)audioPlayerDidStartPlaying:(TGAudioPlayer *)audioPlayer {
    
}

+(void)setCurrentItem:(MessageTableItemAudioDocument *)audioItem {
    [[self instance] setCurrentItem:audioItem];
}


-(void)setCurrentItem:(MessageTableItemAudioDocument *)audioItem {
    
    [_currentItem.downloadItem removeEvent:_downloadEventListener];
    
    if(_currentItem == audioItem)
    {
        [self playOrPause];
        return;
    }
    
    [_currentItem.downloadItem removeEvent:_downloadEventListener];
    
    _currentItem = audioItem;

    
    self.currentTime = 0;
    
    self.mouseInWindow = NSPointInRect([_windowContainerView convertPoint:[self convertScreenToBase:[NSEvent mouseLocation]] fromView:nil], _containerView.frame);
    
    
    
    if([_currentItem isset]) {
        [_progressView setDisableChanges:NO];
        [self play:self.currentTime];
    } else {
        [_currentItem startDownload:NO force:YES];
        [self updateDownloadListener];
        [self stopPlayer];
    }
    
    
    [self updateWithItem:_currentItem];
    
}


-(void)updateDownloadListener {
    
    
    if(_currentItem.downloadItem) {
        
        [_progressView setDisableChanges:YES];
        
        weak();
       
        [self.progressView setDownloadProgress:_currentItem.downloadItem.progress];
        
        
        [_currentItem.downloadItem removeEvent:_downloadEventListener];
        
        _downloadEventListener = [[DownloadEventListener alloc] init];
        
        [_currentItem.downloadItem addEvent:_downloadEventListener];
        
        
        [_downloadEventListener setCompleteHandler:^(DownloadItem * item) {
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                
                [weakSelf.progressView setDisableChanges:NO];
                
                [weakSelf.progressView setDownloadProgress:0];
                
                [weakSelf play:weakSelf.currentTime];
                
                [weakSelf.playListContainerView reloadData];
                
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



+(TGAudioPlayerWindow *)instance {
    static TGAudioPlayerWindow *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TGAudioPlayerWindow alloc] initWithContentRect:NSMakeRect(100, 100, 350, MINI_PHEIGHT) styleMask:NSBorderlessWindowMask | NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]];
        [instance setLevel:NSNormalWindowLevel];
        [instance setOpaque:NO];
        [instance setAcceptsMouseMovedEvents:YES];
        [instance setHasShadow:YES];
        instance.backgroundColor = [NSColor clearColor];
    });
    
    return instance;
}

-(BOOL)becomeFirstResponder {
    return [_containerView becomeFirstResponder];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end



