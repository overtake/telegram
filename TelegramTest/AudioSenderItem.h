//
//  AudioSenderItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 02.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SenderItem.h"

@interface AudioSenderItem : SenderItem
- (id)initWithPath:(NSString *)filePath forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags waveforms:(NSData *)waveforms;
@end
