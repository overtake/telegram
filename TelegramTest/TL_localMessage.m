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
#import "NSString+FindURLs.h"

@interface TL_localMessage ()
@property (nonatomic,strong) NSUserNotification *notification;
@property (nonatomic,assign) int type;
@property (nonatomic,strong,readonly) TLChat *p_chat;
@property (nonatomic,weak) TLUser *fUser;
@end

@implementation TL_localMessage

+(TL_localMessage *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TLPeer *)to_id fwd_from_id:(TLPeer *)fwd_from_id fwd_date:(int)fwd_date reply_to_msg_id:(int)reply_to_msg_id date:(int)date message:(NSString *)message media:(TLMessageMedia *)media fakeId:(int)fakeId randomId:(long)randomId reply_markup:(TLReplyMarkup *)reply_markup  entities:(NSMutableArray *)entities views:(int)views isViewed:(BOOL)isViewed state:(DeliveryState)state  {
    
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
    msg.reply_markup = reply_markup;
    msg.entities = entities;
    msg.views = views;
    msg.viewed = isViewed;
    return msg;
}


+(TL_localMessage *)createWithN_id:(int)n_id flags:(int)flags from_id:(int)from_id to_id:(TLPeer *)to_id fwd_from_id:(TLPeer *)fwd_from_id fwd_date:(int)fwd_date reply_to_msg_id:(int)reply_to_msg_id date:(int)date message:(NSString *)message media:(TLMessageMedia *)media fakeId:(int)fakeId randomId:(long)randomId reply_markup:(TLReplyMarkup *)reply_markup entities:(NSMutableArray *)entities views:(int)views state:(DeliveryState)state pts:(int)pts isViewed:(BOOL)isViewed {
    
    TL_localMessage *msg = [self createWithN_id:n_id flags:flags from_id:from_id to_id:to_id fwd_from_id:fwd_from_id fwd_date:fwd_date reply_to_msg_id:reply_to_msg_id date:date message:message media:media fakeId:fakeId randomId:randomId reply_markup:reply_markup entities:entities views:views isViewed:isViewed state:state];
    
    msg.pts = pts;
    
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
            _replyMessage = [MessagesManager supportMessage:self.reply_to_msg_id peer_id:self.peer_id];
            
            if(_replyMessage)
            {
                [[Storage manager] addSupportMessages:@[_replyMessage]];
                [MessagesManager addSupportMessages:@[_replyMessage]];
            }
        }
        
        return _replyMessage;
    }
    
    return nil;
    
}



-(TLUser *)fromUser {
    
    if(_fUser != nil)
        return _fUser;
    else {
        if(self.from_id != 0)
            _fUser = [[UsersManager sharedManager] find:self.from_id];;
    }
    
    return _fUser;
}

-(TLUser *)fromFwdUser {
    return [[UsersManager sharedManager] find:self.fwd_from_id.user_id];
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
        msg = [TL_localMessageService createWithFlags:message.flags n_id:message.n_id from_id:message.from_id to_id:message.to_id date:message.date action:message.action fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
    }  else if(![message isKindOfClass:[TL_messageEmpty class]]) {
        msg = [TL_localMessage createWithN_id:message.n_id flags:message.flags from_id:message.from_id to_id:message.to_id fwd_from_id:message.fwd_from_id fwd_date:message.fwd_date reply_to_msg_id:message.reply_to_msg_id date:message.date message:message.message media:message.media fakeId:[MessageSender getFakeMessageId] randomId:rand_long() reply_markup:message.reply_markup entities:message.entities views:message.views isViewed:NO state:DeliveryStateNormal];
        
    } else {
        return (TL_localMessage *) message;
    }
    
    if(msg.from_id > 0)
        msg.fUser = [[UsersManager sharedManager] find:msg.from_id];
    
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
    [[Storage manager] insertMessages:@[self]];
    if(updateConversation && (self.n_id != self.conversation.top_message || [self isKindOfClass:[TL_destructMessage class]])) {
        [[DialogsManager sharedManager] updateTop:self needUpdate:YES update_real_date:NO];
    }
}

