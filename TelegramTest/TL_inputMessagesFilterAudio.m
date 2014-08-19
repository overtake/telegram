//
//  TL_inputMessagesFilterAudio.m
//  Messenger for Telegram
//
//  Created by keepcoder on 30.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_inputMessagesFilterAudio.h"

@implementation TL_inputMessagesFilterAudio
+ (TL_inputMessagesFilterAudio *)create {
	TL_inputMessagesFilterAudio *obj = [[TL_inputMessagesFilterAudio alloc] init];
	
	return obj;
}
- (void)serialize:(SerializedData *)stream {
	
}
- (void)unserialize:(SerializedData *)stream {
	
}
@end
