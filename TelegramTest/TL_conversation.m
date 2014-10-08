//
//  TL_conversation.m
//  Messenger for Telegram
//
//  Created by keepcoder on 11.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_conversation.h"
#import "TGPeer+Extensions.h"
@implementation TL_conversation
+(TL_conversation *)createWithPeer:(TGPeer *)peer top_message:(int)top_message unread_count:(int)unread_count last_message_date:(int)last_message_date notify_settings:(TGPeerNotifySettings *)notify_settings last_marked_message:(int)last_marked_message top_message_fake:(int)top_message_fake last_marked_date:(int)last_marked_date {
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
    
    return dialog;
}

-(void)serialize:(SerializedData*)stream {
    [[TLClassStore sharedManager] TLSerialize:self.peer stream:stream];
	[stream writeInt:self.top_message];
	[stream writeInt:self.unread_count];
    [stream writeInt:self.last_message_date];
    [[TLClassStore sharedManager] TLSerialize:self.notify_settings stream:stream];
    [stream writeInt:self.last_marked_message];
    [stream writeInt:self.top_message_fake];
    [stream writeInt:self.last_marked_date];
    [stream writeInt:self.last_real_message_date];


}
-(void)unserialize:(SerializedData*)stream {
    self.peer = [[TLClassStore sharedManager] TLDeserialize:stream];
    self.top_message = [stream readInt];
	self.unread_count = [stream readInt];
	self.last_message_date = [stream readInt];
    self.notify_settings = [[TLClassStore sharedManager] TLDeserialize:stream];
    self.last_marked_message = [stream readInt];
    self.top_message_fake = [stream readInt];
    self.last_marked_date = [stream readInt];
    self.last_real_message_date = [stream readInt];
}

-(void)setLast_message_date:(int)last_message_date {
    self->_last_message_date = last_message_date;
    self->_last_real_message_date = last_message_date;
}



-(BOOL)canSendMessage {
    if(self.type == DialogTypeSecretChat) {
        return self.encryptedChat.encryptedParams.state == EncryptedAllowed;
    }
    
    if(self.type == DialogTypeChat) {
        return !(self.chat.type != TGChatTypeNormal || self.chat.left);
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
            TGUser *user = self.encryptedChat.peerUser;
            return [NSString stringWithFormat:format, user.first_name ? user.first_name : user.dialogFullName];
        }
        
    }
    
    if(self.type == DialogTypeChat) {
        if(self.chat.type == TGChatTypeForbidden) {
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

- (void)mute:(dispatch_block_t)completeHandler {
    [self _changeMute:YES completeHandler:completeHandler];
}

- (void)unmute:(dispatch_block_t)completeHandler {
    [self _changeMute:NO completeHandler:completeHandler];
}

- (void)_changeMute:(BOOL)isMute completeHandler:(dispatch_block_t)completeHandler {
    __block int mute_until = !isMute ? 0 : [[MTNetwork instance] getTime] + 365 * 24 * 60 * 60;
    
    id request = [TLAPI_account_updateNotifySettings createWithPeer:[TL_inputNotifyPeer createWithPeer:[self inputPeer]] settings:[TL_inputPeerNotifySettings createWithMute_until:mute_until sound:self.notify_settings.sound ? self.notify_settings.sound : @"" show_previews:self.notify_settings.show_previews events_mask:self.notify_settings.events_mask]];
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
        if([response isKindOfClass:[TL_boolTrue class]]) {
            
            self.notify_settings = [TL_peerNotifySettings createWithMute_until:mute_until sound:self.notify_settings.sound show_previews:self.notify_settings.show_previews events_mask:self.notify_settings.events_mask];

            [self save];
            [self updateNotifySettings:self.notify_settings];

        }
        
        if(completeHandler)
            completeHandler();
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(completeHandler)
            completeHandler();
    }];
}

- (void)muteOrUnmute:(dispatch_block_t)completeHandler {
    if(self.notify_settings.mute_until) {
        [self unmute:completeHandler];
    } else {
        [self mute:completeHandler];
    }
}


- (void)updateNotifySettings:(TGPeerNotifySettings *)notify_settings {
    self.notify_settings = notify_settings;
    [Notification perform:PUSHNOTIFICATION_UPDATE data:@{KEY_PEER_ID: @(self.peer.peer_id), KEY_IS_MUTE: @(self.isMute)}];
}

@end
