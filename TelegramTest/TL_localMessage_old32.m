//
//  TL_localMessage_old32.m
//  Telegram
//
//  Created by keepcoder on 13.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TL_localMessage_old32.h"

@implementation TL_localMessage_old32


-(void)serialize:(SerializedData*)stream {
    [stream writeInt:self.flags];
    [stream writeInt:self.n_id];
    [stream writeInt:self.from_id];
    [TLClassStore TLSerialize:self.to_id stream:stream];
    if(self.flags & (1 << 2)) [stream writeInt:self.fwd_from_id_old];
    if(self.flags & (1 << 2)) [stream writeInt:self.fwd_date];
    if(self.flags & (1 << 3)) [stream writeInt:self.reply_to_msg_id];
    [stream writeInt:self.date];
    [stream writeString:self.message];
    [TLClassStore TLSerialize:self.media stream:stream];
    [stream writeInt:self.fakeId];
    [stream writeInt:self.dstate];
    [stream writeLong:self.randomId];
    if(self.flags & (1 << 6))
        [ClassStore TLSerialize:self.reply_markup stream:stream];
}
-(void)unserialize:(SerializedData*)stream {
    self.flags = [stream readInt];
    self.n_id = [stream readInt];
    self.from_id = [stream readInt];
    self.to_id = [TLClassStore TLDeserialize:stream];
    if(self.flags & (1 << 2)) self.fwd_from_id_old = [stream readInt];
    if(self.flags & (1 << 2)) self.fwd_date = [stream readInt];
    if(self.flags & (1 << 3)) self.reply_to_msg_id = [stream readInt];
    self.date = [stream readInt];
    self.message = [stream readString];
    self.media = [TLClassStore TLDeserialize:stream];
    self.fakeId = [stream readInt];
    self.dstate = [stream readInt];
    self.randomId = [stream readLong];
    if(self.flags & (1 << 6))
        self.reply_markup = [ClassStore TLDeserialize:stream];
}


@end
