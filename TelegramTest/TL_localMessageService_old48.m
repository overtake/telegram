//
//  TL_localMessageService_old48.m
//  Telegram
//
//  Created by keepcoder on 07/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TL_localMessageService_old48.h"

@implementation TL_localMessageService_old48
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
