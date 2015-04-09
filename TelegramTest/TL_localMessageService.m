//
//  TL_localMessageService.m
//  Telegram
//
//  Created by keepcoder on 23.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_localMessageService.h"

@implementation TL_localMessageService
+ (TL_localMessageService *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TLPeer *)to_id date:(int)date action:(TLMessageAction *)action fakeId:(int)fakeId randomId:(long)randomId dstate:(DeliveryState)dstate {
    TL_localMessageService *msg = [[TL_localMessageService alloc] init];
    msg.flags = flags;
    msg.n_id = n_id == 0 ? fakeId : n_id;
    msg.from_id = from_id;
    msg.to_id = to_id;
    msg.date = date;
    msg.action = action;
    msg.dstate = dstate;
    msg.fakeId = fakeId;
    msg.randomId = randomId;
    return msg;
}

-(void)serialize:(SerializedData*)stream {
    [stream writeInt:self.flags];
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[TLClassStore TLSerialize:self.to_id stream:stream];
	[stream writeInt:self.date];
    [TLClassStore TLSerialize:self.action stream:stream];
    [stream writeInt:self.fakeId];
    [stream writeInt:self.dstate];
}
-(void)unserialize:(SerializedData*)stream {
    self.flags = [stream readInt];
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.to_id = [TLClassStore TLDeserialize:stream];
	self.date = [stream readInt];
    self.action = [TLClassStore TLDeserialize:stream];
    self.fakeId = [stream readInt];
    self.dstate = [stream readInt];
}

-(id)copy {
    return [TL_localMessageService createWithN_id:self.n_id flags:self.flags from_id:self.from_id to_id:self.to_id date:self.date action:self.action fakeId:self.fakeId randomId:self.randomId dstate:self.dstate];
}

@end
