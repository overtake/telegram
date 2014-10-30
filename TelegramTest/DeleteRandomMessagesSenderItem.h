//
//  DeleteRandomMessagesSenderItem.h
//  Telegram
//
//  Created by keepcoder on 28.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"

@interface DeleteRandomMessagesSenderItem : SecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation random_ids:(NSArray *)ids;

@end
