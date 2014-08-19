//
//  TL_inputMessagesFilterAudio.h
//  Messenger for Telegram
//
//  Created by keepcoder on 30.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLRPC.h"

@interface TL_inputMessagesFilterAudio : TGMessagesFilter
+ (TL_inputMessagesFilterAudio *)create;
@end
