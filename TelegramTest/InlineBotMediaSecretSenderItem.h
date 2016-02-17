//
//  InlineBotMediaSecretSenderItem.h
//  Telegram
//
//  Created by keepcoder on 22/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"
#import "FileSecretSenderItem.h"
@interface InlineBotMediaSecretSenderItem : FileSecretSenderItem
-(id)initWithBotContextResult:(TLBotInlineResult *)result via_bot_name:(NSString *)via_bot_name conversation:(TL_conversation *)conversation;
@end
