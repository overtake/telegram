//
//  MessageTableItemAudio.h
//  Messenger for Telegram
//
//  Created by keepcoder on 05.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"
#import "TGAudioPlayer.h"


@class MessagetableCellAudioController;

@interface MessageTableItemAudio : MessageTableItem<TGAudioPlayerDelegate>

typedef enum {
    AudioStateWaitDownloading,
    AudioStateWaitPlaying,
    AudioStatePaused,
    AudioStatePlaying,
    AudioStateDownloading,
    AudioStateUploading
} AudioState;

@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) TGAudioPlayer *player;
@property (nonatomic) AudioState state;
@property (nonatomic, weak) MessagetableCellAudioController *cellView;

- (BOOL)isset;
- (NSString *)path;
- (int)size;
- (BOOL)canDownload;

@end
