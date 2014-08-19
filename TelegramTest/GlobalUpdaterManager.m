//
//  GlobalUpdaterManager.m
//  TelegramTest
//
//  Created by keepcoder on 17.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "GlobalUpdaterManager.h"
#import "UserStatusManager.h"
#import "CMath.h"
#import "TGMessage+Extensions.h"
#import "TGPeer+Extensions.h"
#import "MessagesUtils.h"
#import "AppDelegate.h"
#import "SpacemanBlocks.h"
#import "Crypto.h"
#import "MessageSender.h"
#import <MTProtoKit/MTEncryption.h>
#import "SelfDestructionController.h"

@interface NSUserNotification(lol)

@property (nonatomic)  BOOL hasReplyButton;

@end


@interface GlobalUpdaterManager ()
{
    dispatch_queue_t updateQueue;
    int seqN;
    int ptsN;
    int dateN;
    int qtsN;
    
    
}

@property (nonatomic,strong) NSMutableArray *difQueue;
@end

@implementation GlobalUpdaterManager

+(GlobalUpdaterManager *)sharedManager {
    static GlobalUpdaterManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

-(id)init {
    if(self = [super init]) {
        self->updateQueue = dispatch_queue_create("UpdateQueue", NULL);
        self.difQueue = [[NSMutableArray alloc] init];
        dispatch_async(self->updateQueue, ^{
            [[NSThread currentThread] setName:@"UpdateQueue"];
        });
        self.pts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pts"] intValue];
        self.seq = [[[NSUserDefaults standardUserDefaults] objectForKey:@"seq"] intValue];
        self.date = [[[NSUserDefaults standardUserDefaults] objectForKey:@"date"] intValue];
        self.qts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"qts"] intValue];
        self->dateN = self.date;
        self->ptsN = self.pts;
        self->seqN = self.seq;
        self->qtsN = self.qts;
        self.isUpdated = YES;
    }
    return self;
}


-(NSArray *)checkMessages:(NSArray *)list {
    NSMutableArray *copy = [list mutableCopy];
    for (TGMessage *message in list) {
        if( [self checkMessage:message]) {
            [copy removeObject:message];
        }
    }
    return copy;
}


-(BOOL)checkMessage:(TGMessage *)action {
    if([action.action isKindOfClass:[TL_messageActionChatDeleteUser class]]) {
        if([[UsersManager sharedManager] userSelf].n_id == action.action.user_id) {
            [[DialogsManager sharedManager] deleteDialog:action.dialog];
            return YES;
        }
    }
    return NO;
}

-(void)drop {
    self.seq = 0;
    self.date = 0;
    self.pts = 0;
    self.qts = 0;
    self->qtsN = 0;
    self->seqN = 0;
    self->dateN = 0;
    self->ptsN = 0;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"seq"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pts"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"date"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"qts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)contains:(TL_updates_state *)state {
    return ( state.seq > 0 && self.seq+1 != state.seq );
}

-(TLAPI_updates_getDifference *)getDifference {
    return [TLAPI_updates_getDifference createWithPts:self->ptsN date:self->dateN qts:self->qtsN];
}

-(void)saveDifference:(int)seq date:(int)date qts:(int)qts {
    self.seq = seq;
    self.date = date;
    self.qts = qts;
    self->seqN = seq;
    self->dateN = date;
    self->ptsN = self.pts;
    self->qtsN = qts;
    [self save];
}


-(void)save {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.pts] forKey:@"pts"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.seq] forKey:@"seq"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.date] forKey:@"date"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.qts] forKey:@"qts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    
}



-(BOOL)isUpdated {
    return self->_isUpdated || self.seq == 0;
}

-(void)saveState {
    if(self->seqN+1 < self.seq) {
        [self updateDifference];
    } else if(self.isUpdated) {
        self->seqN = self.seq;
        self->ptsN = self.pts;
        self->dateN = self.date;
        [self save];
    }
}

