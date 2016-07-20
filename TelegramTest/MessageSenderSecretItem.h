//
//  MessageSendSecretTextItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SecretSenderItem.h"
@interface MessageSenderSecretItem : SecretSenderItem
-(id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation entities:(NSArray *)entities noWebpage:(BOOL)noWebpage additionFlags:(int)additionFlags;
-(id)initWithBotContextResult:(TLBotInlineResult *)result via_bot_name:(NSString *)via_bot_name queryId:(long)queryId conversation:(TL_conversation *)conversation;
@end
