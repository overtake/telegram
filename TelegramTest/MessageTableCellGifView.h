//
//  MessageTableCellGifView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/4/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGModernMessageCellContainerView.h"
#import "MessageTableItemGif.h"

@interface MessageTableCellGifView : TGModernMessageCellContainerView

- (void)resumeAnimation;
- (void)pauseAnimation;

@end
