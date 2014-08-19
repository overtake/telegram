//
//  TL_localMessageService.h
//  Telegram
//
//  Created by keepcoder on 23.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_localMessage.h"

@interface TL_localMessageService : TL_localMessage
+ (TL_localMessageService *)createWithN_id:(int)n_id from_id:(int)from_id to_id:(TGPeer *)to_id n_out:(BOOL)n_out unread:(BOOL)unread date:(int)date action:(TGMessageAction *)action fakeId:(int)fakeId randomId:(long)randomId dstate:(DeliveryState)dstate;
@end
