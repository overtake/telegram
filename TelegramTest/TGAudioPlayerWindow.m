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


typedef enum {
    TGAudioPlayerStatePlaying,
    TGAudioPlayerStatePaused
} TGAudioPlayerState;


typedef enum {
    TGAudioPlayerWindowStateMini,
    TGAudioPlayerWindowStatePlayList
} TGAudioPlayerWindowState;

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
@property (nonatomic,strong) BTRButton *playButton;
@property (nonatomic,strong) BTRButton *nextButton;
@property (nonatomic,strong) BTRButton *prevButton;
@property (nonatomic,strong) TGAudioProgressView *progressView;

@property (nonatomic,strong) BTRButton *showPlayListButton;

@property (nonatomic,strong) NSImageView *imageView;
@property (nonatomic,strong) TMTextField *durationField;

@property (nonatomic,strong) TMView *controlsContrainer;


@property (nonatomic,strong) TMTextField *nameTextField;
@property (nonatomic,strong) TMView *nameContainer;


@property (nonatomic,strong) NSArray *items;
@property (nonatomic,assign) TGAudioPlayerState playerState;
@property (nonatomic,assign) NSTimeInterval currentTime;

@property (nonatomic,assign) BOOL mouseInWindow;


@property (nonatomic,assign) TGAudioPlayerWindowState windowState;







@end

@implementation TGAudioPlayerWindow




-(instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    if(self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen]) {
        [self initialize];
    }
    
    return self;
}

