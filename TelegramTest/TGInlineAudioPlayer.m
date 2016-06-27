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
@property (nonatomic,strong) TMTextField *leftDurationField;
@property (nonatomic,strong) BTRButton *closeButton;
@property (nonatomic,strong) BTRButton *showPlayListButton;
@property (nonnull,strong) BTRButton *audioPlayerVisibility;

@property (nonatomic,strong) TGAudioProgressView *progressView;
@property (nonatomic,strong) TGAudioPlayerListView *playerListView;

@property (nonatomic,strong) TGAudioGlobalController *audioController;

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
        
        
        [_playButton setBackgroundImage:image_InlineAudioPlayerPlay() forControlState:BTRControlStateNormal];
        [_playButton setBackgroundImage:image_InlineAudioPlayerPlayHover() forControlState:BTRControlStateHover];
        
        [_playButton setFrameSize:image_InlineAudioPlayerPlay().size];
        
        [_playButton setCenterByView:_leftControlsContainer];
        
        
        [_prevButton setBackgroundImage:image_InlineAudioPlayerBack() forControlState:BTRControlStateNormal];
        [_prevButton setBackgroundImage:image_InlineAudioPlayerBackHover() forControlState:BTRControlStateHover];
        
        [_prevButton setFrameSize:image_InlineAudioPlayerBack().size];
        
        [_prevButton setFrameOrigin:NSMakePoint(NSMinX(_playButton.frame) - NSWidth(_prevButton.frame) - 10, NSMinY(_playButton.frame))];
        
        
        [_nextButton setBackgroundImage:image_InlineAudioPlayerNext() forControlState:BTRControlStateNormal];
        [_nextButton setBackgroundImage:image_InlineAudioPlayerNextHover() forControlState:BTRControlStateHover];

        [_nextButton setFrameSize:image_InlineAudioPlayerNext().size];
        
        [_nextButton setFrameOrigin:NSMakePoint(NSMaxX(_playButton.frame) + 10, NSMinY(_playButton.frame))];
        

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
        
        
        _rightControlsContainer = [[TMView alloc] initWithFrame:NSMakeRect(NSWidth(self.frame) - 120, 5, 120, NSHeight(self.frame)- 10)];
        [_containerView addSubview:_rightControlsContainer];
        
        
        _containerView.autoresizingMask = NSViewMinYMargin;
        
        _leftDurationField = [TMTextField defaultTextField];
        [_leftDurationField setStringValue:@"0:00"];
        [_leftDurationField setFont:TGSystemFont(13)];
        [_leftDurationField setTextColor:NSColorFromRGB(0x7F7F7F)];
        [_leftDurationField setFrame:NSMakeRect(0, 10, 50, 18)];
        
        [_leftDurationField setCenteredYByView:_rightControlsContainer];
        
        [_rightControlsContainer addSubview:_leftDurationField];
        
        
        _closeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(_rightControlsContainer.frame) - image_AudioPlayerClose().size.width - 10, 0, image_AudioPlayerClose().size.width, image_AudioPlayerClose().size.height)];
        
        [_closeButton setBackgroundImage:image_AudioPlayerClose() forControlState:BTRControlStateNormal];
        
        [_closeButton setCenteredYByView:_rightControlsContainer];
        
        [_closeButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf hide];
            
        } forControlEvents:BTRControlEventMouseDownInside];
        
        [_rightControlsContainer addSubview:_closeButton];
        
        _showPlayListButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSMinX(_closeButton.frame) - 25 - 5, NSHeight(_rightControlsContainer.frame) - 30, 25, 25)];
        
        [_showPlayListButton setCenteredYByView:_rightControlsContainer];
        
        [_showPlayListButton setImage:image_AudioPlayerList() forControlState:BTRControlStateNormal];
        
        [_showPlayListButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf showOrHidePlayList];
            
        } forControlEvents:BTRControlEventMouseDownInside];
        
        [_rightControlsContainer addSubview:_showPlayListButton];
        
        
        
        _audioPlayerVisibility = [[BTRButton alloc] initWithFrame:NSMakeRect(NSMinX(_showPlayListButton.frame) - 25, NSHeight(_rightControlsContainer.frame) - 30, 25, 25)];
        
        [_audioPlayerVisibility setCenteredYByView:_rightControlsContainer];
        
        [_audioPlayerVisibility setImage:image_AudioPlayerVisibility() forControlState:BTRControlStateNormal];
        
        [_audioPlayerVisibility addBlock:^(BTRControlEvents events) {
             [weakSelf showAudioWindow];
        } forControlEvents:BTRControlEventMouseDownInside];
        
        [_rightControlsContainer addSubview:_audioPlayerVisibility];

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
    
    [self.showPlayListButton setImage:_style == TGAudioPlayerGlobalStyleMini ? image_AudioPlayerList() : image_AudioPlayerListActive() forControlState:BTRControlStateNormal];
    

    [animated ? self.animator : self setFrame:NSMakeRect(0, _style == TGAudioPlayerGlobalStyleMini ? (NSHeight(self.audioController.navigationController.view.frame) - (self.audioController.navigationController.currentController.isNavigationBarHidden ? 0 : NSHeight(self.audioController.navigationController.currentController.navigationBarView.frame)) - NSHeight(_containerView.frame)) : 0, NSWidth(self.frame), _style == TGAudioPlayerGlobalStyleMini ? NSHeight(_containerView.frame) : NSHeight(self.audioController.navigationController.view.frame) - (self.audioController.navigationController.currentController.isNavigationBarHidden ? 0 : NSHeight(self.audioController.navigationController.currentController.navigationBarView.frame)))];
    
    [animated ? _playerListView.animator : _playerListView setFrame:NSMakeRect(0, 0, NSWidth(self.frame), _style == TGAudioPlayerGlobalStyleMini ? 0 : (NSHeight(self.audioController.navigationController.view.frame) - (self.audioController.navigationController.currentController.isNavigationBarHidden ? 0 : NSHeight(self.audioController.navigationController.currentController.navigationBarView.frame)) - NSHeight(_containerView.frame)))];

    
}


