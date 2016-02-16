//
//  TL_localMessage_old46.m
//  Telegram
//
//  Created by keepcoder on 16/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TL_localMessage_old46.h"

@implementation TL_localMessage_old46



-(void)serialize:(SerializedData*)stream {
    [stream writeInt:self.flags];
    [stream writeInt:self.n_id];
    if(self.flags & (1 << 8)) {[stream writeInt:self.from_id];}
    [TLClassStore TLSerialize:self.to_id stream:stream];
    if(self.flags & (1 << 2)) {[ClassStore TLSerialize:self.fwd_from_id stream:stream];}
    if(self.flags & (1 << 2)) [stream writeInt:self.fwd_date];
    if(self.flags & (1 << 11)) {[stream writeInt:self.via_bot_id];}
    if(self.flags & (1 << 3)) [stream writeInt:self.reply_to_msg_id];
    [stream writeInt:self.date];
    [stream writeString:self.message];
    if(self.flags & (1 << 9)) {[ClassStore TLSerialize:self.media stream:stream];}
    [stream writeInt:self.fakeId];
    [stream writeInt:self.dstate];
    [stream writeLong:self.randomId];
    if(self.flags & (1 << 6))
        [ClassStore TLSerialize:self.reply_markup stream:stream];
    if(self.flags & (1 << 7)) {//Serialize FullVector
        [stream writeInt:0x1cb5c415];
        {
            NSInteger tl_count = [self.entities count];
            [stream writeInt:(int)tl_count];
            for(int i = 0; i < (int)tl_count; i++) {
                TLMessageEntity* obj = [self.entities objectAtIndex:i];
                [ClassStore TLSerialize:obj stream:stream];
            }
        }}
    
    if(self.flags & (1 << 10)) {[stream writeInt:self.views];}
    
    
    
}
-(void)unserialize:(SerializedData*)stream {
    self.flags = [stream readInt];
    self.n_id = [stream readInt];
    if(self.flags & (1 << 8)) {self.from_id = [stream readInt];}
    self.to_id = [TLClassStore TLDeserialize:stream];
    if(self.flags & (1 << 2)) {self.fwd_from_id = [ClassStore TLDeserialize:stream];}
    if(self.flags & (1 << 2)) self.fwd_date = [stream readInt];
    if(self.flags & (1 << 11)) {self.via_bot_id = [stream readInt];}
    if(self.flags & (1 << 3)) self.reply_to_msg_id = [stream readInt];
    self.date = [stream readInt];
    self.message = [stream readString];
    if(self.flags & (1 << 9)) {self.media = [ClassStore TLDeserialize:stream];}
    self.fakeId = [stream readInt];
    self.dstate = [stream readInt];
    self.randomId = [stream readLong];
    if(self.flags & (1 << 6))
        self.reply_markup = [ClassStore TLDeserialize:stream];
    if(self.flags & (1 << 7)) {//UNS FullVector
        [stream readInt];
        {
            if(!self.entities)
                self.entities = [[NSMutableArray alloc] init];
            int count = [stream readInt];
            for(int i = 0; i < count; i++) {
                TLMessageEntity* obj = [ClassStore TLDeserialize:stream];
                if(obj != nil && [obj isKindOfClass:[TLMessageEntity class]])
                    [self.entities addObject:obj];
                else
                    break;
            }
        }}
    
    
    if(self.flags & (1 << 10)) {self.views = [stream readInt];}
    
}

@end
