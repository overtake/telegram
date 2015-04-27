//
//  TGProccessUpdates.m
//  Messenger for Telegram
//
//  Created by keepcoder on 28.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGProccessUpdates.h"
#import "TGTimer.h"
#import "Crypto.h"
#import "SelfDestructionController.h"
#import "TGUpdateContainer.h"
#import "AppDelegate.h"
#import "TLPeer+Extensions.h"
#import "PreviewObject.h"
#import "SecretChatAccepter.h"
#import "MessagesUtils.h"
#import "TGDateUtils.h"
#import "TGModernEncryptedUpdates.h"
@interface TGProccessUpdates ()
@property (nonatomic,strong) TGUpdateState *updateState;
@property (nonatomic,strong) NSMutableArray *statefulUpdates;
@property (nonatomic,strong) TGTimer *sequenceTimer;
@property (nonatomic,assign) BOOL holdUpdates;
@property (nonatomic,strong) TGModernEncryptedUpdates *encryptedUpdates;



@end

@implementation TGProccessUpdates

static NSString *kUpdateState = @"kUpdateState";

static ASQueue *queue;

@synthesize updateState = _updateState;
@synthesize statefulUpdates = _statefulUpdates;
@synthesize sequenceTimer = _sequenceTimer;
@synthesize holdUpdates = _holdUpdates;


-(id)init { 
    if(self = [super init]) {
        self.holdUpdates = NO;
        _statefulUpdates = [[NSMutableArray alloc] init];
        
        _updateState = [[Storage manager] updateState];
        
        _encryptedUpdates = [[TGModernEncryptedUpdates alloc] init];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            queue = [[ASQueue alloc] initWithName:"UpdatesQueue"];
        });
    }
    return self;
}

-(id)initWithQueue:(ASQueue *)q {
    if(self = [self init]) {
        self.holdUpdates = NO;
        _statefulUpdates = [[NSMutableArray alloc] init];
        
        _updateState = [[Storage manager] updateState];
        
        _encryptedUpdates = [[TGModernEncryptedUpdates alloc] init];
        
        queue = q;
    }
    return self;
}

- (void)resetStateAndSync {
    
    [queue dispatchOnQueue:^{
        _updateState = [[TGUpdateState alloc] initWithPts:1 qts:1 date:_updateState.date seq:1 pts_count:1];
        
        [self saveUpdateState];
        
        [self uptodate:_updateState.pts qts:_updateState.qts date:_updateState.date updateConnectionState:YES];
    }];
}


-(void)drop {
    
    [queue dispatchOnQueue:^{
        _updateState = nil;
        [[Storage manager] saveUpdateState:_updateState];
        
        [self cancelSequenceTimer];
        [self.statefulUpdates removeAllObjects];
    }];
    
    
}

-(void)processUpdates:(NSArray *)updates stateSeq:(int)stateSeq {
    
    int statePts = 0;
    int stateDate = 0;
    int stateQts = 0;
    int statePts_count = 0;
    
    for(TLUpdate *update in updates) {
        if ([update date] > stateDate)
            stateDate = [update date];
        
        if([update isKindOfClass:[TL_updateNewEncryptedMessage class]]) {
            if ([update qts] > stateQts)
                stateQts = [update qts];
        } else {
            int updatePts = [update pts];
            if (updatePts > statePts)
                statePts = updatePts;
            int updatePts_count = [update pts_count];
            if (updatePts_count > statePts_count)
                statePts_count = updatePts_count;
        }
        
    }
    
   
    [self addStatefullUpdate:updates seq:stateSeq pts:statePts date:stateDate qts:stateQts pts_count:statePts_count];
    
    
}