-(void)hide {
    [self.audioController hide];
    [self.audioController.navigationController hideInlinePlayer:nil];
}


-(void)show:(TL_conversation *)conversation navigation:(TMNavigationController *)navigation {
    [_audioController setProgressView:_progressView];
    [_audioController setPlayerList:_playerListView];
    
    
    
    if(_audioController.conversation != conversation) {
        _audioController.autoStart = YES;
        [_audioController show:conversation navigation:navigation];
    } else {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"inline-player"];
        
        [self playerDidChangeItem:_audioController.currentItem];
        [self playerDidChangedState:_audioController.currentItem playerState:_audioController.pState];
        [_playerListView setConversation:conversation];
    }
}

-(void)playerDidChangeItem:(MessageTableItemAudioDocument *)item {
    
    [_textNameLabel setText:item.id3AttributedStringHeader maxWidth:NSWidth(self.frame)- NSMinX(_textNameLabel.frame) *2 ];
    [_textNameLabel setCenteredYByView:self];

}

-(void)playerDidChangeTime:(NSTimeInterval)currentTime {
    [_leftDurationField setStringValue:[NSString stringWithFormat:@"%@",[NSString durationTransformedValue:currentTime]]];
}

-(void)playerDidChangedState:(MessageTableItemAudioDocument *)item playerState:(TGAudioPlayerGlobalState)state {
    [_playButton setBackgroundImage:state == TGAudioPlayerGlobalStatePlaying ? image_InlineAudioPlayerPause() : image_InlineAudioPlayerPlay() forControlState:BTRControlStateNormal];
    [_playButton setBackgroundImage:state == TGAudioPlayerGlobalStatePlaying ? image_InlineAudioPlayerPauseHover() : image_InlineAudioPlayerPlayHover() forControlState:BTRControlStateHover];

    
}


@end