-(void)updateHandler:(id)updates {
    
    
    
    
    if([updates isKindOfClass:[TL_updateShort class]]) {
        [self updateShort:updates];
    }
    if([updates isKindOfClass:[TL_updates class]]) {
        [self updates:updates];
    }
    
    if([updates isKindOfClass:[TL_updateShortChatMessage class]]) {
        [self updateShortChatMessage:updates];
    }
    
    if([updates isKindOfClass:[TL_updateShortMessage class]]) {
        [self updateShortMessage:updates];
    }
    
    
    if([updates isKindOfClass:[TL_updatesTooLong class]]) {
        [self updateDifference];
    }
}





-(void)updateShortMessage:(TL_updateShortMessage *)update {
    self.seq = [update seq];
    self.pts = [update pts];
    self.date = [update date];
    [self saveState];
    int user_id = [UsersManager userId];
    TL_message *msg = [TL_message createWithN_id:[update n_id] from_id:[update from_id] to_id:[TL_peerUser createWithUser_id:user_id] n_out:NO unread:YES date:[update date] message:[update message] media:[TL_messageMediaEmpty create]];
    
    [self insertAndUpdateShortMessage:msg];
}


-(void)updateShortChatMessage:(TL_updateShortChatMessage *)update {
    self.seq = [update seq];
    self.pts = [update pts];
    self.date = [update date];
   [self saveState];
    TL_message *msg = [TL_message createWithN_id:[update n_id] from_id:[update from_id] to_id:[TL_peerChat createWithChat_id:[update chat_id]] n_out:NO unread:YES date:[update date] message:[update message] media:[TL_messageMediaEmpty create]];
    
    [self insertAndUpdateShortMessage:msg];
    
}

-(void)insertAndUpdateShortMessage:(TGMessage *)message {
    TGUser *user = [[UsersManager sharedManager] find:message.peer_id];
    if(!user) {
        [self getUserFromMessageId:message.n_id completeHandler:^{
            [self notifyMessage:message];
        }];
        return;
    }
    [self notifyMessage:message];
   
}



-(void)setDate:(int)date {
    self->_date = date;
}

-(void)setSeq:(int)seq {
    self->_seq = seq;
}

-(void)notifyMessage:(TGMessage *)message {
    if([self checkMessage:message]) return;
    
    [[MessagesManager sharedManager] addMessage:message];
    
    
    [Notification perform:MESSAGE_RECEIVE_EVENT data:@{KEY_MESSAGE:message}];
    [Notification perform:MESSAGE_UPDATE_TOP_MESSAGE data:@{KEY_MESSAGE:message}];
    
    
    //start notifications
    
    if(message.from_id == [[UsersManager sharedManager] userSelf].n_id) {
        return;
    }
    
    
    TGDialog *dialog = message.dialog;
    
    [[PushNotificationsManager sharedManager] isMuting:dialog completionHandler:^(BOOL result) {
        
        if(result) return;
        
        NSString *title = [[[UsersManager sharedManager] find:message.from_id] fullName];
        NSString *msg = message.message;
        if(message.action) {
            msg = [MessagesUtils serviceMessage:message forAction:message.action];
        } else if(![message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
            msg = [MessagesUtils mediaMessage:message];
        }
        
        NSString *subTitle;
        
        if(message.to_id.chat_id != 0) {
            if(![message.to_id isSecret]) {
                subTitle = title;
                title = [[[ChatsManager sharedManager] find:message.to_id.chat_id] title];
            }
        }
        
        
        if ([NSUserNotification class] && [NSUserNotificationCenter class]) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = title;
            
            notification.informativeText = msg;
            notification.subtitle = subTitle ? subTitle : @"";
            notification.soundName = NSUserNotificationDefaultSoundName;
            if (floor(NSAppKitVersionNumber) > 1187)
            {
                 notification.hasReplyButton = YES;
            }
           
            TGDialog *dialog = message.dialog;
            if(dialog.type == DialogTypeChat) {
                [notification setUserInfo:@{@"type":@(dialog.type), @"chat_id": @(dialog.peer.chat_id)}];
            } else if(dialog.type == DialogTypeSecretChat) {
                [notification setUserInfo:@{@"type":@(dialog.type), @"chat_id": @(dialog.encryptedChat.n_id)}];
            } else {
                [notification setUserInfo:@{@"type":@(dialog.type), @"user_id": @(dialog.peer.user_id)}];
            }
            
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }


    }];
    
}

