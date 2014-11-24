//
//  TL_messageActionSetMessageTTL.h
//  Telegram
//
//  Created by keepcoder on 28.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MTProto.h"

@interface TL_messageActionSetMessageTTL : TLMessageAction

@property (nonatomic,assign) int ttl;

+(TL_messageActionSetMessageTTL*)createWithTtl:(int)ttl;

@end
