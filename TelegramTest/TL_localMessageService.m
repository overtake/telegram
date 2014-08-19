//
//  TL_localMessageService.m
//  Telegram
//
//  Created by keepcoder on 23.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_localMessageService.h"

@implementation TL_localMessageService
+ (TL_localMessageService *)createWithN_id:(int)n_id from_id:(int)from_id to_id:(TGPeer *)to_id n_out:(BOOL)n_out unread:(BOOL)unread date:(int)date action:(TGMessageAction *)action fakeId:(int)fakeId randomId:(long)randomId dstate:(DeliveryState)dstate {
    TL_localMessageService *msg = [[TL_localMessageService alloc] init];
    
    msg.n_id = n_id == 0 ? fakeId : n_id;
    msg.from_id = from_id;
    msg.to_id = to_id;
    msg.n_out = n_out;
    msg.unread = unread;
    msg.date = date;
    msg.action = action;
    msg.dstate = dstate;
    msg.fakeId = fakeId;
    msg.randomId = randomId;
    return msg;
}

-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[[TLClassStore sharedManager] TLSerialize:self.to_id stream:stream];
	[stream writeBool:self.n_out];
	[stream writeBool:self.unread];
	[stream writeInt:self.date];
    [[TLClassStore sharedManager] TLSerialize:self.action stream:stream];
    [stream writeInt:self.fakeId];
    [stream writeInt:self.dstate];
}
-(void)unserialize:(SerializedData*)stream {
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.to_id = [[TLClassStore sharedManager] TLDeserialize:stream];
	self.n_out = [stream readBool];
	self.unread = [stream readBool];
	self.date = [stream readInt];
    self.action = [[TLClassStore sharedManager] TLDeserialize:stream];
    self.fakeId = [stream readInt];
    self.dstate = [stream readInt];
}


@end
