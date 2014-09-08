//
//  MessagesManager.m
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "MessagesManager.h"
#import "TGMessage+Extensions.h"
#import "TGPeer+Extensions.h"
#import "Crypto.h"
#import "SelfDestructionController.h"
#import "MessagesUtils.h"
#import "TGMessage+Extensions.h"
#import "TGMessageCategory.h"
@interface NSUserNotification(Extensions)

@property (nonatomic)  BOOL hasReplyButton;

@end

@interface MessagesManager ()
@property (nonatomic,strong) NSMutableDictionary *messages;
@property (nonatomic,strong) NSMutableDictionary *messages_with_random_ids;
@end

@implementation MessagesManager

-(id)init {
    if(self = [super init]) {
        self.messages = [[NSMutableDictionary alloc] init];
        self.messages_with_random_ids = [[NSMutableDictionary alloc] init];
    }
    return self;
}


-(void)dealloc {
    [Notification removeObserver:self];
}

+ (void)statedMessage:(TL_messages_statedMessage*)response {
    
    if(response == nil)
        return;
    
    response.message = [TL_localMessage convertReceivedMessage:[response message]];
    
    
    [SharedManager proccessGlobalResponse:response];
    
    
    
    [MessagesManager addAndUpdateMessage:[response message]];
}

+(TGMessage *)defaultMessage:(TL_encryptedMessage *)message {
    __block EncryptedParams *params;
    params = [EncryptedParams findAndCreate:message.chat_id];
    if(params.n_id == 0) {
        return nil;
    }
    
    int64_t keyId = 0;
    [message.bytes getBytes:&keyId range:NSMakeRange(0, 8)];
    NSData *msg_key = [message.bytes subdataWithRange:NSMakeRange(8, 16)];
    NSData *decrypted = [Crypto encrypt:0 data:[message.bytes subdataWithRange:NSMakeRange(24, message.bytes.length - 24)] auth_key:[params encrypt_key] msg_key:msg_key encrypt:NO];
    
    int messageLength = 0;
    [decrypted getBytes:&messageLength range:NSMakeRange(0, 4)];
    decrypted = [decrypted subdataWithRange:NSMakeRange(4, decrypted.length-4)];
    
    
    TL_decryptedMessage * decryptedMessage = [[TLClassStore sharedManager] deserialize:decrypted];
    
    TGEncryptedChat *chat = [[ChatsManager sharedManager] find:message.chat_id];
    if(chat) {
        TGMessage *msg;
        if(![decryptedMessage isKindOfClass:[TL_decryptedMessageService class]]) {
            TGMessageMedia *media = [[MessagesManager sharedManager] mediaFromEncryptedMessage:decryptedMessage.media file:[message file]];
            msg = [TL_destructMessage createWithN_id:[MessageSender getFutureMessageId] from_id:[chat peerUser].n_id to_id:[TL_peerSecret createWithChat_id:[message chat_id]] n_out:NO unread:YES date:[message date] message:[decryptedMessage message] media:media destruction_time:0 randomId:decryptedMessage.random_id fakeId:[MessageSender getFakeMessageId] dstate:DeliveryStateNormal];
            
        } else {
            if([[decryptedMessage action] isKindOfClass:[TL_decryptedMessageActionSetMessageTTL class]]) {
                
                msg = [TL_localMessageService createWithN_id:[MessageSender getFutureMessageId] from_id:[chat peerUser].n_id to_id:[TL_peerSecret createWithChat_id:[message chat_id]] n_out:NO unread:NO date:[[MTNetwork instance] getTime] action:[TL_messageActionEncryptedChat createWithTitle:[MessagesUtils selfDestructTimer:[decryptedMessage.action ttl_seconds]]] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
                
                Destructor *destructor = [[Destructor alloc] initWithTLL:[decryptedMessage.action ttl_seconds] max_id:msg.n_id chat_id:chat.n_id];
                [SelfDestructionController addDestructor:destructor];
                
            }
            
            if([[decryptedMessage action] isKindOfClass:[TL_decryptedMessageActionScreenshotMessages class]]) {
                msg = [TL_localMessageService createWithN_id:[MessageSender getFutureMessageId] from_id:[chat peerUser].n_id to_id:[TL_peerSecret createWithChat_id:[message chat_id]] n_out:NO unread:NO date:[[MTNetwork instance] getTime] action:[TL_messageActionEncryptedChat createWithTitle:NSLocalizedString(@"MessageAction.Secret.TookScreenshot", nil)] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
            }
            
            if([[decryptedMessage action] isKindOfClass:[TL_decryptedMessageActionDeleteMessages class]]) {
                
                [[Storage manager] deleteMessagesWithRandomIds:decryptedMessage.action.random_ids completeHandler:^(BOOL result) {
                    
                    NSMutableDictionary *update = [[NSMutableDictionary alloc] init];
                    
                    NSMutableArray *ids = [[NSMutableArray alloc] init];
                    
                    
                    for (NSNumber *msgId in decryptedMessage.action.random_ids) {
                        
                        TL_destructMessage *message = [[MessagesManager sharedManager] findWithRandomId:[msgId longValue]];
                        
                        if(message) {
                             [ids addObject:@(message.n_id)];
                        }
                        
                        if(message && message.dialog) {
                            [update setObject:message.dialog forKey:@(message.dialog.peer.peer_id)];
                        }
                        
                    }
                    
                    for (TL_conversation *dialog in update.allValues) {
                        [[DialogsManager sharedManager] updateLastMessageForDialog:dialog];
                    }
                    
                    [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_MESSAGE_ID_LIST:ids}];
                    
                }];
                
                
                
                return nil;
            }
            
            if([[decryptedMessage action] isKindOfClass:[TL_decryptedMessageActionFlushHistory class]]) {
                
                [[Storage manager] deleteMessagesInDialog:chat.dialog completeHandler:^{
                    
                    [Notification perform:MESSAGE_FLUSH_HISTORY data:@{KEY_DIALOG:chat.dialog}];
                    
                    [[DialogsManager sharedManager] updateLastMessageForDialog:chat.dialog];
                    
                }];
                
                return nil;
            }
        }
        return msg;
    }
    return nil;
}


+(void)addAndUpdateMessage:(TGMessage *)message {
    [self notifyMessage:message update_real_date:NO];
}

+(void)notifyMessage:(TGMessage *)message update_real_date:(BOOL)update_real_date {
    
    [ASQueue dispatchOnStageQueue:^{
        if(!message)
            return;
        
        
        [[MessagesManager sharedManager] addMessage:message];
        
        [Notification perform:MESSAGE_RECEIVE_EVENT data:@{KEY_MESSAGE:message}];
        [Notification perform:MESSAGE_UPDATE_TOP_MESSAGE data:@{KEY_MESSAGE:message,@"update_real_date":@(update_real_date)}];
        
        
        if(message.from_id == [UsersManager currentUserId]) {
            return;
        }
        
        
        
        
        TL_conversation *dialog = message.dialog;
        
        
        BOOL result = dialog.isMute;
        if(result)
            return;
        
        NSString *title = [[[UsersManager sharedManager] find:message.from_id] fullName];
        NSString *msg = message.message;
        if(message.action) {
            msg = [MessagesUtils serviceMessage:message forAction:message.action];
        } else if(![message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
            msg = [MessagesUtils mediaMessage:message];
        }
        
        if([message.to_id isSecret] && !message.action)
            msg = NSLocalizedString(@"Notification.SecretMessage", nil);
        
        NSString *subTitle;
        
        if(message.to_id.chat_id != 0) {
            if(![message.to_id isSecret]) {
                subTitle = title;
                title = [[[ChatsManager sharedManager] find:message.to_id.chat_id] title];
            } else {
                title = message.dialog.encryptedChat.peerUser.fullName;
            }
        }
        
        
        if ([NSUserNotification class] && [NSUserNotificationCenter class]) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = title;
            notification.informativeText = msg;
            notification.subtitle = subTitle ? subTitle : @"";
            if(![[SettingsArchiver soundNotification] isEqualToString:@"None"])
                notification.soundName = [SettingsArchiver soundNotification];
            if (floor(NSAppKitVersionNumber) > 1187)
            {
                if(![message.to_id isSecret])
                    notification.hasReplyButton = YES;
            }
            
            [notification setUserInfo:@{@"peer_id":[NSNumber numberWithInt:[message peer_id]]}];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }

    }];
    
}

+ (void)notifyConversation:(int)peer_id title:(NSString *)title text:(NSString *)text {
    if ([NSUserNotification class] && [NSUserNotificationCenter class]) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = title;
        notification.informativeText = text;
        if(![[SettingsArchiver soundNotification] isEqualToString:@"None"])
            notification.soundName = [SettingsArchiver soundNotification];
        
        [notification setUserInfo:@{@"peer_id":@(peer_id)}];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
}

+ (void) getUserFromMessageId:(int)message_id completeHandler:(void (^)())completeHandler {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithInt:message_id]];
    [RPCRequest sendRequest:[TLAPI_messages_getMessages createWithN_id:array] successHandler:^(RPCRequest *request, id response) {
        
        if([response isKindOfClass:[TL_messages_messages class]]) {
            [SharedManager proccessGlobalResponse:response];
        }
        
        if(completeHandler)completeHandler();
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
    }];
}

