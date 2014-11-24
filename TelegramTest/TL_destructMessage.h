//
//  TLEncryptedMessage.h
//  Messenger for Telegram
//
//  Created by keepcoder on 26.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MTProto.h"
#import "TL_localMessage.h"
#import "EncryptedParams.h"
@interface TL_destructMessage : TL_localMessage
@property (nonatomic,assign) int destruction_time;
@property (nonatomic,assign) int ttl_seconds;
@property (nonatomic,assign) int out_seq_no;

+(TL_destructMessage *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TLPeer*)to_id date:(int)date message:(NSString*)message media:(TLMessageMedia*)media destruction_time:(int)destruction_time randomId:(long)randomId fakeId:(int)fakeId ttl_seconds:(int)ttl_seconds out_seq_no:(int)out_seq_no dstate:(DeliveryState)dstate;

-(EncryptedParams *)params;
@end
