//
//  MessageSendItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SenderItem.h"
@interface MessageSenderItem : SenderItem

-(id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation noWebpage:(BOOL)noWebpage additionFlags:(int)additionFlags;

@end
