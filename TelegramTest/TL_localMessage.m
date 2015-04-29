//
//  TL_localMessage.m
//  Telegram P-Edition
//
//  Created by keepcoder on 10.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_localMessage.h"
#import "TL_localMessageService.h"
#import "HistoryFilter.h"


@interface TL_localMessage ()
@property (nonatomic,strong) NSUserNotification *notification;
@end

@implementation TL_localMessage

+(TL_localMessage *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TLPeer *)to_id fwd_from_id:(int)fwd_from_id fwd_date:(int)fwd_date reply_to_msg_id:(int)reply_to_msg_id date:(int)date message:(NSString *)message media:(TLMessageMedia *)media fakeId:(int)fakeId randomId:(long)randomId state:(DeliveryState)state  {
    
    TL_localMessage *msg = [[TL_localMessage alloc] init];
    msg.flags = flags;
    msg.n_id = n_id == 0 ? fakeId : n_id;
    msg.from_id = from_id;
    msg.to_id = to_id;
    msg.date = date;
    msg.fwd_from_id = fwd_from_id;
    msg.fwd_date = fwd_date;
    msg.reply_to_msg_id = reply_to_msg_id;
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



-(TL_localMessage *)replyMessage {
    
    if(self.reply_to_msg_id != 0)
    {
        
        if(!_replyMessage)
        {
            _replyMessage = [[MessagesManager sharedManager] supportMessage:self.reply_to_msg_id];
            
            if(!_replyMessage)
            {
                _replyMessage = [[MessagesManager sharedManager] find:self.reply_to_msg_id];
                
                if(!_replyMessage)
                    _replyMessage = [[Storage manager] messageById:self.reply_to_msg_id];
                
                if(_replyMessage)
                {
                    [[Storage manager] addSupportMessages:@[_replyMessage]];
                    [[MessagesManager sharedManager] addSupportMessages:@[_replyMessage]];
                }
            }
        }
        
        return _replyMessage;
    }
    
    return nil;
    
}



-(TLUser *)fromUser {
    return [[UsersManager sharedManager] find:self.from_id];
}

-(void)setDstate:(DeliveryState)dstate {
    BOOL needUpdate = dstate != self.dstate;
    self->_dstate = dstate;
    if(needUpdate)
        [Notification perform:MESSAGE_CHANGED_DSTATE data:@{KEY_MESSAGE:self}];
}


+(TL_localMessage *)convertReceivedMessage:(TLMessage *)message {
    
    TL_localMessage *msg;
    
    if([message isKindOfClass:[TL_messageService class]]) {
        msg = [TL_localMessageService createWithN_id:message.n_id flags:message.flags from_id:message.from_id to_id:message.to_id date:message.date action:message.action fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
    }  else if(![message isKindOfClass:[TL_messageEmpty class]]) {
        msg = [TL_localMessage createWithN_id:message.n_id flags:message.flags from_id:message.from_id to_id:message.to_id fwd_from_id:message.fwd_from_id fwd_date:message.fwd_date reply_to_msg_id:message.reply_to_msg_id date:message.date message:message.message media:message.media fakeId:[MessageSender getFakeMessageId] randomId:rand_long() state:DeliveryStateNormal];
    } else {
        return (TL_localMessage *) message;
    }
    
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
    if(updateConversation && (self.n_id != self.conversation.top_message || [self isKindOfClass:[TL_destructMessage class]])) {
        [[DialogsManager sharedManager] updateTop:self needUpdate:YES update_real_date:NO];
    }
}

-(void)serialize:(SerializedData*)stream {
    [stream writeInt:self.flags];
	[stream writeInt:self.n_id];
	[stream writeInt:self.from_id];
	[TLClassStore TLSerialize:self.to_id stream:stream];
    if(self.flags & (1 << 2)) [stream writeInt:self.fwd_from_id];
    if(self.flags & (1 << 2)) [stream writeInt:self.fwd_date];
    if(self.flags & (1 << 3)) [stream writeInt:self.reply_to_msg_id];
	[stream writeInt:self.date];
	[stream writeString:self.message];
	[TLClassStore TLSerialize:self.media stream:stream];
    [stream writeInt:self.fakeId];
    [stream writeInt:self.dstate];
    [stream writeLong:self.randomId];
}
-(void)unserialize:(SerializedData*)stream {
    self.flags = [stream readInt];
	self.n_id = [stream readInt];
	self.from_id = [stream readInt];
	self.to_id = [TLClassStore TLDeserialize:stream];
    if(self.flags & (1 << 2)) self.fwd_from_id = [stream readInt];
    if(self.flags & (1 << 2)) self.fwd_date = [stream readInt];
    if(self.flags & (1 << 3)) self.reply_to_msg_id = [stream readInt];
	self.date = [stream readInt];
    self.message = [stream readString];
	self.media = [TLClassStore TLDeserialize:stream];
    self.fakeId = [stream readInt];
    self.dstate = [stream readInt];
    self.randomId = [stream readLong];
}

-(int)peer_id {
    int peer_id;
    if([self.to_id chat_id] != 0) {
        if(self.to_id.class == [TL_peerSecret class] || self.to_id.class == [TL_peerBroadcast class])
            peer_id = self.to_id.chat_id;
        else
            peer_id = -self.to_id.chat_id;
    }
    else
        if([self n_out])
            peer_id = self.to_id.user_id;
        else
            peer_id = self.from_id;
    return peer_id;
}

-(TLPeer *)peer {
    
    if([self.to_id chat_id] != 0)
        return self.to_id;
    else {
        if([self n_out])
            return [TL_peerUser createWithUser_id:self.to_id.user_id];
        else
            return [TL_peerUser createWithUser_id:self.from_id];
        
    }
}



-(BOOL)n_out {
    return (self.flags & TGOUTMESSAGE) == TGOUTMESSAGE;
}


-(BOOL)unread {
    return (self.flags & TGUNREADMESSAGE) == TGUNREADMESSAGE;
}

-(BOOL)readedContent {
    return (self.flags & TGREADEDCONTENT) == 0;
}

-(void)setFlags:(int)flags {
    
    int of = self.flags;
    
    BOOL o = [self unread];
    
    [super setFlags:flags];
    
    BOOL n = [self unread];
    
    if(of != -1 && o && o != n && [self userNotification]) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:[self userNotification]];
        _notification = nil;
    }
    
}