-(void)saveViews {
    [[Storage manager] updateChannelMessageViews:self.channelMsgId views:self.views];
}

-(void)serialize:(SerializedData*)stream {
    [stream writeInt:self.flags];
    [stream writeInt:self.n_id];
    if(self.flags & (1 << 8)) {[stream writeInt:self.from_id];}
    [TLClassStore TLSerialize:self.to_id stream:stream];
    if(self.flags & (1 << 2)) {[ClassStore TLSerialize:self.fwd_from_id stream:stream];}
    if(self.flags & (1 << 2)) [stream writeInt:self.fwd_date];
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



-(TLPeer *)fwd_from_id {
    if(self.class != [TL_localMessage class]) {
        return self.fwd_from_id_old != 0 ? [TL_peerUser createWithUser_id:self.fwd_from_id_old] : nil;
    }
    
    return [super fwd_from_id];
}


-(int)peer_id {
    int peer_id;
    if([self.to_id chat_id] != 0) {
        if(self.to_id.class == [TL_peerSecret class] || self.to_id.class == [TL_peerBroadcast class])
            peer_id = self.to_id.chat_id;
        else
            peer_id = -self.to_id.chat_id;
    }
    else if(self.to_id.channel_id != 0) {
        peer_id = -self.to_id.channel_id;
    } else
        if([self n_out])
            peer_id = self.to_id.user_id;
        else
            peer_id = self.from_id;
    return peer_id;
}

-(TLPeer *)peer {
    
    if([self.to_id chat_id] != 0 || self.to_id.channel_id != 0)
        return self.to_id;
    else {
        if([self n_out])
            return [TL_peerUser createWithUser_id:self.to_id.user_id];
        else
            return [TL_peerUser createWithUser_id:self.from_id];
        
    }
}

- (TLChat *) chat {
    
    if(!_p_chat && (self.peer.chat_id != 0 || self.peer.channel_id != 0)) {
        _p_chat = [[ChatsManager sharedManager] find:self.peer.chat_id == 0 ? self.peer.channel_id : self.peer.chat_id];
    }
    return _p_chat;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [TLClassStore deserialize:[aDecoder decodeObjectForKey:@"data"]])) {
        
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[TLClassStore serialize:self] forKey:@"data"];
}

-(BOOL)n_out {
    return self.flags & TGOUTMESSAGE;
}


-(BOOL)isImportantMessage {
    return self.isChannelMessage &&  ((self.flags & 2) || (self.flags & 16) || (self.flags & 256) == 0);
}

-(BOOL)isChannelMessage {
    return [self.to_id isKindOfClass:[TL_peerChannel class]];
}

-(BOOL)unread {
    return self.isChannelMessage ? self.n_out || self.n_id > TGMINFAKEID ? NO : (self.conversation.read_inbox_max_id < self.n_id || self.conversation.read_inbox_max_id > TGMINFAKEID) :  self.flags & TGUNREADMESSAGE;
}

-(BOOL)readedContent {
    return (self.flags & TGREADEDCONTENT) == 0;
}

-(BOOL)isMentioned {
    return self.flags & TGMENTIONMESSAGE;
}



DYNAMIC_PROPERTY(DDialog);

- (TL_conversation *)conversation {
    
    __block TL_conversation *dialog;
    
    dialog = [self getDDialog];
    
    if(!dialog) {
        dialog = [[DialogsManager sharedManager] find:self.peer_id];
        [self setDDialog:dialog];
    }
    
    if(!dialog) {
        if(!dialog)
            dialog = [[DialogsManager sharedManager] createDialogForMessage:self];
        else
            [[DialogsManager sharedManager] add:@[dialog]];
        
        [self setDDialog:dialog];
    }
    
    
    return dialog;
}

