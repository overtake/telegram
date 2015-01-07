//
//  AcceptKeySecretSenderItem.h
//  Telegram
//
//  Created by keepcoder on 02.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"

@interface AcceptKeySecretSenderItem : SecretSenderItem
-(id)initWithConversation:(TL_conversation *)conversation exchange_id:(long)exchange_id g_b:(NSData *)g_b key_fingerprint:(long)key_fingerprint;
@end