DYNAMIC_PROPERTY(DDialog);

- (TL_conversation *)conversation {
    
    TL_conversation *dialog = [self getDDialog];
    
    if(!dialog) {
        dialog = [[DialogsManager sharedManager] find:self.peer_id];
        [self setDDialog:dialog];
    }
    
    if(!dialog) {
        dialog = [[Storage manager] selectConversation:self.peer];
        
        if(!dialog)
            dialog = [[DialogsManager sharedManager] createDialogForMessage:self];
        else
            [[DialogsManager sharedManager] add:@[dialog]];
        
        [self setDDialog:dialog];
    }
    
    
    
    return dialog;
}

-(int)filterType {
    int mask = HistoryFilterNone;
    
    if([self.media isKindOfClass:[TL_messageMediaEmpty class]]) {
        mask|=HistoryFilterText;
    }
    
    if([self.media isKindOfClass:[TL_messageMediaAudio class]]) {
        mask|=HistoryFilterAudio;
    }
    
    if([self.media isKindOfClass:[TL_messageMediaDocument class]]) {
        mask|=HistoryFilterDocuments;
    }
    
    if([self.media isKindOfClass:[TL_messageMediaVideo class]]) {
        mask|=HistoryFilterVideo;
    }
    
    if([self.media isKindOfClass:[TL_messageMediaContact class]]) {
        mask|=HistoryFilterContact;
    }
    
    if([self.media isKindOfClass:[TL_messageMediaPhoto class]]) {
        mask|=HistoryFilterPhoto;
    }
    
    return mask;
    
}

-(NSUserNotification *)userNotification {
    
    if(!_notification) {
        NSArray *notifications = [[NSUserNotificationCenter defaultUserNotificationCenter] deliveredNotifications];
        
        
        [notifications enumerateObjectsUsingBlock:^(NSUserNotification *obj, NSUInteger idx, BOOL *stop) {
            
            int msg_id = [obj.userInfo[@"msg_id"] intValue];
            
            if(msg_id  == self.n_id) {
                _notification = obj;
                *stop = YES;
            }
            
        }];
    }
    
    return _notification;
    
}

-(id)copy {
    return [TL_localMessage createWithN_id:self.n_id flags:self.flags from_id:self.from_id to_id:self.to_id fwd_from_id:self.fwd_from_id fwd_date:self.fwd_date reply_to_msg_id:self.reply_to_msg_id date:self.date message:self.message media:self.media fakeId:self.fakeId randomId:self.randomId state:self.dstate];
}


@end
