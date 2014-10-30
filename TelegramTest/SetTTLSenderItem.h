//
//  SetTTLSenderItem.h
//  Telegram
//
//  Created by keepcoder on 28.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"

@interface SetTTLSenderItem : SecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation ttl:(int)ttl;

@end
