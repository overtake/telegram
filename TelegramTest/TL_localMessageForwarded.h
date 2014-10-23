//
//  TL_localMessageForwarded.h
//  Messenger for Telegram
//
//  Created by keepcoder on 05.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLRPC.h"

@interface TL_localMessageForwarded : TL_localMessage
@property (nonatomic,assign) int fwd_n_id;
+ (TL_localMessageForwarded *)createWithN_id:(int)n_id flags:(int)flags fwd_from_id:(int)fwd_from_id fwd_date:(int)fwd_date from_id:(int)from_id to_id:(TGPeer *)to_id date:(int)date message:(NSString *)message media:(TGMessageMedia *)media fakeId:(int)fakeId randomId:(long)randomId fwd_n_id:(int)fwd_n_id state:(DeliveryState)state;
@end
