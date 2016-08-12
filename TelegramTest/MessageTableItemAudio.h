//
//  MessageTableItemAudio.h
//  Messenger for Telegram
//
//  Created by keepcoder on 05.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"
#import "TGAudioPlayer.h"



@class MessageTableCellAudioView;

@interface MessageTableItemAudio : MessageTableItem<TGAudioPlayerDelegate>



@property (nonatomic, strong) NSAttributedString *duration;
@property (nonatomic, strong) TGAudioPlayer *player;
@property (nonatomic, assign) int state;
@property (nonatomic, weak) MessageTableCellAudioView *cellView;
@property (nonatomic,strong,readonly) NSArray *waveform;

@property (nonatomic,strong) NSAttributedString *nameAttributedString;
@property (nonatomic,assign) NSSize nameSize;



- (BOOL)isset;
- (NSString *)path;
- (int)size;
- (BOOL)canDownload;

-(NSArray *)emptyWaveform;

@end
