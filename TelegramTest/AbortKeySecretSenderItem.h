//
//  AbortKeySecretSenderItem.h
//  Telegram
//
//  Created by keepcoder on 08.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"

@interface AbortKeySecretSenderItem : SecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation exchange_id:(long)exchange_id;

@end
