//
//  ResendSecretSenderItem.h
//  Telegram
//
//  Created by keepcoder on 09.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"

@interface ResendSecretSenderItem : SecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation start_seq:(int)start_seq end_seq:(int)end_seq;

@end
