//
//  TLEncryptedMessage.h
//  Messenger for Telegram
//
//  Created by keepcoder on 26.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLRPC.h"
#import "TL_localMessage.h"
@interface TL_destructMessage : TL_localMessage
@property (nonatomic,assign) int destruction_time;
+(TL_destructMessage *)createWithN_id:(int)n_id from_id:(int)from_id to_id:(TGPeer*)to_id n_out:(Boolean)n_out unread:(Boolean)unread date:(int)date message:(NSString*)message media:(TGMessageMedia*)media destruction_time:(int)destruction_time randomId:(long)randomId fakeId:(int)fakeId dstate:(DeliveryState)dstate;
@end