-(int)filterType {
    if(_type == 0)
    {
        int mask = [self.to_id isKindOfClass:[TL_peerChannel class]] ? HistoryFilterChannelMessage : HistoryFilterNone;
        
        if([self isImportantMessage])
            mask|=HistoryFilterImportantChannelMessage;
        
        if([self.media isKindOfClass:[TL_messageMediaEmpty class]] || self.media == nil) {
            mask|=HistoryFilterText;
        }
        
        if([self.media isKindOfClass:[TL_messageMediaAudio class]]) {
            mask|=HistoryFilterAudio;
        }
        
        if([self.media isKindOfClass:[TL_messageMediaDocument class]]) {
            TL_documentAttributeAudio *attr =  (TL_documentAttributeAudio *)[self.media.document attributeWithClass:[TL_documentAttributeAudio class]];
            if(attr != nil || [self.media.document.mime_type hasPrefix:@"audio/"]) {
                mask|=HistoryFilterAudioDocument;
            }
            
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
        
        NSArray *entities = [self.entities filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.class = %@",[TL_messageEntityUrl class]]];
        
        if([self.media.webpage isKindOfClass:[TL_webPage class]] || entities.count > 0) {
            mask|=HistoryFilterSharedLink;
        }
        
        _type = mask;
    }
    
    return _type;
    
}

-(NSUserNotification *)userNotification {
    
//    if(!_notification) {
//        NSArray *notifications = [[NSUserNotificationCenter defaultUserNotificationCenter] deliveredNotifications];
//        
//        
//        
//        [notifications enumerateObjectsUsingBlock:^(NSUserNotification *obj, NSUInteger idx, BOOL *stop) {
//            
//            int msg_id = [obj.userInfo[@"msg_id"] intValue];
//            
//            if(msg_id  == self.n_id) {
//                _notification = obj;
//                *stop = YES;
//            }
//            
//        }];
//    }
    
    return nil;
    
}

-(void)setMedia:(TLMessageMedia*)media
{
    [super setMedia:media];
    
    if(self.media == nil)  { self.flags&= ~ (1 << 9) ;} else { self.flags|= (1 << 9); }
}

-(void)setFrom_id:(int)from_id
{
    [super setFrom_id:from_id];
    
    if(self.from_id == 0)  { self.flags&= ~ (1 << 8) ;} else { self.flags|= (1 << 8); }
}


-(void)setEntities:(NSMutableArray*)entities
{
    [super setEntities:entities];
    
    if(self.entities == nil)  { self.flags&= ~ (1 << 7) ;} else { self.flags|= (1 << 7); }
}

-(long)channelMsgId {
    return self.isChannelMessage ? channelMsgId(self.n_id,self.peer_id) : self.n_id;
}


long channelMsgId(int msg_id, int peer_id) {
    NSMutableData *data = [NSMutableData data];
    int msgId = msg_id;
    int channelId = peer_id;
    
    msg_id = NSSwapHostIntToBig(msg_id);
    
    
    
    [data appendBytes:&msgId length:4];
    [data appendBytes:&channelId length:4];
    
    long converted;
    
    [data getBytes:&converted length:8];
    
    return converted;

}

-(id)fwdObject {
    if([self.fwd_from_id isKindOfClass:[TL_peerUser class]]) {
        return [[UsersManager sharedManager] find:self.fwd_from_id.user_id];
    } else
        return [[ChatsManager sharedManager] find:self.fwd_from_id.chat_id != 0 ? self.fwd_from_id.chat_id : self.fwd_from_id.channel_id];
}

-(id)copy {
    return [TL_localMessage createWithN_id:self.n_id flags:self.flags from_id:self.from_id to_id:self.to_id fwd_from_id:self.fwd_from_id fwd_date:self.fwd_date reply_to_msg_id:self.reply_to_msg_id date:self.date message:self.message media:self.media fakeId:self.fakeId randomId:self.randomId reply_markup:self.reply_markup entities:self.entities views:self.views state:self.dstate pts:self.pts isViewed:self.isViewed];
}

-(void)dealloc {
    
}


@end
