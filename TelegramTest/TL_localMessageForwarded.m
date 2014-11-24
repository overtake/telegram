//
//  TL_localMessageForwarded.m
//  Messenger for Telegram
//
//  Created by keepcoder on 05.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_localMessageForwarded.h"

@implementation TL_localMessageForwarded

+ (TL_localMessageForwarded *)createWithN_id:(int)n_id flags:(int)flags fwd_from_id:(int)fwd_from_id fwd_date:(int)fwd_date from_id:(int)from_id to_id:(TLPeer *)to_id date:(int)date message:(NSString *)message media:(TLMessageMedia *)media fakeId:(int)fakeId randomId:(long)randomId fwd_n_id:(int)fwd_n_id state:(DeliveryState)state {
	TL_localMessageForwarded *obj = [[TL_localMessageForwarded alloc] init];
    obj.flags = flags;
	obj.n_id = n_id == 0 ? fakeId : n_id;;
	obj.fwd_from_id = fwd_from_id;
	obj.fwd_date = fwd_date;
	obj.from_id = from_id;
	obj.to_id = to_id;
	obj.date = date;
	obj.message = message;
	obj.media = media;
    obj.fakeId = fakeId;
    obj.dstate = state;
    obj.randomId = randomId;
    obj.fwd_n_id = fwd_n_id;
	return obj;
}
- (void)serialize:(SerializedData *)stream {
    [stream writeInt:self.flags];
	[stream writeInt:self.n_id];
	[stream writeInt:self.fwd_from_id];
	[stream writeInt:self.fwd_date];
	[stream writeInt:self.from_id];
	[TLClassStore TLSerialize:self.to_id stream:stream];
	[stream writeInt:self.date];
	[stream writeString:self.message];
	[TLClassStore TLSerialize:self.media stream:stream];
    [stream writeInt:self.fakeId];
    [stream writeLong:self.randomId];
    [stream writeInt:self.fwd_n_id];
    [stream writeInt:self.dstate];
    
}
- (void)unserialize:(SerializedData *)stream {
    self.flags = [stream readInt];
	self.n_id = [stream readInt];
	self.fwd_from_id = [stream readInt];
	self.fwd_date = [stream readInt];
	self.from_id = [stream readInt];
	self.to_id = [TLClassStore TLDeserialize:stream];
	self.date = [stream readInt];
	self.message = [stream readString];
	self.media = [TLClassStore TLDeserialize:stream];
    self.fakeId = [stream readInt];
    self.randomId = [stream readLong];
    self.fwd_n_id = [stream readInt];
    self.dstate = [stream readInt];
}

@end
