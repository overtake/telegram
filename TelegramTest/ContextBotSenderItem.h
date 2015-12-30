//
//  ContextBotSenderItem.h
//  Telegram
//
//  Created by keepcoder on 28/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "SenderItem.h"

@interface ContextBotSenderItem : SenderItem

-(id)initWithBotContextResult:(TLBotContextResult *)result via_bot_id:(int)via_bot_id queryId:(long)queryId additionFlags:(int)additionFlags conversation:(TL_conversation *)conversation;

@end
