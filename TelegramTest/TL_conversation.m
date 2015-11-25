//
//  TL_conversation.m
//  Messenger for Telegram
//
//  Created by keepcoder on 11.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_conversation.h"
#import "TLPeer+Extensions.h"
#import "TGPasslock.h"
#import "TL_localMessage.h"

@interface TL_conversation ()
@property (nonatomic,strong,readonly) TLUser *p_user;
@property (nonatomic,strong,readonly) TLChat *p_chat;
@end


@implementation TL_conversation
+(TL_conversation *)createWithPeer:(TLPeer *)peer top_message:(int)top_message unread_count:(int)unread_count last_message_date:(int)last_message_date notify_settings:(TLPeerNotifySettings *)notify_settings last_marked_message:(int)last_marked_message top_message_fake:(int)top_message_fake last_marked_date:(int)last_marked_date sync_message_id:(int)sync_message_id read_inbox_max_id:(int)read_inbox_max_id unread_important_count:(int)unread_important_count lastMessage:(TL_localMessage *)lastMessage {
    TL_conversation *dialog = [[TL_conversation alloc] init];
    dialog.peer = peer;
    dialog.top_message = top_message;
    dialog.unread_count = unread_count;
    dialog.last_message_date = last_message_date;
    dialog.notify_settings = notify_settings;
    dialog.last_marked_message = last_marked_message;
    dialog.top_message_fake = top_message_fake;
    dialog.last_marked_date = last_marked_date;
    dialog.last_real_message_date = last_message_date;
    dialog.dstate = DeliveryStateNormal;
    dialog.sync_message_id = sync_message_id;
    dialog.lastMessage = lastMessage;

    
    dialog.read_inbox_max_id = read_inbox_max_id;
    dialog.unread_important_count = unread_important_count;
    
    return dialog;
}


+ (TL_conversation *)createWithPeer:(TLPeer *)peer top_message:(int)top_message unread_count:(int)unread_count last_message_date:(int)last_message_date notify_settings:(TLPeerNotifySettings *)notify_settings last_marked_message:(int)last_marked_message top_message_fake:(int)top_message_fake last_marked_date:(int)last_marked_date sync_message_id:(int)sync_message_id read_inbox_max_id:(int)read_inbox_max_id unread_important_count:(int)unread_important_count lastMessage:(TL_localMessage *)lastMessage pts:(int)pts isInvisibleChannel:(BOOL)isInvisibleChannel top_important_message:(int)top_important_message {
    
    TL_conversation *conversation = [self createWithPeer:peer top_message:top_message unread_count:unread_count last_message_date:last_message_date notify_settings:notify_settings last_marked_message:last_marked_message top_message_fake:top_message_fake last_marked_date:last_marked_date sync_message_id:sync_message_id read_inbox_max_id:read_inbox_max_id unread_important_count:unread_important_count lastMessage:lastMessage];
    
    conversation.pts = pts;
    conversation.invisibleChannel = isInvisibleChannel;
    conversation.top_important_message = top_important_message;
    return conversation;
    
}

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
    [stream writeInt:self.read_inbox_max_id];
    [stream writeInt:self.unread_important_count];
    
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
    self.read_inbox_max_id = [stream readInt];
    self.unread_important_count = [stream readInt];
}

-(void)setLast_message_date:(int)last_message_date {
    self->_last_message_date = last_message_date;
    self->_last_real_message_date = last_message_date;
}

-(void)setLastMessage:(TL_localMessage *)lastMessage {
    _lastMessage = lastMessage;
}

-(BOOL)canSendMessage {
    
    if([TGPasslock isVisibility])
        return NO;
    
    if(self.type == DialogTypeSecretChat) {
        return self.encryptedChat.encryptedParams.state == EncryptedAllowed;
    }
    
    if(self.type == DialogTypeChat) {
        return !(self.chat.type != TLChatTypeNormal || self.chat.left || self.chat.isDeactivated);
    }
    
    if(self.type == DialogTypeUser && self.user.isBot)
        return  !self.user.isBot || !self.user.isBlocked;
    
    if(self.type == DialogTypeChannel)
        return ((!self.chat.isBroadcast && !self.isInvisibleChannel) || self.chat.isCreator || self.chat.isEditor) && !self.chat.isKicked && !self.chat.left && self.chat.type == TLChatTypeNormal;
    
    if(self.type == DialogTypeUser)
        return !self.user.isBlocked;
    
    return YES;
}

-(BOOL)isInvisibleChannel {

    return _invisibleChannel;
}

- (TL_broadcast *)broadcast {
    return [[BroadcastManager sharedManager] find:self.peer.peer_id];
}

-(int)universalTopMessage {
    return (self.type == DialogTypeChannel ? self.top_important_message : self.top_message);
}