-(void)initialize {
    
    
    _windowContainerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth([self.contentView bounds]), 44)];
    _windowContainerView.autoresizingMask = NSViewHeightSizable;
    
    _windowContainerView.isFlipped = YES;
    _windowContainerView.backgroundColor = NSColorFromRGB(0xEEEEEE);
    _windowContainerView.wantsLayer = YES;
    _windowContainerView.layer.cornerRadius = 4;
    
    [self.contentView addSubview:_windowContainerView];
    
    
    
    _containerView = [[TGAudioPlayerContainerView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_windowContainerView.frame), 44)];
    _containerView.controller = self;
    _containerView.movableWindow = YES;
    
    [_windowContainerView addSubview:_containerView];
    
    _controlsContrainer = [[TMView alloc] initWithFrame:NSMakeRect(75, 0, 165, NSHeight(_containerView.frame))];
    
    [_containerView addSubview:_controlsContrainer];
    
    
    _playListContainerView = [[TGAudioPlayerListView alloc] initWithFrame:NSMakeRect(0, 44, NSWidth(_windowContainerView.frame), 508 - NSHeight(_containerView.frame))];

    _playListContainerView.backgroundColor = [NSColor whiteColor];
    
    
    [_playListContainerView setChangedAudio:^(MessageTableItemAudioDocument *audioItem) {
        [TGAudioPlayerWindow setCurrentItem:audioItem];
    }];
    
    [_windowContainerView addSubview:_playListContainerView];
    
    
    _closeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(5, NSHeight(_containerView.frame) - image_MiniPlayerClose().size.height - 5, image_MiniPlayerClose().size.width, image_MiniPlayerClose().size.height)];
    
    [_closeButton setBackgroundImage:image_MiniPlayerClose() forControlState:BTRControlStateNormal];
    
    [_containerView addSubview:_closeButton];
    
    [_closeButton addBlock:^(BTRControlEvents events) {
        
        [TGAudioPlayerWindow hide];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    
    
    
    _playButton = [[BTRButton alloc] init];
    _prevButton = [[BTRButton alloc] init];
    _nextButton = [[BTRButton alloc] init];
    
    weakify();
    
    
    [_prevButton addBlock:^(BTRControlEvents events) {
        [strongSelf prevTrack];
    } forControlEvents:BTRControlEventMouseDownInside];
    
    [_nextButton addBlock:^(BTRControlEvents events) {
        [strongSelf nextTrack];
    } forControlEvents:BTRControlEventMouseDownInside];
    
    [_playButton addBlock:^(BTRControlEvents events) {
        
        [strongSelf playOrPause];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    
    [_playButton setBackgroundImage:image_MiniPlayerPlay() forControlState:BTRControlStateNormal];
    
    
    [_playButton setFrameSize:image_MiniPlayerPlay().size];
    
    [_playButton setCenterByView:_controlsContrainer];

    
    [_prevButton setBackgroundImage:image_MiniPlayerPrev() forControlState:BTRControlStateNormal];
    
    [_prevButton setFrameSize:image_MiniPlayerPrev().size];
    
    [_prevButton setFrameOrigin:NSMakePoint(NSMinX(_playButton.frame) - NSWidth(_prevButton.frame), NSMinY(_playButton.frame))];
    
    
    [_nextButton setBackgroundImage:image_MiniPlayerNext() forControlState:BTRControlStateNormal];
    
    [_nextButton setFrameSize:image_MiniPlayerNext().size];
    
    [_nextButton setFrameOrigin:NSMakePoint(NSMaxX(_playButton.frame), NSMinY(_playButton.frame))];
    
    
    
    
    [_nextButton setFrameOrigin:NSMakePoint(NSMinX(_nextButton.frame), NSHeight(_controlsContrainer.frame) - NSHeight(_nextButton.frame) - 0)];
    [_prevButton setFrameOrigin:NSMakePoint(NSMinX(_prevButton.frame), NSHeight(_controlsContrainer.frame) - NSHeight(_prevButton.frame) - 0)];
    [_playButton setFrameOrigin:NSMakePoint(NSMinX(_playButton.frame), NSHeight(_controlsContrainer.frame) - NSHeight(_playButton.frame) - 0)];
    
    [_controlsContrainer addSubview:_nextButton];
    [_controlsContrainer addSubview:_prevButton];
    [_controlsContrainer addSubview:_playButton];
    
    
    
    _progressView = [[TGAudioProgressView alloc] initWithFrame:NSMakeRect(0, 3, 165, 10)];
    
    [_progressView setProgressCallback:^(float progress) {
        
        if(globalAudioPlayer()) {
            strongSelf.currentTime = globalAudioPlayer().duration * (progress/100);
            
            if(strongSelf.playerState == TGAudioPlayerStatePlaying) {
                [globalAudioPlayer() playFromPosition:strongSelf.currentTime];
            }
        }

    }];
    
    [_controlsContrainer addSubview:_progressView];
    
    _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(22, 0, 45, NSHeight(_containerView.frame))];
    
    NSImage *thumbImage = image_MiniPlayerDefaultCover();
    
    _imageView.image = thumbImage;
    
    [_containerView addSubview:_imageView];
    
    
    _durationField = [TMTextField defaultTextField];
    
    [_durationField setStringValue:@"-0:03"];
    
    
    [_durationField setFont:TGSystemFont(10)];
    [_durationField setTextColor:NSColorFromRGB(0x7F7F7F)];
    
    [_durationField setFrame:NSMakeRect(NSMaxX(_controlsContrainer.frame) + 1, 5, 35, 12)];
    
    [_containerView addSubview:_durationField];
    
    _nameContainer = [[TMView alloc] initWithFrame:NSMakeRect(75, 13, NSWidth(_controlsContrainer.frame), 31)];
    
    [_nameContainer setHidden:YES];
    
    _nameContainer.backgroundColor = NSColorFromRGB(0xEEEEEE);
    
    _nameTextField = [TMTextField defaultTextField];
    _nameTextField.wantsLayer = YES;
    _nameTextField.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
    
    [_nameContainer addSubview:_nameTextField];
    
    [_containerView addSubview:_nameContainer];
    
    
    
    _showPlayListButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(_containerView.frame) - 30, NSHeight(_containerView.frame) - 30, 25, 25)];
    
    [_showPlayListButton setImage:image_MiniPlayerPlaylist() forControlState:BTRControlStateNormal];
    
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
    
    [self updateWindowWithHeight:_windowState == TGAudioPlayerWindowStateMini ? 44 : 508 animate:YES];
}


-(void)updateWindowWithHeight:(float)height animate:(BOOL)animate {
    
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
    [_nameContainer setHidden:mouseInWindow || !_currentItem];
    [_progressView setShowDivider:mouseInWindow];
    if(mouseInWindow) {
        [self makeKeyAndOrderFront:self];
    }
    [self playAnimationForName];
}

+(void)show:(TL_conversation *)conversation {
    
    [[self instance] show:conversation];
    
    [[self instance] makeKeyAndOrderFront:nil];
    
}

+(void)hide {
    [[self instance] orderOut:nil];
}


