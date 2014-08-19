//
//  TLEncryptedMessage.m
//  Messenger for Telegram
//
//  Created by keepcoder on 26.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_destructMessage.h"

@implementation TL_destructMessage

+(TL_destructMessage *)createWithN_id:(int)n_id from_id:(int)from_id to_id:(TGPeer*)to_id n_out:(Boolean)n_out unread:(Boolean)unread date:(int)date message:(NSString*)message media:(TGMessageMedia*)media destruction_time:(int)destruction_time randomId:(long)randomId fakeId:(int)fakeId dstate:(DeliveryState)dstate {
	TL_destructMessage* obj = [[TL_destructMessage alloc] init];
	obj.n_id = n_id == 0 ? fakeId : n_id;
	obj.from_id = from_id;
	obj.to_id = to_id;
	obj.n_out = n_out;
	obj.unread = unread;
	obj.date = date;
	obj.message = message;
	obj.media = media;
    obj.destruction_time = destruction_time;
    obj.randomId = randomId;
    obj.fakeId = fakeId;
    obj.dstate = dstate;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[[TLClassStore sharedManager] TLSerialize:self.to_id stream:stream];
	[stream writeBool:self.n_out];
	[stream writeBool:self.unread];
	[stream writeInt:self.date];
	[stream writeString:self.message];
	[[TLClassStore sharedManager] TLSerialize:self.media stream:stream];
    [stream writeInt:self.destruction_time];
    [stream writeLong:self.randomId];
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
	self.message = [stream readString];
	self.media = [[TLClassStore sharedManager] TLDeserialize:stream];
    self.destruction_time = [stream readInt];
    self.randomId = [stream readLong];
    self.fakeId = [stream readInt];
    self.dstate = [stream readInt];
}
@end
