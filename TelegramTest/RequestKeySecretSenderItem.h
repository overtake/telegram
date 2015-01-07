//
//  RequestKeySecretSenderItem.h
//  Telegram
//
//  Created by keepcoder on 02.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"

@interface RequestKeySecretSenderItem : SecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation exchange_id:(long)exchange_id g_a:(NSData *)g_a;

@end