-(TL_destructMessage *)findWithRandomId:(long)random_id {
    __block TL_destructMessage *object;
    
    [ASQueue dispatchOnStageQueue:^{
        object = [self.messages_with_random_ids objectForKey:@(random_id)];
    } synchronous:YES];
    
    return object;
}


-(void)drop {
    self->keys = [[NSMutableDictionary alloc] init];
    self->list = [[NSMutableArray alloc] init];
    self.messages = [[NSMutableDictionary alloc] init];
    _unread_count = 0;
}

-(void)add:(NSArray *)all {
    [ASQueue dispatchOnStageQueue:^{
        for (TGMessage *message in all) {
            assert([message isKindOfClass:[TL_localMessage class]]);
            [self TGsetMessage:message];
        }
    }];

}


-(TGMessage *)localMessageForId:(int)n_id {
    return [self.messages objectForKey:[NSNumber numberWithInt:n_id]];
}

-(TGMessageMedia *)mediaFromEncryptedMessage:(TGDecryptedMessageMedia *)media file:(TGEncryptedFile *)file {
    if([media isKindOfClass:[TL_decryptedMessageMediaEmpty class]])
        return [TL_messageMediaEmpty create];
    
    if([media isKindOfClass:[TL_decryptedMessageMediaGeoPoint class]]) {
        return [TL_messageMediaGeo createWithGeo:[TL_geoPoint createWithN_long:media.n_long lat:media.lat]];
    }
    
    if([media isKindOfClass:[TL_decryptedMessageMediaContact class]]) {
        TL_decryptedMessageMediaContact *contact = (TL_decryptedMessageMediaContact *) media;
        return [TL_messageMediaContact createWithPhone_number:contact.phone_number first_name:contact.file_name last_name:contact.last_name user_id:contact.user_id];
    }
    

    
   
    TL_fileLocation *location = [TL_fileLocation createWithDc_id:[file dc_id] volume_id:[file n_id] local_id:-1 secret:[file access_hash]];
    
    if(!media.key || !media.iv) {
        DLog(@"drop encrypted media class ====== %@ ======",NSStringFromClass([media class]));
        return [TL_messageMediaEmpty create];
    }
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:@{@"key": media.key, @"iv":media.iv} forKey:[NSString stringWithFormat:@"%lu",file.n_id] inCollection:ENCRYPTED_IMAGE_COLLECTION];
    }];
    
    if([media isKindOfClass:[TL_decryptedMessageMediaPhoto class]]) {
        
        TL_photoCachedSize *s0 = [TL_photoCachedSize createWithType:@"jpeg" location:location w:[media thumb_w] h:[media thumb_h] bytes:[media thumb]];
        
        TL_photoSize *s1 = [TL_photoSize createWithType:@"jpeg" location:location w:[media w] h:[media h] size:[media size]];
        NSMutableArray *size =  [NSMutableArray arrayWithObjects:s0,s1,nil];
        
        return [TL_messageMediaPhoto createWithPhoto:[TL_photo createWithN_id:[file n_id] access_hash:[file access_hash] user_id:[media user_id] date:[[MTNetwork instance] getTime] caption:@"" geo:[TL_geoPointEmpty create] sizes:size]];
    } else if([media isKindOfClass:[TL_decryptedMessageMediaDocument class]]) {
        
        TGPhotoSize *size = [TL_photoSizeEmpty createWithType:@"jpeg"];
        if(media.thumb.length > 0) {
            size = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:0 local_id:0 secret:0] w:media.thumb_w h:media.thumb_w bytes:media.thumb];
        }
        
        return [TL_messageMediaDocument createWithDocument:[TL_document createWithN_id:file.n_id access_hash:file.access_hash user_id:media.user_id date:[[MTNetwork instance] getTime] file_name:[media file_name] mime_type:[media mime_type] size:file.size thumb:size dc_id:[file dc_id]]];
      
        
    } else if([media isKindOfClass:[TL_decryptedMessageMediaVideo class]] || [media isKindOfClass:[TL_decryptedMessageMediaVideo_12 class]] ) {
        location.dc_id = 0;
        
        NSString *mime_type = media.mime_type ? media.mime_type : @"mp4";
        
        return [TL_messageMediaVideo createWithVideo:[TL_video createWithN_id:file.n_id access_hash:file.access_hash user_id:media.user_id date:[[MTNetwork instance] getTime] caption:@"" duration:media.duration mime_type:mime_type size:file.size thumb:[TL_photoCachedSize createWithType:@"jpeg" location:location w:media.thumb_w h:media.thumb_w bytes:media.thumb] dc_id:[file dc_id] w:media.w h:media.h]];
        
    } else if([media isKindOfClass:[TL_decryptedMessageMediaAudio class]] || [media isKindOfClass:[TL_decryptedMessageMediaAudio_12 class]]) {
        TL_decryptedMessageMediaAudio *audio = (TL_decryptedMessageMediaAudio *)media;
        
        NSString *mime_type = media.mime_type ? media.mime_type : @"ogg";

        
        return [TL_messageMediaAudio createWithAudio:[TL_audio createWithN_id:file.n_id access_hash:file.access_hash user_id:media.user_id date:[[MTNetwork instance] getTime] duration:audio.duration mime_type:mime_type size:file.size dc_id:file.dc_id]];
        
    } else {
        alert(@"Unknown secret media", @"");
    }
    
    return [TL_messageMediaEmpty create];
}