-(void)show:(TL_conversation *)conversation {
    _conversation = conversation;
    [_playListContainerView setConversation:_conversation];
    [self updateWithItem:nil];
    [self setFrameOrigin:[NSEvent mouseLocation]];
}



-(void)updateWithItem:(MessageTableItemAudioDocument *)item {
    
    [_nameTextField setStringValue:[item fileName]];
    [_nameTextField sizeToFit];
    [_nameTextField setFrameOrigin:NSMakePoint(0, NSHeight(_nameContainer.frame) - NSHeight(_nameTextField.frame) - 5)];
    
    [self playAnimationForName];
    
    [_progressView setDownloadProgress:0];
    
    [_playListContainerView setSelectedId:_currentItem.message.randomId];
    
    
    NSImage *thumbImage = image_MiniPlayerDefaultCover(); // previewImageForDocument(item.path);
    
    _imageView.image = thumbImage;
}


-(void)makeKeyAndOrderFront:(id)sender {
    [super makeKeyAndOrderFront:self];
    
    
    [self makeFirstResponder:_playListContainerView];
    
    
    _isVisibility = YES;
}

-(void)orderOut:(id)sender {
    [super orderOut:sender];
    _isVisibility = NO;
    [self clear];
}


-(void)clear {
    [self stopPlayer];
    [_playListContainerView setConversation:nil];
}

-(void)setPlayerState:(TGAudioPlayerState)playerState {
    _playerState = playerState;
    
    [_playButton setBackgroundImage:playerState == TGAudioPlayerStatePlaying ? image_MiniPlayerPause() : image_MiniPlayerPlay() forControlState:BTRControlStateNormal];
}

-(void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    [self.progressView setCurrentProgress:(self.currentTime/globalAudioPlayer().duration) * 100];
    [_durationField setStringValue:[NSString stringWithFormat:@"-%@",[NSString durationTransformedValue:globalAudioPlayer().duration - self.currentTime]]];
}

-(void)play:(NSTimeInterval)fromPosition {
    
    self.playerState = TGAudioPlayerStatePlaying;
    
    [globalAudioPlayer() stop];
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
    self.currentTime = 0;
    [_progressView setCurrentProgress:0];
    
}

-(void)nextTrack {
    [_playListContainerView selectNext];
}

-(void)prevTrack {
    [_playListContainerView selectPrev];
}

- (void)audioPlayerDidFinishPlaying:(TGAudioPlayer *)audioPlayer {
    [self nextTrack];
}
- (void)audioPlayerDidStartPlaying:(TGAudioPlayer *)audioPlayer {
    
}

+(void)setCurrentItem:(MessageTableItemAudioDocument *)audioItem {
    [[self instance] setCurrentItem:audioItem];
}


-(void)setCurrentItem:(MessageTableItemAudioDocument *)audioItem {
    
    [_currentItem.downloadItem removeEvent:audioItem.secondDownloadListener];
    
    if(_currentItem == audioItem)
    {
        [self playOrPause];
        return;
    }
    
    _currentItem = audioItem;
    
    self.currentTime = 0;
    
    self.mouseInWindow = NSPointInRect([_windowContainerView convertPoint:[self convertScreenToBase:[NSEvent mouseLocation]] fromView:nil], _containerView.frame);
    
    
    
    if([_currentItem isset]) {
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
        
        weak();
       
        [self.progressView setDownloadProgress:_currentItem.downloadItem.progress];
        
        [_currentItem.downloadItem addEvent:_currentItem.secondDownloadListener];
        
        [_currentItem.secondDownloadListener setCompleteHandler:^(DownloadItem * item) {
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                
                [weakSelf.progressView setDownloadProgress:0];
                
                [weakSelf play:weakSelf.currentTime];
                
                [weakSelf.playListContainerView reloadData];
                
                [weakSelf updateWithItem:weakSelf.currentItem];
                
            }];
            
        }];
        
        [_currentItem.secondDownloadListener setProgressHandler:^(DownloadItem * item) {
            
            [ASQueue dispatchOnMainQueue:^{
                
                [weakSelf.progressView setDownloadProgress:item.progress];
                
            }];
        }];
        
    }
}


+(TGAudioPlayerWindow *)instance {
    static TGAudioPlayerWindow *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TGAudioPlayerWindow alloc] initWithContentRect:NSMakeRect(100, 100, 280, 44) styleMask:NSBorderlessWindowMask | NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]];
        [instance setLevel:NSScreenSaverWindowLevel];
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