//-(void)updateShortMessage:(TL_updateShortMessage *)update {
//    self.seq = [update seq];
//    self.pts = [update pts];
//    self.date = [update date];
//    [self saveState];
//    int user_id = [[UsersManager sharedManager] userSelf].n_id;
//
//    
//    TL_message *msg = [TL_message createWithN_id:[update n_id] from_id:[update from_id] to_id:[TL_peerUser createWithUser_id:user_id] n_out:NO unread:YES date:[update date] message:[update message] media:[TL_messageMediaEmpty create]];
//    
//    [self insertAndUpdateShortMessage:msg];
//}

-(void)updates:(TL_updates *)updates {
   
    
    
    [[SQLManager manager] insertUsers:[updates users] completeHandler:nil];
    
    [[UsersManager sharedManager] add:[updates users]];
    [[ChatsManager sharedManager] add:[updates chats]];
    
    [[SQLManager manager] insertChats:[updates chats] completeHandler:nil];
    
    [self loopUpdates:[updates updates] save:YES];
    self.seq = updates.seq;
    self.date = updates.date;
    [self saveState];
}



- (void) updateChecker:(TGUpdate *)update {
    
    NSLog(@"update %@", NSStringFromClass(update.class) );
    
    if([update isKindOfClass:[TL_updateNewMessage class]]) {
        TGMessage *message = [update message];
        return [self insertAndUpdateShortMessage:message];
    }
    
    if([update isKindOfClass:[TL_updateReadMessages class]]) {
        return [self updateReadMessages:[update messages]];
    }
    
    if([update isKindOfClass:[TL_updateDeleteMessages class]]) {
        return [self updateDeleteMessages:[update messages]];
    }
    
    if([update isKindOfClass:[TL_updateUserName class]]) {
        
    }
    
    if([update isKindOfClass:[TL_updateContactLink class]]) {
        TL_updateContactLink *contactLink = (TL_updateContactLink *)update;
        
        BOOL isContact = NO;
        if([contactLink.my_link isKindOfClass:[TL_contacts_myLinkContact class]]) {
            isContact = YES;
        } else if([contactLink.my_link isKindOfClass:[TL_contacts_myLinkRequested class]]) {
            isContact = contactLink.my_link.contact;
        }
        
        DLog(@"%@ contact %d", isContact ? @"add" : @"delete", contactLink.user_id);
        
        if(isContact) {
            [[NewContactsManager sharedManager] insertContact:[TL_contact createWithUser_id:contactLink.user_id mutual:NO] insertToDB:YES];
        } else {
            [[NewContactsManager sharedManager] removeContact:[TL_contact createWithUser_id:contactLink.user_id mutual:NO] removeFromDB:YES];
        }
        return;
    }
    
    if([update isKindOfClass:[TL_updateEncryption class]]) {
        return [self updateEncryption:(TL_updateEncryption *)update];
    }
    
    if([update isKindOfClass:[TL_updateNewEncryptedMessage class]]) {
        TL_encryptedMessage *message = (TL_encryptedMessage *) [update encrypted_message];
        TGMessage *msg = [self normalMessageFromEncrypted:message];
        [self insertAndUpdateShortMessage:msg];
        return;
    }
    
    if([update isKindOfClass:[TL_updateEncryptedMessagesRead class]]) {
        TGDialog *dialog = [[DialogsManager sharedManager] findByUserSecretId:[update chat_id]];
        if(dialog) {
            [[DialogsManager sharedManager] markAllMessagesAsRead:dialog];
        }
        return;
    }
    
    if([update isKindOfClass:[TL_updateUserPhoto class]]) {
        TGUser *user = [[UsersManager sharedManager] find:update.user_id];
        user.photo = [update photo];
        if(user) {
            [[SQLManager manager] insertUser:user completeHandler:nil];
            [Notification perform:USER_UPDATE_PHOTO data:@{KEY_USER:user}];
        }
        return;
    }
    
    if([update isKindOfClass:[TL_updateUserStatus class]]) {
        return [[UserStatusManager sharedManager] setUserStatus:[update status] forUid:update.user_id needUpdate:YES];
    }

    
    if([update isKindOfClass:[TL_updateChatUserTyping class]] || [update isKindOfClass:[TL_updateUserTyping class]] || [update isKindOfClass:[TL_updateEncryptedChatTyping class]]) {
        [Notification perform:USER_TYPING data:@{KEY_SHORT_UPDATE:update}];
        return;
    }

    if([update isKindOfClass:[TL_updateContactLink class]]) {
        
        return;
    }
}