-(void)addUpdate:(id)update {
    
    [queue dispatchOnQueue:^{
        
        if([update isKindOfClass:[TL_messages_sentMessage class]] ||
           [update isKindOfClass:[TL_messages_affectedHistory class]]) {
            
            [self addStatefullUpdate:update seq:0 pts:[update pts] date:0 qts:0 pts_count:[update pts_count]];
            
            return;
        }
        
        if([update isKindOfClass:[TL_updateShort class]]) {
            [self updateShort:update];
        }
        if([update isKindOfClass:[TL_updatesCombined class]]) {
            TL_updatesCombined *combined = update;
            
            if(_updateState.seq+1 == combined.seq_start) {
                
                [SharedManager proccessGlobalResponse:update];
                
                for (TLUpdate *one in combined.updates) {
                    [self proccessUpdate:one];
                }
                
                _updateState.seq = combined.seq;
                [self saveUpdateState];
                
            } else {
                [self failSequence];
            }
        }
        
        if([update isKindOfClass:[TL_updates class]]) {
            
            [SharedManager proccessGlobalResponse:update];
            [self processUpdates:[update updates] stateSeq:[update seq]];
        }
        
        
        if([update isKindOfClass:[TL_updateShortChatMessage class]]) {
            TL_updateShortChatMessage *shortMessage = update;
            if(![[UsersManager sharedManager] find:shortMessage.from_id] || ![[ChatsManager sharedManager] find:shortMessage.chat_id] || (shortMessage.fwd_from_id > 0 && ![[UsersManager sharedManager] find:shortMessage.fwd_from_id])) {
                [self failSequence];
                return;
            }
            [self addStatefullUpdate:update seq:[shortMessage seq] pts:[shortMessage pts] date:[shortMessage date] qts:0 pts_count:[shortMessage pts_count]];
            
        }
        
        if([update isKindOfClass:[TL_updateShortMessage class]]) {
            TL_updateShortMessage *shortMessage = update;
            if(![[UsersManager sharedManager] find:shortMessage.user_id] || (shortMessage.fwd_from_id > 0 && ![[UsersManager sharedManager] find:shortMessage.fwd_from_id])) {
                [self failSequence];
                return;
            }
            [self addStatefullUpdate:update seq:[shortMessage seq] pts:[shortMessage pts] date:[shortMessage date] qts:0 pts_count:[shortMessage pts_count]];
            
        }
        
        
        if([update isKindOfClass:[TL_updatesTooLong class]]) {
            [self updateDifference];
        }
        
        if([update isKindOfClass:[TL_updateServiceNotification class]]) { // for debug
            [self proccessUpdate:update];
        }
    }];
    
    
}

-(void)addStatefullUpdate:(id)update seq:(int)seq pts:(int)pts date:(int)date qts:(int)qts pts_count:(int)pts_count {
    
    TGUpdateContainer *statefulMessage = [[TGUpdateContainer alloc] initWithSequence:seq pts:pts date:date qts:qts pts_count:pts_count update:update];
    
   
    if(statefulMessage.pts > 0 && _updateState.pts + statefulMessage.pts_count == statefulMessage.pts && !_holdUpdates) {
        [self proccessStatefulMessage:statefulMessage needSave:YES];
        return;
    }
    
    if(statefulMessage.qts > 0 && _updateState.qts + 1 == statefulMessage.qts && !_holdUpdates) {
        [self proccessStatefulMessage:statefulMessage needSave:YES];
        return;
    }
    
    if(statefulMessage.beginSeq > 0 && _updateState.seq + 1 == statefulMessage.beginSeq && !_holdUpdates) {
        [self proccessStatefulMessage:statefulMessage needSave:YES];
        return;
    }
    
    if([statefulMessage isEmpty]) {
        [self proccessStatefulMessage:statefulMessage needSave:NO];
        return;
    }
    
    
    [_statefulUpdates addObject:statefulMessage];
    
    [self cancelSequenceTimer];
    
    _sequenceTimer = [[TGTimer alloc] initWithTimeout:2.0 repeat:NO completion:^{
        [self failSequence];
    } queue:queue.nativeQueue];
    
    [_sequenceTimer start];
    
    [self checkSequence];
}

-(void)failSequence {
    [self cancelSequenceTimer];
    [_statefulUpdates removeAllObjects];
   
    [self updateDifference:NO updateConnectionState:NO];
}

