//
//  MessageTableCellAudioView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 24.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellContainerView.h"

#import "DownloadQueue.h"
#import "TGOpusAudioPlayerAU.h"

@interface MessageTableCellAudioView : MessageTableCellContainerView

+ (void)stop;
- (void)stopPlayer;

@end
