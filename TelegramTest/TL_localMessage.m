//
//  TL_localMessage.m
//  Telegram P-Edition
//
//  Created by keepcoder on 10.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_localMessage.h"
#import "TL_localMessageService.h"
#import "TL_localMessageForwarded.h"
@implementation TL_localMessage

+(TL_localMessage *)createWithN_id:(int)n_id from_id:(int)from_id to_id:(TGPeer *)to_id n_out:(Boolean)n_out unread:(Boolean)unread date:(int)date message:(NSString *)message media:(TGMessageMedia *)media fakeId:(int)fakeId randomId:(long)randomId state:(DeliveryState)state  {
    
    TL_localMessage *msg = [[TL_localMessage alloc] init];
    msg.n_id = n_id == 0 ? fakeId : n_id;
    msg.from_id = from_id;
    msg.to_id = to_id;
    msg.n_out = n_out;
    msg.unread = unread;
    msg.date = date;
    msg.message = message;
    msg.media = media;
    msg.dstate = state;
    msg.fakeId = fakeId;
    msg.randomId = randomId;
    return msg;
}

-(id)init {
    if(self = [super init]) {
        _dstate = DeliveryStateNormal;
    }
    
    return self;
}


-(void)setDstate:(DeliveryState)dstate {
    BOOL needUpdate = dstate != self.dstate;
    self->_dstate = dstate;
    if(needUpdate)
        [Notification perform:MESSAGE_CHANGED_DSTATE data:@{KEY_MESSAGE:self}];
}


+(TL_localMessage *)convertReceivedMessage:(TGMessage *)message {
    
    TL_localMessage *msg;
    
    if([message isKindOfClass:[TL_messageService class]]) {
        msg = [TL_localMessageService createWithN_id:message.n_id from_id:message.from_id to_id:message.to_id n_out:message.n_out unread:message.unread date:message.date action:message.action fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
    } else if([message isKindOfClass:[TL_messageForwarded class]]) {
        msg = [TL_localMessageForwarded createWithN_id:message.n_id fwd_from_id:message.fwd_from_id fwd_date:message.fwd_date from_id:message.from_id to_id:message.to_id n_out:message.n_out unread:message.unread date:message.date message:message.message media:message.media fakeId:[MessageSender getFakeMessageId] randomId:rand_long() fwd_n_id:message.n_id state:DeliveryStateNormal];
    } else {
        msg = [TL_localMessage createWithN_id:message.n_id from_id:message.from_id to_id:message.to_id n_out:message.n_out unread:message.unread date:message.date message:message.message media:message.media fakeId:[MessageSender getFakeMessageId] randomId:rand_long() state:DeliveryStateNormal];
    };
    
    return msg;
}

+(void)convertReceivedMessages:(NSMutableArray *)messages {
    for (int i = 0; i < messages.count; i++) {
        if(![messages[i] isKindOfClass:[TL_localMessage class]]) {
            messages[i] = [TL_localMessage convertReceivedMessage:messages[i]];
        }
    }
}

- (void)save:(BOOL)updateConversation {
    [[Storage manager] insertMessage:self completeHandler:nil];
    [[MessagesManager sharedManager] TGsetMessage:self];
    if(updateConversation && self.n_id != self.dialog.top_message) {
        [[DialogsManager sharedManager] updateTop:self needUpdate:YES update_real_date:NO];
    }
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
    [stream writeInt:self.fakeId];
    [stream writeInt:self.dstate];
    [stream writeLong:self.randomId];
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
    self.fakeId = [stream readInt];
    self.dstate = [stream readInt];
    self.randomId = [stream readLong];
}

@end
