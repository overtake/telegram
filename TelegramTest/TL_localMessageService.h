//
//  TL_localMessageService.h
//  Telegram
//
//  Created by keepcoder on 23.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_localMessage.h"

@interface TL_localMessageService : TL_localMessage
+ (TL_localMessageService *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TLPeer *)to_id date:(int)date action:(TLMessageAction *)action fakeId:(int)fakeId randomId:(long)randomId dstate:(DeliveryState)dstate;
@end
