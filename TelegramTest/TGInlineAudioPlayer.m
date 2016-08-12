//
//  TGInlineAudioPlayer.m
//  Telegram
//
//  Created by keepcoder on 26/05/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGInlineAudioPlayer.h"
#import "TGAudioPlayerWindow.h"
#import "TGAudioPlayerListView.h"
#import "TGAudioProgressView.h"
#import "TGTimer.h"
#import "TGTextLabel.h"
#import "TGAudioGlobalController.h"
@interface TGInlineAudioPlayer ()<TGAudioPlayerGlobalDelegate> {
    
}
@property (nonatomic,strong) BTRButton *nextButton;
@property (nonatomic,strong) BTRButton *prevButton;
@property (nonatomic,strong) BTRButton *playButton;
@property (nonatomic,strong) TMView *leftControlsContainer;
@property (nonatomic,strong) TGTextLabel *textNameLabel;

@property (nonatomic,strong) TMView *rightControlsContainer;
@property (nonatomic,strong) BTRButton *closeButton;
@property (nonatomic,strong) BTRButton *showPlayListButton;
@property (nonatomic,strong) BTRButton *audioPlayerVisibility;
@property (nonatomic,strong) BTRButton *repeatButton;

@property (nonatomic,strong) TGAudioProgressView *progressView;
@property (nonatomic,strong) TGAudioPlayerListView *playerListView;



@property (nonatomic,assign) TGAudioPlayerGlobalStyle style;

@property (nonatomic,strong) TMView *containerView;

@end

@implementation TGInlineAudioPlayer

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(0, 0, NSWidth(self.frame), DIALOG_BORDER_WIDTH));
    
    // Drawing code here.
}


-(id)initWithFrame:(NSRect)frameRect {
    return [self initWithFrame:frameRect globalController:nil];
}

-(id)initWithFrame:(NSRect)frameRect globalController:(TGAudioGlobalController *)globalController {
    if(self = [super initWithFrame:frameRect]) {
        self.backgroundColor = [NSColor whiteColor];
        
        
        self.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
        
        weak();
        
        _playerListView = [[TGAudioPlayerListView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect), 0)];
        
        _playerListView.backgroundColor = [NSColor whiteColor];
        
        [self addSubview:_playerListView];
        
        
        _containerView = [[TMView alloc]initWithFrame:self.bounds];
        
        [self addSubview:_containerView];
        
        
        _progressView = [[TGAudioProgressView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), 10)];
        
       
        [_containerView addSubview:_progressView];
        
        _leftControlsContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 5, 110, NSHeight(self.frame) - 10)];
        
        
        
        [_containerView addSubview:_leftControlsContainer];
        
        
        _playButton = [[BTRButton alloc] init];
        _prevButton = [[BTRButton alloc] init];
        _nextButton = [[BTRButton alloc] init];
        
        
        [_prevButton addBlock:^(BTRControlEvents events) {
            [weakSelf.audioController prevTrack];
        } forControlEvents:BTRControlEventMouseDownInside];
        
        [_nextButton addBlock:^(BTRControlEvents events) {
            [weakSelf.audioController nextTrack];
        } forControlEvents:BTRControlEventMouseDownInside];
        
        [_playButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf.audioController playOrPause];
            
        } forControlEvents:BTRControlEventMouseDownInside];
        
        
        [_playButton setImage:image_InlineAudioPlayerPlay() forControlState:BTRControlStateNormal];
        
        [_playButton setFrameSize:image_InlineAudioPlayerPlay().size];
        
        [_playButton setCenterByView:_leftControlsContainer];
        
        
        [_prevButton setImage:image_InlineAudioPlayerBack() forControlState:BTRControlStateNormal];
        
        [_prevButton setFrameSize:image_InlineAudioPlayerBack().size];
        
        [_prevButton setFrameOrigin:NSMakePoint(NSMinX(_playButton.frame) - NSWidth(_prevButton.frame) - 15, NSMinY(_playButton.frame))];
        
        
        [_nextButton setImage:image_InlineAudioPlayerNext() forControlState:BTRControlStateNormal];

        [_nextButton setFrameSize:image_InlineAudioPlayerNext().size];
        
        [_nextButton setFrameOrigin:NSMakePoint(NSMaxX(_playButton.frame) + 15, NSMinY(_playButton.frame))];
        

        [_nextButton setCenteredYByView:_leftControlsContainer];
        [_prevButton setCenteredYByView:_leftControlsContainer];
        [_playButton setCenteredYByView:_leftControlsContainer];
        
        [_leftControlsContainer addSubview:_nextButton];
        [_leftControlsContainer addSubview:_prevButton];
        [_leftControlsContainer addSubview:_playButton];
        
        
        [_leftControlsContainer setCenteredYByView:self];
        

        _textNameLabel = [[TGTextLabel alloc] init];
        [_textNameLabel setFrameOrigin:NSMakePoint(NSMaxX(self.leftControlsContainer.frame) + 10, 0)];
       [_containerView addSubview:_textNameLabel];
        
        
        if(globalController == nil) {
            _audioController = [[TGAudioGlobalController alloc] init];
        } else {
            _audioController = globalController;
        }
        
        [_audioController addEventListener:self];
        
        
        _rightControlsContainer = [[TMView alloc] initWithFrame:NSMakeRect(NSWidth(self.frame) - 127, 5, 120, NSHeight(self.frame)- 10)];
        [_containerView addSubview:_rightControlsContainer];
        
        
        _containerView.autoresizingMask = NSViewMinYMargin;
        
        
        _closeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(_rightControlsContainer.frame) - image_AudioPlayerClose().size.width - 10, 0, image_AudioPlayerClose().size.width, image_AudioPlayerClose().size.height)];
        
        [_closeButton setImage:[image_AudioPlayerClose() imageTintedWithColor:GRAY_ICON_COLOR] forControlState:BTRControlStateNormal];
        
        [_closeButton setCenteredYByView:_rightControlsContainer];
        
        [_closeButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf hide];
            
        } forControlEvents:BTRControlEventMouseDownInside];
        
        [_rightControlsContainer addSubview:_closeButton];
        
