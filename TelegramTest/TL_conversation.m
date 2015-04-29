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


@interface TL_conversation ()
@property (nonatomic,strong,readonly) TLUser *p_user;
@property (nonatomic,strong,readonly) TLChat *p_chat;
@end

@implementation TL_conversation
+(TL_conversation *)createWithPeer:(TLPeer *)peer top_message:(int)top_message unread_count:(int)unread_count last_message_date:(int)last_message_date notify_settings:(TLPeerNotifySettings *)notify_settings last_marked_message:(int)last_marked_message top_message_fake:(int)top_message_fake last_marked_date:(int)last_marked_date sync_message_id:(int)sync_message_id {
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
    dialog.lastMessage = [[MessagesManager sharedManager] find:top_message];
    
    return dialog;
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

-(void)setLast_message_date:(int)last_message_date {
    self->_last_message_date = last_message_date;
    self->_last_real_message_date = last_message_date;
}



-(BOOL)canSendMessage {
    
    if([TGPasslock isVisibility])
        return NO;
    
    if(self.type == DialogTypeSecretChat) {
        return self.encryptedChat.encryptedParams.state == EncryptedAllowed;
    }
    
    if(self.type == DialogTypeChat) {
        return !(self.chat.type != TLChatTypeNormal || self.chat.left);
    }
    
    return YES;
}

- (TL_broadcast *)broadcast {
    return [[BroadcastManager sharedManager] find:self.peer.peer_id];
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
    
    if(self.type == DialogTypeChat) {
        if(self.chat.type == TLChatTypeForbidden) {
            return NSLocalizedString(@"Conversation.Action.YouKickedGroup", nil);
        }
        
        
        if(self.chat.left) {
            return NSLocalizedString(@"Conversation.Action.YouLeftGroup", nil);
        }
        
    }
    
    if(self.type == DialogTypeUser) {
        if([[BlockedUsersManager sharedManager] isBlocked:self.peer.peer_id]) {
            return NSLocalizedString(@"User.Blocked", nil);
        }
    }
    
    return @"";
}

- (void)save {
    if(self.top_message && self.fake)
        self.fake = NO;
    [[Storage manager] updateDialog:self];
}

-(void)dealloc {

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
    
    return self.last_message_date > 0  && !self.fake;
}

- (void)mute:(dispatch_block_t)completeHandler until:(int)until {
    [self _changeMute:until completeHandler:completeHandler];
}

- (void)unmute:(dispatch_block_t)completeHandler {
    [self _changeMute:0 completeHandler:completeHandler];
}

- (void)_changeMute:(int)until completeHandler:(dispatch_block_t)completeHandler {
    __block int mute_until = until == 0 ? 0 : [[MTNetwork instance] getTime] + until;
    
    id request = [TLAPI_account_updateNotifySettings createWithPeer:[TL_inputNotifyPeer createWithPeer:[self inputPeer]] settings:[TL_inputPeerNotifySettings createWithMute_until:mute_until sound:self.notify_settings.sound ? self.notify_settings.sound : @"" show_previews:self.notify_settings.show_previews events_mask:self.notify_settings.events_mask]];
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
        if([response isKindOfClass:[TL_boolTrue class]]) {
            
            self.notify_settings = [TL_peerNotifySettings createWithMute_until:mute_until sound:self.notify_settings.sound show_previews:self.notify_settings.show_previews events_mask:self.notify_settings.events_mask];
            [self updateNotifySettings:self.notify_settings];

        }
        
        if(completeHandler)
            completeHandler();
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(completeHandler)
            completeHandler();
    }];
}

- (void)muteOrUnmute:(dispatch_block_t)completeHandler until:(int)until {
    [self mute:completeHandler until:until];
}

-(int)peer_id {
    return self.peer.peer_id;
}

- (void)updateNotifySettings:(TLPeerNotifySettings *)notify_settings {
    self.notify_settings = notify_settings;
    
    [self save];
    [Notification perform:PUSHNOTIFICATION_UPDATE data:@{KEY_PEER_ID: @(self.peer.peer_id), KEY_IS_MUTE: @(self.isMute)}];
}


-(id)inputPeer {
    id input;
    if(self.peer.chat_id != 0) {
        // if([self.peer isKindOfClass:[TL_peerSecret class]]) {
        //  TLEncryptedChat *chat = [[ChatsManager sharedManager] find:self.peer.chat_id];
        //}
        input = [TL_inputPeerChat createWithChat_id:self.peer.chat_id];
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
    //    DLog(@"")
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
        if(self.peer.chat_id) {
            if(self.peer.class == [TL_peerChat class])
                type = DialogTypeChat;
            else if(self.peer.class == [TL_peerSecret class])
                type = DialogTypeSecretChat;
            else
                type = DialogTypeBroadcast;
            
            
        }
        
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
    
    if(!_p_chat && self.peer.chat_id != 0) {
        _p_chat = [[ChatsManager sharedManager] find:self.peer.chat_id];
    }
    return _p_chat;
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


@end
