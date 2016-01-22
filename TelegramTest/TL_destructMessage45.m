//
//  TL_destructMessage45.m
//  Telegram
//
//  Created by keepcoder on 21/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TL_destructMessage45.h"

@implementation TL_destructMessage45
+(TL_destructMessage45 *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TLPeer*)to_id date:(int)date message:(NSString*)message media:(TLMessageMedia*)media destruction_time:(int)destruction_time randomId:(long)randomId fakeId:(int)fakeId ttl_seconds:(int)ttl_seconds entities:(NSMutableArray *)entities via_bot_name:(NSString *)via_bot_name reply_to_random_id:(long)reply_to_random_id out_seq_no:(int)out_seq_no dstate:(DeliveryState)dstate {
    
    TL_destructMessage45 *obj = [[TL_destructMessage45 alloc] init];
    
    obj.flags = flags;
    obj.n_id = n_id == 0 ? fakeId : n_id;
    obj.from_id = from_id;
    obj.to_id = to_id;
    obj.date = date;
    obj.message = message;
    obj.media = media;
    obj.destruction_time = destruction_time;
    obj.randomId = randomId;
    obj.fakeId = fakeId;
    obj.ttl_seconds = ttl_seconds;
    obj.out_seq_no = out_seq_no;
    obj.dstate = dstate;
    obj.entities = entities;
    obj.via_bot_name = via_bot_name;
    obj.reply_to_random_id = reply_to_random_id;
    return obj;
}
-(void)serialize:(SerializedData*)stream {
    [stream writeInt:self.flags];
    [stream writeInt:self.n_id];
    [stream writeInt:self.from_id];
    [TLClassStore TLSerialize:self.to_id stream:stream];
    [stream writeInt:self.date];
    [stream writeString:self.message];
    [TLClassStore TLSerialize:self.media stream:stream];
    [stream writeInt:self.destruction_time];
    [stream writeLong:self.randomId];
    [stream writeInt:self.fakeId];
    [stream writeInt:self.ttl_seconds];
    [stream writeInt:self.out_seq_no];
    [stream writeInt:self.dstate];
    
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

    if(self.flags & (1 << 11)) [stream writeString:self.via_bot_name];
    if(self.flags & (1 << 3)) [stream writeLong:self.reply_to_random_id];
}
-(void)unserialize:(SerializedData*)stream {
    self.flags = [stream readInt];
    self.n_id = [stream readInt];
    self.from_id = [stream readInt];
    self.to_id = [TLClassStore TLDeserialize:stream];
    self.date = [stream readInt];
    self.message = [stream readString];
    self.media = [TLClassStore TLDeserialize:stream];
    self.destruction_time = [stream readInt];
    self.randomId = [stream readLong];
    self.fakeId = [stream readInt];
    self.ttl_seconds = [stream readInt];
    self.out_seq_no = [stream readInt];
    self.dstate = [stream readInt];
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
        }
    }
    
    if(self.flags & (1 << 11)) self.via_bot_name = [stream readString];
    if(self.flags & (1 << 3)) self.reply_to_random_id = [stream readLong];
}

-(void)setVia_bot_name:(NSString *)via_bot_name
{
    super.via_bot_name = via_bot_name;
    
    if(super.via_bot_name == nil)  { super.flags&= ~ (1 << 11) ;} else { super.flags|= (1 << 11); }
}

-(void)setReply_to_random_id:(long)reply_to_random_id {
    super.reply_to_random_id = reply_to_random_id;
    
    if(super.reply_to_random_id == 0)  { super.flags&= ~ (1 << 3) ;} else { super.flags|= (1 << 3); }
}

-(long)channelMsgId {
    return self.randomId;
}

-(id)copy {
    return [TL_destructMessage45 createWithN_id:self.n_id flags:self.flags from_id:self.from_id to_id:self.to_id date:self.date message:self.message media:self.media destruction_time:self.destruction_time randomId:self.randomId fakeId:self.fakeId ttl_seconds:self.ttl_seconds entities:self.entities via_bot_name:self.via_bot_name reply_to_random_id:self.reply_to_random_id out_seq_no:self.out_seq_no dstate:self.dstate];
}

@end