-(void)addMessage:(TGMessage *)message  {
    [self TGsetMessage:message];
    [[Storage manager] insertMessage:message  completeHandler:nil];
}

-(void)TGsetMessage:(TGMessage *)message {
    
    [ASQueue dispatchOnStageQueue:^{
        if(!message || message.n_id == 0) return;
        
        [self.messages setObject:message forKey:@(message.n_id)];
        
        if([message isKindOfClass:[TL_destructMessage class]])
            [self.messages_with_random_ids setObject:message forKey:@(((TL_destructMessage *)message).randomId)];
    }];
}



-(id)find:(NSInteger)_id {
    
    __block id object;
    
    [ASQueue dispatchOnStageQueue:^{
        object = [self.messages objectForKey:@(_id)];
    } synchronous:YES];
    
    return object;
}


-(NSArray *)markAllInDialog:(TL_conversation *)dialog {
    
    __block NSMutableArray *marked = [[NSMutableArray alloc] init];
    
    [ASQueue dispatchOnStageQueue:^{
        NSArray *copy = [[self.messages allValues] copy];
        copy = [copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"peer_id == %d",dialog.peer.peer_id]];
        for (TGMessage *msg in copy) {
            
            
            if(msg.unread == YES)
                [marked addObject:@([msg n_id])];
            msg.unread = NO;
        }
        [[Storage manager] markAllInDialog:dialog];
    } synchronous:YES];
    
   
    return marked;
}



-(void)setUnread_count:(int)unread_count {
     self->_unread_count = unread_count < 0 ? 0 : unread_count;
    [LoopingUtils runOnMainQueueAsync:^{
        NSString *str = unread_count > 0 ? [NSString stringWithFormat:@"%d",unread_count] : nil;
        [[[NSApplication sharedApplication] dockTile] setBadgeLabel:str];

    }];
   
   }

+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}
@end