-(TGMessage *)normalMessageFromEncrypted:(TL_encryptedMessage *)message {
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
            msg = [TL_destructMessage createWithN_id:[MessageSender getFutureMessageId] from_id:[chat peerUser].n_id to_id:[TL_peerSecret createWithChat_id:[message chat_id]] n_out:NO unread:YES date:[message date] message:[decryptedMessage message] media:media destruction_time:0];
            
        } else {
            if([[decryptedMessage action] isKindOfClass:[TL_decryptedMessageActionSetMessageTTL class]]) {
                msg = [TL_messageService createWithN_id:[MessageSender getFutureMessageId] from_id:[chat peerUser].n_id to_id:[TL_peerSecret createWithChat_id:[message chat_id]] n_out:NO unread:NO date:[[MTNetwork instance] getTime] action:[TL_messageActionEncryptedChat createWithTitle:[NSString stringWithFormat:@"set the self-destruct timer to %d seconds",[decryptedMessage.action ttl_seconds]]]];
                
                Destructor *destructor = [[Destructor alloc] initWithTLL:[decryptedMessage.action ttl_seconds] max_id:msg.n_id chat_id:chat.n_id];
                [[SelfDestructionController sharedManager] addDestructor:destructor];
                
            }
        }
        return msg;
    }
    
    return nil;

}

-(void)loopUpdates:(NSArray *)updates save:(BOOL)needSave {
    dispatch_sync(self->updateQueue, ^{
        
        for (TGUpdate *update in updates) {
            
            if(update.pts != 0) {
                self.pts = [update pts];
            }
            if(update.qts != 0) {
                self.qts = [update qts];
            }
            
            [self updateChecker:update];
            
        }
        if(needSave)
            [self saveState];
    });
}



-(void)acceptEncryption:(TL_encryptedChatRequested *)request {
    
    
    [RPCRequest sendRequest:[TLAPI_messages_getDhConfig createWithVersion:1 random_length:256] successHandler:^(TL_messages_dhConfig *response) {
        
        uint8_t bBytes[256] = {};
        
        for (int i = 0; i < 256 && i < (int)response.random.length; i++)
        {
            uint8_t currentByte = ((uint8_t *)response.random.bytes)[i];
            bBytes[i] ^= currentByte;
        }
        
        NSData *b = [[NSData alloc] initWithBytes:bBytes length:256];
        
        int g = [response g];
        
        if(!MTCheckIsSafeG(g)) return;
        
        NSData *dhPrime = [response p];
        
        NSMutableData *g_b = [[Crypto exp:[NSData dataWithBytes:&g length:1] b:b dhPrime:dhPrime] mutableCopy];
        
        if( !MTCheckIsSafeGAOrB(g_b, dhPrime)) return;
        
        
        NSData *key_hash = [Crypto exp:[request g_a] b:b dhPrime:dhPrime];
        
        
        NSData *key_fingerprints = [[Crypto sha1:key_hash] subdataWithRange:NSMakeRange(12, 8)];
        long keyId;
        [key_fingerprints getBytes:&keyId];
        [RPCRequest sendRequest:[TLAPI_messages_acceptEncryption createWithPeer:[request inputPeer] g_b:g_b key_fingerprint:keyId] successHandler:^(TL_encryptedChat * acceptResponse) {
            
            
            EncryptedParams *params = [[EncryptedParams alloc] initWithChatId:acceptResponse.n_id encrypt_key:key_hash key_fingerprings:keyId a:b g_a:g_b dh_prime:dhPrime state:EncryptedAllowed];
            
            TL_dialog *dialog = [TL_dialog createWithPeer:[TL_peerSecret createWithChat_id:acceptResponse.n_id] top_message:0 unread_count:0];

            
            [[ChatsManager sharedManager] add:@[acceptResponse]];
            [[DialogsManager sharedManager]insertDialog:dialog secret:YES];
            
            [[SQLManager manager] insertEncryptedChat:acceptResponse];
            [params save];
            
            TL_messageService *msg = [TL_messageService createWithN_id:[MessageSender getFutureMessageId] from_id:acceptResponse.admin_id to_id:[TL_peerSecret createWithChat_id:acceptResponse.n_id] n_out:NO unread:NO date:[[MTNetwork instance] getTime] action:[TL_messageActionEncryptedChat createWithTitle:NSLocalizedString(@"created secret chat", nil)]];
            [self insertAndUpdateShortMessage:msg];
            
            
        } errorHandler:^(RpcError *error) {
            
        }];
    } errorHandler:^(RpcError *error) {
        
    }];
    
   
}