-(NSString *)blockedText {
    if(self.type == DialogTypeSecretChat) {
        EncryptedParams *params = [EncryptedParams findAndCreate:self.peer.peer_id];
        
        
        if(params.state == EncryptedDiscarted) {
            return NSLocalizedString(@"MessageAction.Secret.CancelledSecretChat", nil);
        }
        
        if(params.state == EncryptedWaitOnline) {
            NSString *format = NSLocalizedString(@"MessageAction.Secret.WaitingToGetOnline", nil);
            TLUser *user = self.encryptedChat.peerUser;
            return [NSString stringWithFormat:format, user.first_name ? user.first_name : user.dialogFullName];
        }
        
    }
    
    if(self.type == DialogTypeChat || self.type == DialogTypeChannel) {
        
        if(self.type == DialogTypeChannel) {
            
            if(self.isInvisibleChannel) {
                return NSLocalizedString(@"Conversation.Action.JoinToChannel", nil);
            }
            
            if(self.chat.isKicked || self.chat.left || self.chat.type == TLChatTypeForbidden) {
                return NSLocalizedString(@"Conversation.DeleteAndExit", nil);
            }
            
            if(self.chat.isBroadcast) {
                return self.isMute ? NSLocalizedString(@"Unmute", nil) : NSLocalizedString(@"Mute", nil);
            }
            
            
        }
        
        if(self.chat.isDeactivated) {
            return NSLocalizedString(@"Conversation.Action.ChatDeactivated", nil);
        }
        
        if(self.chat.isKicked || self.chat.type == TLChatTypeForbidden) {
            return NSLocalizedString(@"Conversation.Action.YouKickedGroup", nil);
        }
        
        
        if(self.chat.left) {
            return NSLocalizedString(@"Conversation.Action.YouLeftGroup", nil);
        }
        
        
        
    }
    
    
    if(self.type == DialogTypeUser) {
        if(self.user.isBlocked) {
            if(self.user.isBot)
                return NSLocalizedString(@"RestartBot", nil);
            return NSLocalizedString(@"User.Unlock", nil);
        }
        
    }
    
    return NSLocalizedString(@"Bot.Start", nil);
}


- (void)save {
    if(self.top_message && self.fake)
        self.fake = NO;
    [[Storage manager] insertDialogs:@[self]];
}

-(void)dealloc {

}

-(int)unread_count {
    if(super.unread_count > 1000000) {
        
        if(self.top_message < TGMINFAKEID) {
            return MAX(self.top_message - self.last_marked_message,0);
        }
        
        return 100;
        
    }
    
    return super.unread_count;
}


-(void)setUnread_count:(int)unread_count {
    
    if(unread_count >= 0)
        [super setUnread_count:unread_count];
    
}

- (BOOL)isMute {
    if(self.type == DialogTypeSecretChat)
        return NO;
    
    return self.notify_settings.mute_until > [[MTNetwork instance] getTime];
}


- (BOOL) isAddToList {
    if(self.type == DialogTypeSecretChat)
        return YES;
        
    return !self.isInvisibleChannel && self.last_message_date > 0  && !self.fake && (!self.chat.isDeactivated);
}

//-(BOOL)isInvisibleChannel {
//    if(self.type == DialogTypeChannel) {
//        return _invisibleChannel || [self.chat left];
//    }
//    
//    return _invisibleChannel;
//}


- (void)mute:(dispatch_block_t)completeHandler until:(int)until {
    [self _changeMute:until completeHandler:completeHandler];
}

- (void)unmute:(dispatch_block_t)completeHandler {
    [self _changeMute:0 completeHandler:completeHandler];
}

- (void)mute:(dispatch_block_t)completeHandler {
    [self _changeMute:365*24*60*60 completeHandler:completeHandler];
}


- (void)_changeMute:(int)until completeHandler:(dispatch_block_t)completeHandler {
    __block int mute_until = until == 0 ? 0 : [[MTNetwork instance] getTime] + until;
    
    id request = [TLAPI_account_updateNotifySettings createWithPeer:[TL_inputNotifyPeer createWithPeer:[self inputPeer]] settings:[TL_inputPeerNotifySettings createWithMute_until:mute_until sound:self.notify_settings.sound ? self.notify_settings.sound : @"" show_previews:self.notify_settings.show_previews events_mask:self.notify_settings.events_mask]];
    
    
    dispatch_block_t successBlock = ^{
        self.notify_settings = [TL_peerNotifySettings createWithMute_until:mute_until sound:self.notify_settings.sound show_previews:self.notify_settings.show_previews events_mask:self.notify_settings.events_mask];
        [self updateNotifySettings:self.notify_settings];
        
        if(completeHandler)
            completeHandler();
        
        [MessagesManager updateUnreadBadge];

    };
    
    if(self.type != DialogTypeSecretChat && self.type != DialogTypeBroadcast) {
        [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
            
            successBlock();
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            if(completeHandler)
                completeHandler();
        }];
    } else {
        successBlock();
    }
    
    
}

