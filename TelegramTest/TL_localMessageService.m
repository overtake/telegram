//
//  TL_localMessageService.m
//  Telegram
//
//  Created by keepcoder on 23.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_localMessageService.h"

@implementation TL_localMessageService
+(TL_localMessageService*)createWithFlags:(int)flags n_id:(int)n_id from_id:(int)from_id to_id:(TLPeer*)to_id date:(int)date action:(TLMessageAction*)action fakeId:(int)fakeId randomId:(long)randomId dstate:(DeliveryState)dstate {
   
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


+(TL_localMessageService *)createWithHole:(TGMessageHole *)hole {
    
    TL_localMessageService *service = [TL_localMessageService createWithFlags:16 n_id:hole.uniqueId from_id:0 to_id:[TL_peerChannel createWithChannel_id:-hole.peer_id] date:hole.date action:[TL_messageActionEmpty create] fakeId:0 randomId:rand_long() dstate:DeliveryStateNormal];
    
    service.hole = hole;
    
    return service;
}

-(void)serialize:(SerializedData*)stream {
    [stream writeInt:self.flags];
    [stream writeInt:self.n_id];
    if(self.flags & (1 << 8)) {[stream writeInt:self.from_id];}
    [ClassStore TLSerialize:self.to_id stream:stream];
    [stream writeInt:self.date];
    [ClassStore TLSerialize:self.action stream:stream];
    [stream writeLong:self.randomId];
    [stream writeInt:self.fakeId];
    [stream writeInt:self.dstate];
    
}
-(void)unserialize:(SerializedData*)stream {
    self.flags = [stream readInt];
    self.n_id = [stream readInt];
    if(self.flags & (1 << 8)) {self.from_id = [stream readInt];}
    self.to_id = [ClassStore TLDeserialize:stream];
    self.date = [stream readInt];
    self.action = [ClassStore TLDeserialize:stream];
    self.randomId = [stream readLong];
    self.fakeId = [stream readInt];
    self.dstate = [stream readInt];
}

-(TL_localMessageService *)copy {
    
    TL_localMessageService *objc = [[TL_localMessageService alloc] init];
    
    objc.flags = self.flags;
    objc.n_id = self.n_id;
    objc.from_id = self.from_id;
    objc.to_id = [self.to_id copy];
    objc.date = self.date;
    objc.action = [self.action copy];
    objc.fakeId = self.fakeId;
    objc.dstate = self.dstate;
    objc.randomId = self.randomId;
    return objc;
}


@end