-(void)updateEncryption:(TL_updateEncryption *)updateEncryption {
    if(updateEncryption.chat) {
        if([updateEncryption.chat isKindOfClass:[TL_encryptedChatRequested class]]) {
            [self acceptEncryption:(TL_encryptedChatRequested *) updateEncryption.chat];
        }
        if([updateEncryption.chat isKindOfClass:[TL_encryptedChat class]]) {
            TL_encryptedChat *chat = (TL_encryptedChat *) updateEncryption.chat;
            
            
            EncryptedParams *params = [EncryptedParams findAndCreate:chat.n_id];

            NSData *key_hash = [Crypto exp:[updateEncryption.chat g_a_or_b] b:[params a] dhPrime:params.dh_prime];
            NSData *key_fingerprints = [[Crypto sha1:key_hash] subdataWithRange:NSMakeRange(12, 8)];
            long keyId;
            [key_fingerprints getBytes:&keyId];
            
            
            params.key_fingerprints = keyId;
            params.encrypt_key = key_hash;
            
            [params setState:EncryptedAllowed];
            [params save];
            [[SQLManager manager] insertEncryptedChat:chat];
            [[ChatsManager sharedManager] add:@[chat]];
        }
        
        if([updateEncryption.chat isKindOfClass:[TL_encryptedChatDiscarded class]]) {
            EncryptedParams *params = [EncryptedParams findAndCreate:[updateEncryption.chat n_id]];
            [params setState:EncryptedDiscarted];
            [params save];
            
        }
        if([updateEncryption.chat isKindOfClass:[TL_encryptedChatEmpty class]]) {
            
        }
    }
}


-(void)saveDate:(int)date {
    self.date = date;
    [self saveState];
}

-(void)updateShort:(TL_updateShort *)shortUpdate {
    [self saveDate:shortUpdate.date];
    
    [self updateChecker:shortUpdate.update];
}


- (void) getUserFromMessageId:(int)message_id completeHandler:(void (^)())completeHandler {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithInt:message_id]];
    [RPCRequest sendRequest:[TLAPI_messages_getMessages createWithN_id:array] successHandler:^(id response) {
        
        if([response isKindOfClass:[TL_messages_messages class]]) {
            TL_messages_messages* messages = response;
            
            [[SQLManager manager] insertChats:[messages chats] completeHandler:nil];
            [[SQLManager manager] insertMessages:[messages messages] completeHandler:nil];
            [[SQLManager manager] insertUsers:[messages users] completeHandler:nil];
            
            [[UsersManager sharedManager] add:[messages users]];
            [[ChatsManager sharedManager] add:[messages chats]];
        }
        
        if(completeHandler)completeHandler();
        
    } errorHandler:^(RpcError *error) {
        
    }];
}



-(void)updateReadMessages:(NSArray *)messages {
    [[SQLManager manager] markMessagesAsRead:messages completeHandler:nil];
    
    for(NSNumber *mgsId in messages) {
        TGMessage *message = [[MessagesManager sharedManager] find:[mgsId intValue]];
        message.unread = NO;
    }
    
    [Notification perform:MESSAGE_READ_EVENT data:@{KEY_MESSAGE_ID_LIST:messages}];
}