- (void)muteOrUnmute:(dispatch_block_t)completeHandler until:(int)until {
    [self mute:completeHandler until:self.isMute ? 0 : 365*24*60*60];
}

-(int)peer_id {
    return self.peer.peer_id;
}

- (void)updateNotifySettings:(TLPeerNotifySettings *)notify_settings {
    self.notify_settings = notify_settings;
    
    [self save];
    
    [Notification perform:[Notification notificationNameByDialog:self action:@"notification"] data:@{@"notify_settings":self.notify_settings}];
}


-(id)inputPeer {
    id input;
    if(self.peer.chat_id != 0) {
        input = [TL_inputPeerChat createWithChat_id:self.peer.chat_id];
    } else if([self.peer isKindOfClass:[TL_peerChannel class]]) {
            return [TL_inputPeerChannel createWithChannel_id:self.peer.channel_id access_hash:self.chat.access_hash];
    } else {
        TLUser *user = [[UsersManager sharedManager] find:self.peer.user_id];
        input = [user inputPeer];
    }
    if(!input)
        return [TL_inputPeerEmpty create];
    return input;
}

-(void)setUnreadCount:(int)unread_count {
    self.unread_count = unread_count  < 0 ? 0 : unread_count;
}

-(void)addUnread {
    self.unread_count++;
}


-(void)subUnread {
    self.unread_count = self.unread_count-1 < 0 ? 0 : self.unread_count-1;
}

-(NSPredicate *)predicateForPeer {
    //    int peer_id = ;
    //    MTLog(@"")
    //    int a = 1;
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"peer.peer_id == %d",self.peer.peer_id];
    return pred;
}






static void *kType;

- (DialogType) type {
    NSNumber *typeNumber = objc_getAssociatedObject(self, &kType);
    if(typeNumber) {
        return [typeNumber intValue];
    } else {
        DialogType type = DialogTypeUser;
        
        if(self.peer.class == [TL_peerUser class])
            type = DialogTypeUser;
        else if(self.peer.class == [TL_peerChat class])
            type = DialogTypeChat;
        else if(self.peer.class == [TL_peerSecret class])
            type = DialogTypeSecretChat;
        else if(self.peer.class == [TL_peerChannel class])
            type = DialogTypeChannel;
        else if(self.peer.class == [TL_peerBroadcast class])
            type = DialogTypeBroadcast;
        
        
        objc_setAssociatedObject(self, kType, [NSNumber numberWithInt:type], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return type;
    }
}



- (NSUInteger) cacheHash {
    return [[self cacheKey] hash];
}

- (NSString *)cacheKey {
    return [NSString stringWithFormat:@"peer_id:%d", self.peer_id];
}

- (TLChat *) chat {
    
    if(!_p_chat && (self.peer.chat_id != 0 || self.peer.channel_id != 0)) {
        _p_chat = [[ChatsManager sharedManager] find:self.peer.chat_id == 0 ? self.peer.channel_id : self.peer.chat_id];
    }
    return _p_chat;
}

- (TLChatFull *)fullChat {
    return [[FullChatManager sharedManager] find:[self chat].n_id];
}

-(long)channel_top_message_id {
    return channelMsgId(self.top_message,self.peer_id);
}

-(long)channel_top_important_message_id {
    return channelMsgId(self.top_important_message,self.peer_id);
}

-(BOOL)isVerified {
    return self.type == DialogTypeChannel ? self.chat.isVerified : self.type == DialogTypeUser ? self.user.isVerified : NO;
}

- (TL_encryptedChat *) encryptedChat {
    return (TL_encryptedChat *)[self chat];
}

- (TLUser *) user {
    
    if(!_p_user && (self.peer.user_id != 0 || self.type == DialogTypeSecretChat)) {
        
        if(self.peer.user_id != 0) {
            _p_user = [[UsersManager sharedManager] find:self.peer.user_id];
        }
        
        if(self.type == DialogTypeSecretChat) {
            _p_user = self.encryptedChat.peerUser;
        }
        
    }
    
    return _p_user;
}

-(BOOL)canEditConversation {
    return YES;
}


-(BOOL)canSendChannelMessageAsAdmin {
    return self.type == DialogTypeChannel && !self.chat.isMegagroup && (self.chat.isAdmin || self.chat.isEditor);
}

-(BOOL)canSendChannelMessageAsUser {
    return self.type == DialogTypeChannel && (self.chat.isMegagroup || ((self.chat.isAdmin && !self.chat.isBroadcast) || !self.chat.isBroadcast));
}



@end
