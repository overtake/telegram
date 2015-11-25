//
//  TL_conversation_old34.m
//  Telegram
//
//  Created by keepcoder on 24.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TL_conversation_old34.h"

@implementation TL_conversation_old34



-(void)serialize:(SerializedData*)stream {
    [TLClassStore TLSerialize:self.peer stream:stream];
    [stream writeInt:self.top_message];
    [stream writeInt:self.unread_count];
    [stream writeInt:self.last_message_date];
    [TLClassStore TLSerialize:self.notify_settings stream:stream];
    [stream writeInt:self.last_marked_message];
    [stream writeInt:self.top_message_fake];
    [stream writeInt:self.last_marked_date];
    [stream writeInt:self.last_real_message_date];
    [stream writeInt:self.sync_message_id];
    
}
-(void)unserialize:(SerializedData*)stream {
    self.peer = [TLClassStore TLDeserialize:stream];
    self.top_message = [stream readInt];
    self.unread_count = [stream readInt];
    self.last_message_date = [stream readInt];
    self.notify_settings = [TLClassStore TLDeserialize:stream];
    self.last_marked_message = [stream readInt];
    self.top_message_fake = [stream readInt];
    self.last_marked_date = [stream readInt];
    self.last_real_message_date = [stream readInt];
    self.sync_message_id = [stream readInt];
}

@end
