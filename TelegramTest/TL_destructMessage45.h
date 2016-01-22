//
//  TL_destructMessage45.h
//  Telegram
//
//  Created by keepcoder on 21/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TL_destructMessage.h"

@interface TL_destructMessage45 : TL_destructMessage



+(TL_destructMessage45 *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TLPeer*)to_id date:(int)date message:(NSString*)message media:(TLMessageMedia*)media destruction_time:(int)destruction_time randomId:(long)randomId fakeId:(int)fakeId ttl_seconds:(int)ttl_seconds entities:(NSMutableArray *)entities via_bot_name:(NSString *)via_bot_name reply_to_random_id:(long)reply_to_random_id out_seq_no:(int)out_seq_no dstate:(DeliveryState)dstate;
@end
