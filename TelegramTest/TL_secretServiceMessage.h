//
//  TL_secretServiceMessage.h
//  Telegram
//
//  Created by keepcoder on 28.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_destructMessage.h"

@interface TL_secretServiceMessage : TL_destructMessage
+ (TL_secretServiceMessage *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TLPeer *)to_id date:(int)date action:(TLMessageAction *)action fakeId:(int)fakeId randomId:(long)randomId out_seq_no:(int)out_seq_no dstate:(DeliveryState)dstate;
@end