-(void)updateDeleteMessages:(NSArray *)messages {
    [[SQLManager manager] deleteMessages:messages completeHandler:^(BOOL result) {
         [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_MESSAGE_ID_LIST:messages}];
    }];
}


-(void)updateDifference {
    
    if(self.seq == 0 || self.pts == 0 || self.date == 0 || self.qts == 0) {
        
        [RPCRequest sendRequest:[TLAPI_updates_getState create] successHandler:^(id response) {
            TL_updates_state *obj = response;
            if([self contains:obj]) {
                if(self.pts == 0) {
                    self.pts = [obj pts];
                    self->ptsN = self.pts;
                }
                if(self.date == 0) {
                    self.date = [obj date];
                    self->dateN = self.date;
                }
                if(self.qts == 0) {
                    self.qts = [obj qts];
                    self->qtsN = self.qts;
                }
                [self updateUpdates:[self getDifference]];
            }
            
        } errorHandler:^(RpcError *error) {
            
        }];
    } else {
         [self updateUpdates:[self getDifference]];
    }
    
    
}

-(void)updateUpdates:(TLAPI_updates_getDifference *)dif {
    NSLog(@"-----TRY START UPDATES-----");
    if(!self.isUpdated || ![[MTNetwork instance] isAuth]) return;
    self.isUpdated = NO;
    NSLog(@"-----START UPDATES----- with pts: %d, date: %d, qts: %d",dif.pts,dif.date,dif.qts);
    [RPCRequest sendRequest:dif successHandler:^(id response) {
        
        TL_updates_difference *updates = response;
        
        TGupdates_State * intstate;
        if([response isKindOfClass:[TL_updates_differenceSlice class]]) {
            intstate = [response intermediate_state];   
        }
        
        
        [self loopUpdates:[updates other_updates] save:NO];
        
        
        
        for (TL_encryptedMessage *encryptedMessage in [updates n_encrypted_messages]) {
            TGMessage *msg = [self normalMessageFromEncrypted:encryptedMessage];
            if(msg) {
                [[updates n_messages] addObject:msg];
            }
        }
        
        if([updates chats].count > 0) {
            [[SQLManager manager] insertChats:[updates chats] completeHandler:nil];
            [[ChatsManager sharedManager] add:[updates chats]];
        }
        
        if([updates users].count > 0) {
            [[SQLManager manager] insertUsers:[updates users] completeHandler:nil];
            [[UsersManager sharedManager] add:[updates users]];
        }
        
        if([response n_messages].count > 0) {
            NSArray *messages = [self checkMessages:[response n_messages]];
            [[MessagesManager sharedManager] addMessageList:messages];
            
            [Notification perform:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:messages}];
            [Notification perform:MESSAGE_LIST_RECEIVE object:messages];
            
            
            [[SQLManager manager] insertMessages:messages completeHandler:nil];
        }
        
        
        if([response isKindOfClass:[TL_updates_differenceEmpty class]]) {
            [self saveDifference:[response seq] date:self.date qts:self.qts];
            self.isUpdated = YES;
           
        }
        if([response isKindOfClass:[TL_updates_difference class]]) {
            self.pts = [[updates state] pts];
            [self saveDifference:[[updates state] seq] date:[[updates state] date] qts:[[updates state] qts]];
            self.isUpdated = YES;
        }
        NSLog(@"-----END UPDATES----- with pts: %d, date: %d, qts: %d",dif.pts,dif.date,dif.qts);
        
        if(intstate != nil) {
            self.pts = [intstate pts];
            [self saveDifference:[intstate seq] date:[intstate date] qts:[intstate qts]];
            self.isUpdated = YES;
            [self updateUpdates:[TLAPI_updates_getDifference createWithPts:intstate.pts date:intstate.date qts:intstate.qts]];
            NSLog(@"-----START NEXT UPDATE-----");

        }
        [Notification perform:PROTOCOL_UPDATED data:nil];
        
    } errorHandler:^(RpcError *error) {
        self.isUpdated = YES;
       // [self updateDifference];
    } timeout:5];

}
@end