-(void)checkSequence {
    
    if(!_statefulUpdates.count || _holdUpdates)
        return;
    
    [_statefulUpdates sortUsingComparator:^NSComparisonResult(TGUpdateContainer * obj1, TGUpdateContainer * obj2) {
        return obj1.pts < obj2.pts ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    
    if([_statefulUpdates[0] pts] > 0 &&  _updateState.pts + [_statefulUpdates[0] pts_count] != [_statefulUpdates[0] pts] )
        return;
    
    
   __block BOOL fail = NO;
    
    
    NSMutableArray *qtsUpdates = [[NSMutableArray alloc] init];
    NSMutableArray *seqUpdates = [[NSMutableArray alloc] init];
    
    [_statefulUpdates enumerateObjectsUsingBlock:^(TGUpdateContainer *obj, NSUInteger idx, BOOL *stop) {
        
        
        if(obj.pts > 0) {
            if(_updateState.pts + [obj pts_count] == [obj pts]) {
                
                BOOL success = [self proccessStatefulMessage:obj needSave:YES];
                
                if(!success)
                {
                    *stop = YES;
                    fail = YES;
                }
            } else {
                *stop = YES;
                fail = YES;
            }
        } else {
            
            if(obj.qts > 0) {
                [qtsUpdates addObject:obj];
            } else if(obj.beginSeq > 0) {
                [seqUpdates addObject:obj];
            }
            
        }
            
    }];
    
    [_statefulUpdates removeAllObjects];
    
    if(!fail) {
        
        [qtsUpdates sortUsingComparator:^NSComparisonResult(TGUpdateContainer * obj1, TGUpdateContainer * obj2) {
            return obj1.qts < obj2.qts ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        [qtsUpdates enumerateObjectsUsingBlock:^(TGUpdateContainer  *obj, NSUInteger idx, BOOL *stop) {
            
            if(_updateState.qts + 1 == [obj qts]) {
                
                BOOL success = [self proccessStatefulMessage:obj needSave:YES];
                
                if(!success)
                {
                    *stop = YES;
                    fail = YES;
                }
            } else {
                *stop = YES;
                fail = YES;
            }
            
        }];
        
        
        if(!fail) {
            
            [seqUpdates sortUsingComparator:^NSComparisonResult(TGUpdateContainer * obj1, TGUpdateContainer * obj2) {
                return obj1.beginSeq < obj2.beginSeq ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            [seqUpdates enumerateObjectsUsingBlock:^(TGUpdateContainer  *obj, NSUInteger idx, BOOL *stop) {
                
                if(_updateState.seq + 1 == [obj beginSeq]) {
                    
                    BOOL success = [self proccessStatefulMessage:obj needSave:YES];
                    
                    if(!success)
                    {
                        *stop = YES;
                        fail = YES;
                    }
                } else {
                    *stop = YES;
                    fail = YES;
                }
                
            }];
        }
        
    }
    
    
    if (!fail)
    {
        [self cancelSequenceTimer];
    }
}

-(void)applyUpdate:(TGUpdateContainer *)container {
    
    _updateState.seq = container.beginSeq;
    
    _updateState.pts = container.pts;
    
    _updateState.date = container.date;
    
    _updateState.qts = container.qts;
    
    [self saveUpdateState];
}


-(BOOL)proccessStatefulMessage:(TGUpdateContainer *)container needSave:(BOOL)needSave {
    
    if([container.update isKindOfClass:[TL_updateShortChatMessage class]]) {
        
        TL_updateShortChatMessage *shortMessage = (TL_updateShortChatMessage *) container.update;
        
        if(![[UsersManager sharedManager] find:[shortMessage from_id]] || ![[ChatsManager sharedManager] find:shortMessage.chat_id]) {
            [self failSequence];
            return NO;
        }
        
        TL_localMessage *message = [TL_localMessage createWithN_id:shortMessage.n_id flags:shortMessage.flags from_id:[shortMessage from_id] to_id:[TL_peerChat createWithChat_id:shortMessage.chat_id] fwd_from_id:shortMessage.fwd_from_id fwd_date:shortMessage.fwd_date reply_to_msg_id:shortMessage.reply_to_msg_id date:shortMessage.date message:shortMessage.message media:[TL_messageMediaEmpty create] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() state:DeliveryStateNormal];
        
         if(message.reply_to_msg_id != 0 && message.replyMessage == nil) {
             [self failSequence];
             return NO;
         }
        
        [MessagesManager addAndUpdateMessage:message];
    }
    
    if([container.update isKindOfClass:[TL_updateShortMessage class]]) {
        TL_updateShortMessage *shortMessage = (TL_updateShortMessage *) container.update;
        
        if(![[UsersManager sharedManager] find:[shortMessage user_id]]) {
            [self failSequence];
            return NO;
        }
        
        TL_localMessage *message = [TL_localMessage createWithN_id:shortMessage.n_id flags:shortMessage.flags from_id:[shortMessage user_id] to_id:[TL_peerUser createWithUser_id:[shortMessage user_id]] fwd_from_id:shortMessage.fwd_from_id fwd_date:shortMessage.fwd_date reply_to_msg_id:shortMessage.reply_to_msg_id date:shortMessage.date message:shortMessage.message media:[TL_messageMediaEmpty create] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() state:DeliveryStateNormal];
        
        if(message.n_out) {
            message.from_id = [UsersManager currentUserId];
        } else {
            message.to_id.user_id = [UsersManager currentUserId];
        }
        
        if(message.reply_to_msg_id != 0 && message.replyMessage == nil) {
            [self failSequence];
            return NO;
        }
        
        [MessagesManager addAndUpdateMessage:message];
    }
    
    if([container.update isKindOfClass:[NSArray class]]) {
        for (TLUpdate *update in container.update) {
            [self proccessUpdate:update];
        }
    }
    
    if(needSave)
        [self applyUpdate:container];
    
    return YES;
    
}


-(void)updateShort:(TL_updateShort *)shortUpdate {
    
    _updateState.date = [shortUpdate date];
    [self saveUpdateState];
    
    [self proccessUpdate:shortUpdate.update];
}

+(void)checkAndLoadIfNeededSupportMessages:(NSArray *)messages {
    [self checkAndLoadIfNeededSupportMessages:messages asyncCompletionHandler:nil];
}

+(void)checkAndLoadIfNeededSupportMessages:(NSArray *)messages asyncCompletionHandler:(dispatch_block_t)completionHandler {
    
   NSMutableArray *supportMessages = [[NSMutableArray alloc] init];
        
    [messages enumerateObjectsUsingBlock:^(TL_localMessage * obj, NSUInteger idx, BOOL *stop) {
            
        if(obj.reply_to_msg_id != 0 && obj.replyMessage == nil) {
            [supportMessages addObject:@(obj.reply_to_msg_id)];
        } 
            
    }];
        
    if(supportMessages.count > 0)
    {
      
        [self loadSupportSyncMessages:supportMessages syncCompletionHandler:completionHandler];
    
    } else if(completionHandler != nil) {
        
        completionHandler();
       
    }


}

+(void)loadSupportSyncMessages:(NSArray *)ids syncCompletionHandler:(dispatch_block_t)completionHandler {
    
    
    dispatch_semaphore_t semaphore = NULL;
    
    if(completionHandler == nil) {
       semaphore = dispatch_semaphore_create(0);
    }
    
    [RPCRequest sendRequest:[TLAPI_messages_getMessages createWithN_id:[ids mutableCopy]] successHandler:^(RPCRequest *request, TL_messages_messages *response) {
        
        NSMutableArray *messages = [response.messages mutableCopy];
        
        [[response messages] removeAllObjects];
        
        [SharedManager proccessGlobalResponse:response];
        
        [TL_localMessage convertReceivedMessages:messages];
        
        [[Storage manager] addSupportMessages:messages];
        [[MessagesManager sharedManager] addSupportMessages:messages];
        
        
        if(completionHandler == nil) {
            dispatch_semaphore_signal(semaphore);
        } else {
            completionHandler();
        }
        
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
    }];
    
    if(completionHandler == nil) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_release(semaphore);
    }
    
   
}


-(void)proccessUpdate:(TLUpdate *)update {
    
    if([update isKindOfClass:[TL_updateWebPage class]]) {
        
        TLWebPage *page = [update webpage];
        
        NSArray *updateMessages = [[MessagesManager sharedManager] findWithWebPageId:page.n_id];
        
        NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:updateMessages.count];
        
        [updateMessages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            
            obj.media.webpage = page;
            
            [ids addObject:@(obj.n_id)];
        
        }];
        
        [[Storage manager] updateMessages:updateMessages];
        
        [Notification perform:UPDATE_WEB_PAGES data:@{KEY_WEBPAGE:page}];
        
        [Notification perform:UPDATE_WEB_PAGE_ITEMS data:@{KEY_MESSAGE_ID_LIST:ids}];
        
    }
    
    if([update isKindOfClass:[TL_updateMessageID class]]) {
        
        TL_localMessage *msg = [[MessagesManager sharedManager] findWithRandomId:[update random_id]];
        
        msg.n_id = [update n_id];
        
        if(msg) {
            [[MessagesManager sharedManager] add:@[msg]];
        }
        
        
        
        [[Storage manager] updateMessageId:update.random_id msg_id:[update n_id]];
        
        return;
        
    }
    
    if([update isKindOfClass:[TL_updateNewMessage class]]) {
        
        TL_localMessage *message = [TL_localMessage convertReceivedMessage:(TL_localMessage *)[update message]];
        
        if(message.reply_to_msg_id != 0 && message.replyMessage == nil) {
            [self failSequence];
            return;
        }
        
        return [MessagesManager addAndUpdateMessage:message];
    }
    
    
    if([update isKindOfClass:[TL_updateReadHistoryInbox class]]) {
        [[DialogsManager sharedManager] markAllMessagesAsRead:update.peer max_id:update.max_id];
        return;
    }
    
    if([update isKindOfClass:[TL_updateReadHistoryOutbox class]]) {
        [[DialogsManager sharedManager] markAllMessagesAsRead:update.peer max_id:update.max_id];
        return;
    }
    
    if([update isKindOfClass:[TL_updateReadMessagesContents class]]) {
        [[MessagesManager sharedManager] readMessagesContent:[[update messages] copy]];
    }
    
    if([update isKindOfClass:[TL_updateDeleteMessages class]]) {
        [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_MESSAGE_ID_LIST:[update messages]}];
        return;
    }
    
    if([update isKindOfClass:[TL_updateUserName class]]) {
        
        
        TLUser *user = [[UsersManager sharedManager] find:update.user_id];
        
        if(user) {
            
            TLUser *copy = [user copy];
            
            copy.first_name = update.first_name;
            copy.last_name = update.last_name;
            copy.username = update.username;
            [[UsersManager sharedManager] add:@[copy]];
            
        }
       
        
        return;
    }
    
    if([update isKindOfClass:[TL_updateServiceNotification class]]) {
        
        
        TL_updateServiceNotification *updateNotification = (TL_updateServiceNotification *)update;
        
        TL_conversation *conversation = [[Storage manager] selectConversation:[TL_peerUser createWithUser_id:777000]];
        TLUser *user = [[UsersManager sharedManager] find:777000];
        if(!conversation) {
            conversation = [[DialogsManager sharedManager] createDialogForUser:user];
            [conversation save];
        }
        
        TL_localMessage *msg = [TL_localMessage createWithN_id:0 flags:TGUNREADMESSAGE from_id:777000 to_id:[TL_peerUser createWithUser_id:[UsersManager currentUserId]] fwd_from_id:0 fwd_date:0 reply_to_msg_id:0  date:[[MTNetwork instance] getTime] message:updateNotification.message media:updateNotification.media fakeId:[MessageSender getFakeMessageId] randomId:rand_long() state:DeliveryStateNormal];
        
        [MessagesManager addAndUpdateMessage:msg];
        
        
        if(updateNotification.popup) {
            [[ASQueue mainQueue] dispatchOnQueue:^{
                alert(NSLocalizedString(@"UpdateNotification.Alert", nil), updateNotification.message);
            }];
            
        }
        
        
        return;
    }
    
    if([update isKindOfClass:[TL_updateNotifySettings class]]) {
        
        TL_updateNotifySettings *notifyUpdate = (TL_updateNotifySettings *)update;
        
        TL_notifyPeer *peer = (TL_notifyPeer *) notifyUpdate.peer;
        
        TL_conversation *dialog = [[DialogsManager sharedManager] find:peer.peer.peer_id];
        
        if(!dialog) {
            dialog = [[Storage manager] selectConversation:peer.peer];
        }
        
        if(dialog) {
            [dialog updateNotifySettings:notifyUpdate.notify_settings];
        }
        return;
    }
    
    if([update isKindOfClass:[TL_updateChatParticipants class]]) {
        TLChatParticipants *chatParticipants = ((TL_updateChatParticipants *)update).participants;
        
        TLChatFull *fullChat = [[FullChatManager sharedManager] find:chatParticipants.chat_id];
        if(!fullChat) {
            [[FullChatManager sharedManager] loadIfNeed:chatParticipants.chat_id];
            return;
        }
        
        fullChat.participants = chatParticipants;
        [[Storage manager] insertFullChat:fullChat completeHandler:nil];
        
        [Notification perform:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT_ID: @(fullChat.n_id), @"participants": fullChat.participants}];
        return;
    }
    
    if([update isKindOfClass:[TL_updateContactLink class]]) {
        TL_updateContactLink *contactLink = (TL_updateContactLink *)update;
        
        BOOL isContact = [contactLink.my_link isKindOfClass:[TL_contactLinkContact class]];
        
        
        DLog(@"%@ contact %d", isContact ? @"add" : @"delete", contactLink.user_id);
        
        
        TLUser *user = [[[UsersManager sharedManager] find:contactLink.user_id] copy];
        
        if([contactLink.my_link isKindOfClass:[TL_contactLinkContact class]]) {
            user.type = TLUserTypeContact;
        } else if([contactLink.my_link isKindOfClass:[TL_contactLinkHasPhone class]]) {
            user.type = TLUserTypeRequest;
        } else {
            user.type = TLUserTypeForeign;
        }
        
        
        [[UsersManager sharedManager] add:@[user]];
        
        if(isContact) {
            [[NewContactsManager sharedManager] insertContact:[TL_contact createWithUser_id:contactLink.user_id mutual:NO]];
        } else {
            [[NewContactsManager sharedManager] removeContact:[TL_contact createWithUser_id:contactLink.user_id mutual:NO]];
        }
        return;
    }
    
    if([update isKindOfClass:[TL_updateEncryption class]]) {
        TL_encryptedChat *chat = (TL_encryptedChat *) [update chat];
        if(chat) {
            
            if([chat isKindOfClass:[TL_encryptedChatRequested class]]) {
                [[ChatsManager sharedManager] acceptEncryption:(TL_encryptedChatRequested *)chat]; 
            }
            
            if([chat isKindOfClass:[TL_encryptedChat class]]) {
               
                EncryptedParams *params = [EncryptedParams findAndCreate:chat.n_id];
                
                NSData *key_hash = [Crypto exp:[chat g_a_or_b] b:[params a] dhPrime:params.p];
                NSData *key_fingerprints = [[Crypto sha1:key_hash] subdataWithRange:NSMakeRange(12, 8)];
                long keyId;
                [key_fingerprints getBytes:&keyId];
                
                 params.key_fingerprint = keyId;
                
                [params setKey:key_hash forFingerprint:keyId];
                
                params.access_hash = chat.access_hash;
                [params setState:EncryptedAllowed];
                [params save];
                [[Storage manager] insertEncryptedChat:chat];
                [[ChatsManager sharedManager] add:@[chat]];
                
                if(!chat.dialog) {
                    TL_conversation *conversation = [[Storage manager] selectConversation:[TL_peerSecret createWithChat_id:chat.n_id]];
                    if(conversation) {
                         [[DialogsManager sharedManager] add:@[conversation]];
                    }
                   
                }
                
                [Notification perform:[Notification notificationNameByDialog:chat.dialog action:@"message"] data:@{KEY_DIALOG:chat.dialog}];
               
                [MessagesManager notifyConversation:chat.dialog.peer.peer_id title:chat.peerUser.fullName text:NSLocalizedString(@"MessageService.Action.JoinedSecretChat", nil)];
                                
            }
            
            if([chat isKindOfClass:[TL_encryptedChatDiscarded class]]) {
                
                TL_encryptedChat *local = [[ChatsManager sharedManager] find:[chat n_id]];
                if(!local)
                    return;
                
                
                
                EncryptedParams *params = [EncryptedParams findAndCreate:[chat n_id]];
                [params setState:EncryptedDiscarted];
                [params save];
                
                 [Notification perform:[Notification notificationNameByDialog:local.dialog action:@"message"] data:@{KEY_DIALOG:chat.dialog}];
                
                
                [SecretChatAccepter removeChatId:chat.n_id];
                
            }
            if([chat isKindOfClass:[TL_encryptedChatEmpty class]]) {
                
            }
        }
        return;
    }
    
    if([update isKindOfClass:[TL_updateNewEncryptedMessage class]]) {
        
        [_encryptedUpdates proccessUpdate:(TLEncryptedMessage *)[update message]];
        
        return;
    }
    
    if([update isKindOfClass:[TL_updateEncryptedMessagesRead class]]) {
        TL_conversation *dialog = [[DialogsManager sharedManager] findBySecretId:update.chat_id];
        if(dialog) {
            [[DialogsManager sharedManager] markAllMessagesAsRead:dialog];
        }
        return;
    }
    
    if([update isKindOfClass:[TL_updateUserPhoto class]]) {
        TLUser *user = [[UsersManager sharedManager] find:update.user_id];
        
        user.photo = [update photo];
        
        if(user) {
            [[Storage manager] insertUser:user completeHandler:nil];
            PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:user.photo.photo_id media:[TL_photoSize createWithType:@"x" location:user.photo.photo_big w:640 h:640 size:0] peer_id:user.n_id];
            [Notification perform:USER_UPDATE_PHOTO data:@{KEY_USER:user,KEY_PREVIOUS:@([update previous]), KEY_PREVIEW_OBJECT:previewObject}];
        }
        
        return;
    }
    
    if([update isKindOfClass:[TL_updateUserStatus class]]) {
        
//        if(update.user_id == [UsersManager currentUserId]) {
//            [[Telegram sharedInstance] setIsOnline:NO];
//            [[Telegram sharedInstance] setAccountOnline];
//        
//            return;
//        }
        [[UsersManager sharedManager] setUserStatus:[update status] forUid:update.user_id];

        return;
    }
    
    
    if([update isKindOfClass:[TL_updateChatUserTyping class]] || [update isKindOfClass:[TL_updateUserTyping class]] || [update isKindOfClass:[TL_updateEncryptedChatTyping class]]) {
        [Notification perform:USER_TYPING data:@{KEY_SHORT_UPDATE:update}];
        return;
    }
    
    if([update isKindOfClass:[TL_updateUserBlocked class]]) {
        BOOL blocked = ((TL_updateUserBlocked *)update).blocked;
        int user_id = ((TL_updateUserBlocked *)update).user_id;
        
        [[BlockedUsersManager sharedManager] updateBlocked:user_id isBlocked:blocked];
    }
    
    if([update isKindOfClass:[TL_updateNewAuthorization class]]) {
        
        
        TL_conversation *conversation = [[Storage manager] selectConversation:[TL_peerUser createWithUser_id:777000]];
        TLUser *user = [[UsersManager sharedManager] find:777000];
        if(!conversation) {
            conversation = [[DialogsManager sharedManager] createDialogForUser:user];
            [conversation save];
        }
        
         NSString *displayDate = [[NSString alloc] initWithFormat:@"%@, %@ at %@", [TGDateUtils stringForDayOfWeek:update.date], [TGDateUtils stringForDialogTime:update.date], [TGDateUtils stringForShortTime:update.date]];
        
        NSString *messageText = [[NSString alloc] initWithFormat:NSLocalizedString(@"Notification.NewAuthDetected",nil), [UsersManager currentUser].first_name, displayDate, update.device, update.location];;
        
        TL_localMessage *msg = [TL_localMessage createWithN_id:0 flags:TGUNREADMESSAGE from_id:777000 to_id:[TL_peerUser createWithUser_id:[UsersManager currentUserId]] fwd_from_id:0 fwd_date:0 reply_to_msg_id:0 date:[[MTNetwork instance] getTime] message:messageText media:[TL_messageMediaEmpty create] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() state:DeliveryStateNormal];
        
        [MessagesManager addAndUpdateMessage:msg];
        
        return;
    }
    
    if([update isKindOfClass:[TL_updateContactRegistered class]]) {
        
        TLUser *user = [[UsersManager sharedManager] find:[update user_id]];
        
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Notification.UserRegistred", nil),user.fullName];
        
        TL_localMessageService *message = [TL_localMessageService createWithN_id:0 flags:TGOUTMESSAGE from_id:[update user_id] to_id:[TL_peerUser createWithUser_id:[update user_id]] date:[update date] action:[TL_messageActionEncryptedChat createWithTitle:text] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
        
        [MessagesManager addAndUpdateMessage:message];

        return;
    }
    
    if([update isKindOfClass:[TL_updatePrivacy class]]) {
        
        
        
        PrivacyArchiver *privacy = [PrivacyArchiver privacyFromRules:[(TL_updatePrivacy *)update rules] forKey:NSStringFromClass([(TL_updatePrivacy *)update n_key].class)];
        
        [privacy _save];
        
        
        [[NewContactsManager sharedManager] getStatuses:^{
            [Notification perform:PRIVACY_UPDATE data:@{KEY_PRIVACY:privacy}];
        }];
        
    }
    
}

-(void)cancelSequenceTimer {
    if(_sequenceTimer) {
        
        [_sequenceTimer invalidate];
        _sequenceTimer = nil;
        
    }
}

-(void)updateDifference {
    [self updateDifference:NO updateConnectionState:YES];
}

-(void)updateDifference:(BOOL)force updateConnectionState:(BOOL)updateConnectionState  {
    
   if(_holdUpdates || ![[MTNetwork instance] isAuth] ) return;
   
    _holdUpdates = YES;
    
    if( !_updateState || force) {
        
        [RPCRequest sendRequest:[TLAPI_updates_getState create] successHandler:^(RPCRequest *request, TL_updates_state * state) {
    
            _updateState = [[TGUpdateState alloc] initWithPts:_updateState.pts == 0 ? state.pts : _updateState.pts qts:_updateState.qts == 0 ? state.qts : _updateState.qts date:_updateState.date == 0 ? state.date : _updateState.date seq:_updateState.seq == 0 ? state.seq : _updateState.seq pts_count:_updateState.pts_count];

            [self saveUpdateState];
            
            MessagesManager *manager = [MessagesManager sharedManager];
            
            manager.unread_count = state.unread_count;
            
            _holdUpdates = NO;
            
            [self uptodate:_updateState.pts qts:_updateState.qts date:_updateState.date updateConnectionState:updateConnectionState];
            
        } errorHandler:nil];
    } else {
        _holdUpdates = NO;
        [self uptodate:_updateState.pts qts:_updateState.qts date:_updateState.date updateConnectionState:updateConnectionState];
    }
}





-(void)uptodate:(int)pts qts:(int)qts date:(int)date updateConnectionState:(BOOL)updateConnectionState  {
    
    if(_holdUpdates || ![[MTNetwork instance] isAuth] ) return;
    
    _holdUpdates = YES;
    
    if(updateConnectionState)
        [Telegram setConnectionState:ConnectingStatusTypeUpdating];
    
    TLAPI_updates_getDifference *dif = [TLAPI_updates_getDifference createWithPts:pts date:date qts:qts];
    [RPCRequest sendRequest:dif successHandler:^(RPCRequest *request, id response)  {
        
        TL_updates_difference *updates = response;
        
        int stateQts = _updateState.qts;
        int statePts = _updateState.pts;
        int stateDate = _updateState.date;
        int stateSeq = _updateState.seq;        
        
        if([response isKindOfClass:[TL_updates_difference class]]) {
            stateQts = [[updates state] qts];
            statePts = [[updates state] pts];
            stateSeq = [[updates state] seq];
            stateDate = [[updates state] date];
        }
        
        
        TLupdates_State * intstate;
        if([response isKindOfClass:[TL_updates_differenceSlice class]]) {
            intstate = [response intermediate_state];
            
            stateQts = [intstate qts];
            statePts = [intstate pts];
            stateDate = [intstate date];
            stateSeq = [intstate seq];
        }
        
        
        for (TL_encryptedMessage *enmsg in [updates n_encrypted_messages]) {
            [self.encryptedUpdates proccessUpdate:enmsg];
        }
        
        NSMutableArray *copy = [[response n_messages] mutableCopy];
       
        
        
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        
        
        [copy enumerateObjectsUsingBlock:^(TLMessage *obj, NSUInteger idx, BOOL *stop) {
            [ids addObject:@(obj.n_id)];
        }];
        
        if(ids.count > 0) {
            [[Storage manager] messages:^(NSArray *res) {
                if(res.count > 0) {
                    [ids removeAllObjects];
                    
                    [res enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
                        [ids addObject:@(obj.n_id)];
                    }];
                    
                    NSArray *f = [copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id IN %@",ids]];
                    
                    [copy removeObjectsInArray:f];
                }
            } forIds:ids random:NO sync:YES];
        }
    
        
        
        
        [response setN_messages:copy];
        
        [SharedManager proccessGlobalResponse:updates];
        
        
        for (TLUpdate *update in [updates other_updates]) {
            [self proccessUpdate:update];
        }
        
        [TGProccessUpdates checkAndLoadIfNeededSupportMessages:[response n_messages] asyncCompletionHandler:^{
            
           
            [queue dispatchOnQueue:^{
                
                if([response n_messages].count > 0) {
                    [Notification perform:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:[response n_messages]}];
                    [Notification perform:MESSAGE_LIST_RECEIVE object:[response n_messages]];
                }
                
                
                _updateState.checkMinimum = NO;
                _updateState.qts = stateQts;
                _updateState.pts = statePts;
                _updateState.date = stateDate;
                _updateState.seq = stateSeq;
                _updateState.checkMinimum = YES;
                
                [self saveUpdateState];
                
                _holdUpdates = NO;
                
                if(intstate != nil) {
                    [self uptodate:statePts qts:stateQts date:stateDate updateConnectionState:updateConnectionState];
                } else {
                    [Notification perform:PROTOCOL_UPDATED data:nil];
                    [Telegram setConnectionState:ConnectingStatusTypeNormal];
                }

            }];
            
        }];
        
       
       
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        _holdUpdates = NO;
        if(error.error_code == 502) {
            [self uptodate:pts qts:qts date:date updateConnectionState:updateConnectionState];
        } else {
            [self updateDifference:YES updateConnectionState:updateConnectionState];
        }
    } timeout:10 queue:queue.nativeQueue];

}


-(void)saveUpdateState {
    [[Storage manager] saveUpdateState:_updateState];
}


@end
