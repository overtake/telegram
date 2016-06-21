//
//  VideoSenderItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageSenderItem.h"

@interface VideoSenderItem : SenderItem
-(id)initWithPath:(NSString *)path_for_file forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags caption:(NSString *)caption;
@end