//        _showPlayListButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSMinX(_closeButton.frame) - 25 - 5, NSHeight(_rightControlsContainer.frame) - 30, 25, 25)];
//        
//        [_showPlayListButton setCenteredYByView:_rightControlsContainer];
//        
//        [_showPlayListButton setImage:[image_AudioPlayerList() imageTintedWithColor:GRAY_ICON_COLOR] forControlState:BTRControlStateNormal];
//        
//        [_showPlayListButton addBlock:^(BTRControlEvents events) {
//            
//            [weakSelf showOrHidePlayList];
//            
//        } forControlEvents:BTRControlEventMouseDownInside];
//        
//        [_rightControlsContainer addSubview:_showPlayListButton];
        
        
        
        _audioPlayerVisibility = [[BTRButton alloc] initWithFrame:NSMakeRect(NSMinX(_closeButton.frame) - 33, NSHeight(_rightControlsContainer.frame) - 30, 25, 25)];
        
        [_audioPlayerVisibility setCenteredYByView:_rightControlsContainer];
        
        [_audioPlayerVisibility setImage:[image_AudioPlayerVisibility() imageTintedWithColor:GRAY_ICON_COLOR] forControlState:BTRControlStateNormal];
        
        [_audioPlayerVisibility addBlock:^(BTRControlEvents events) {
             [weakSelf showAudioWindow];
        } forControlEvents:BTRControlEventMouseDownInside];
        
        [_rightControlsContainer addSubview:_audioPlayerVisibility];
        
        
        _repeatButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSMinX(_audioPlayerVisibility.frame) - 25, NSHeight(_rightControlsContainer.frame) - 30, 25, 25)];
        [_repeatButton setCenteredYByView:_rightControlsContainer];
        
        [_repeatButton setImage:[image_Player_Repeat() imageTintedWithColor:GRAY_ICON_COLOR] forControlState:BTRControlStateNormal];
        
        [_repeatButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf.audioController setRepeat:!weakSelf.audioController.isRepeat];
            
            [weakSelf.repeatButton setImage:weakSelf.audioController.isRepeat ? [image_Player_Repeat() imageTintedWithColor:BLUE_UI_COLOR] : [image_Player_Repeat() imageTintedWithColor:GRAY_ICON_COLOR]  forControlState:BTRControlStateNormal];
            
        } forControlEvents:BTRControlEventMouseDownInside];
        
        [_rightControlsContainer addSubview:_repeatButton];

        
        

    }
    
    return self;
}

-(void)showAudioWindow {
    [_audioController.navigationController hideInlinePlayer:self.audioController];
}

-(void)showOrHidePlayList {
    
    [self setStyle:_style == TGAudioPlayerGlobalStyleMini && !self.audioController.currentItem.message.isFake ? TGAudioPlayerGlobalStyleList : TGAudioPlayerGlobalStyleMini animated:YES];
}



