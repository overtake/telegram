//
//  MessagetableCellAudioController.h
//  Telegram
//
//  Created by keepcoder on 17.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellContainerView.h"
#import "MessageTableItemAudio.h"
#import "TGTimer.h"
@interface MessagetableCellAudioController : MessageTableCellContainerView


@property (nonatomic, strong) TMTextField *stateTextField;
@property (nonatomic, strong) MessageTableItemAudio *item;

@property (nonatomic, strong) BTRButton *playerButton;
@property (nonatomic, strong) TMTextField *durationView;
@property (nonatomic, assign) BOOL needPlayAfterDownload;
@property (nonatomic, strong) TGTimer *progressTimer;
@property (nonatomic, assign) float progress;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) BOOL acceptTimeChanger;

- (void)setDurationTextFieldString:(NSString *)string;
- (void)setStateTextFieldString:(NSString *)string;
- (void)play:(NSTimeInterval)pos;
- (void)pause;
- (void)stopPlayer;
- (void)startTimer;

-(float)progressWidth;
-(NSRect)progressRect;



NSImage *blueBackground();
NSImage *grayBackground();
NSImage *playImage();
NSImage *voicePlay();
@end