-(void)setStyle:(TGAudioPlayerGlobalStyle)style animated:(BOOL)animated {
    _style = style;
    
    if(_style == TGAudioPlayerGlobalStyleList) {
        [_playerListView onShow];
    }
    
    if(_style != TGAudioPlayerGlobalStyleList)
        self.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    else
        self.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin | NSViewHeightSizable;

    
    [self.showPlayListButton setImage:_style == TGAudioPlayerGlobalStyleMini ? [image_AudioPlayerList() imageTintedWithColor:GRAY_ICON_COLOR] : [image_AudioPlayerList() imageTintedWithColor:GRAY_ICON_COLOR] forControlState:BTRControlStateNormal];
    
    [animated ? self.animator : self setFrame:NSMakeRect(0, _style == TGAudioPlayerGlobalStyleMini ? (NSHeight(self.audioController.navigationController.view.frame) - (self.audioController.navigationController.currentController.isNavigationBarHidden ? 0 : NSHeight(self.audioController.navigationController.currentController.navigationBarView.frame)) - NSHeight(_containerView.frame)) : 0, NSWidth(self.frame), _style == TGAudioPlayerGlobalStyleMini ? NSHeight(_containerView.frame) : NSHeight(self.audioController.navigationController.view.frame) - (self.audioController.navigationController.currentController.isNavigationBarHidden ? 0 : NSHeight(self.audioController.navigationController.currentController.navigationBarView.frame)))];
    
    [animated ? _playerListView.animator : _playerListView setFrame:NSMakeRect(0, 0, NSWidth(self.frame), _style == TGAudioPlayerGlobalStyleMini ? 0 : (NSHeight(self.audioController.navigationController.view.frame) - (self.audioController.navigationController.currentController.isNavigationBarHidden ? 0 : NSHeight(self.audioController.navigationController.currentController.navigationBarView.frame)) - NSHeight(_containerView.frame)))];

    
}


-(void)hide {
    [self.audioController hide];
    _audioController = nil;
    [self.audioController.navigationController hideInlinePlayer:nil];
}


-(void)show:(TL_conversation *)conversation navigation:(TMNavigationController *)navigation {
    [_audioController setProgressView:_progressView];
    [_audioController setPlayerList:_playerListView];
    
    [_repeatButton setImage:!_audioController.isRepeat ? [image_Player_Repeat() imageTintedWithColor:GRAY_ICON_COLOR] : [image_Player_Repeat() imageTintedWithColor:BLUE_ICON_COLOR]  forControlState:BTRControlStateNormal];

    
    if(_audioController.conversation != conversation) {
        _audioController.autoStart = YES;
        [_audioController show:conversation navigation:navigation];
    } else {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"inline-player"];
        
        [self playerDidChangeItem:_audioController.currentItem];
        [self playerDidChangedState:_audioController.currentItem playerState:_audioController.pState];
    }
    
    [_audioPlayerVisibility setHidden:_audioController.isReversed];
    [_repeatButton setHidden:_audioController.isReversed];
}

-(void)playerDidChangeItem:(MessageTableItemAudioDocument *)item {
    
    [_textNameLabel setText:item.id3AttributedStringHeader maxWidth:NSWidth(self.containerView.frame)- NSMinX(_textNameLabel.frame) *2 ];
    [_textNameLabel setCenteredYByView:self.containerView];

}

-(void)setFrameOrigin:(NSPoint)newOrigin {
    [super setFrameOrigin:newOrigin];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_containerView setFrameSize:NSMakeSize(newSize.width, NSHeight(_containerView.frame))];
    [_progressView setFrameSize:NSMakeSize(newSize.width, NSHeight(_progressView.frame))];
    [_rightControlsContainer setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_rightControlsContainer.frame), NSMinY(_rightControlsContainer.frame))];
    if(_style == TGAudioPlayerGlobalStyleList) {
        [_playerListView setFrameSize:NSMakeSize(newSize.width, newSize.height - NSHeight(_containerView.frame))];
    }
}

-(void)mouseDown:(NSEvent *)theEvent {
    if([self.containerView mouse:[self.containerView convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_textNameLabel.frame] && !_audioController.isReversed) {
        [self showOrHidePlayList];
    }
}

-(void)mouseUp:(NSEvent *)theEvent {
    
}

-(void)playerDidChangeTime:(NSTimeInterval)currentTime {
    
}

-(void)playerDidChangedState:(MessageTableItemAudioDocument *)item playerState:(TGAudioPlayerGlobalState)state {
    [_playButton setImage:state == TGAudioPlayerGlobalStatePlaying ? image_InlineAudioPlayerPause() : image_InlineAudioPlayerPlay() forControlState:BTRControlStateNormal];
}


@end
