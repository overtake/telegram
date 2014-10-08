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
#import "TGPeer+Extensions.h"
#import "PreviewObject.h"
#import "SecretChatAccepter.h"
#import "MessagesUtils.h"
#import "TGDateUtils.h"
@interface TGProccessUpdates ()
@property (nonatomic,strong) TGUpdateState *updateState;
@property (nonatomic,strong) NSMutableArray *statefulUpdates;
@property (nonatomic,strong) TGTimer *sequenceTimer;
@property (nonatomic,assign) BOOL holdUpdates;
@end

@implementation TGProccessUpdates

static NSString *kUpdateState = @"kUpdateState";

@synthesize updateState = _updateState;
@synthesize statefulUpdates = _statefulUpdates;
@synthesize sequenceTimer = _sequenceTimer;
@synthesize holdUpdates = _holdUpdates;


-(id)init {
    if(self = [super init]) {
        self.holdUpdates = NO;
        _statefulUpdates = [[NSMutableArray alloc] init];
        
        _updateState = [[Storage manager] updateState];
    }
    return self;
}

- (void)resetStateAndSync {
    
    [ASQueue dispatchOnStageQueue:^{
        _updateState = [[TGUpdateState alloc] initWithPts:1 qts:1 date:_updateState.date seq:1];
        
        [self saveUpdateState];
        
        [self uptodate:_updateState.pts qts:_updateState.qts date:_updateState.date];
    }];
}


-(void)drop {
    
    _updateState = nil;
    [[Storage manager] saveUpdateState:_updateState];

    [self cancelSequenceTimer];
    [self.statefulUpdates removeAllObjects];
}

-(void)processUpdates:(NSArray *)updates stateSeq:(int)stateSeq {
    
    int statePts = 0;
    int stateDate = 0;
    int stateQts = 0;
    
    
    for(TGUpdate *update in updates) {
        if ([update date] > stateDate)
            stateDate = [update date];
        
        if([update isKindOfClass:[TL_updateNewEncryptedMessage class]]) {
            if ([update qts] > stateQts)
                stateQts = [update qts];
        } else {
            int updatePts = [update pts];
            if (updatePts > statePts)
                statePts = updatePts;
        }
        
    }
    
   
    [self addStatefullUpdate:updates seq:stateSeq pts:statePts date:stateDate qts:stateQts];
    
    
}

-(void)addUpdate:(id)update {
    
    
    if([update isKindOfClass:[TL_messages_statedMessage class]] ||
       [update isKindOfClass:[TL_messages_statedMessageLink class]] ||
       [update isKindOfClass:[TL_messages_statedMessages class]] ||
       [update isKindOfClass:[TL_messages_statedMessagesLinks class]] ||
       [update isKindOfClass:[TL_messages_sentMessage class]] ||
       [update isKindOfClass:[TL_messages_affectedHistory class]]) {
        
        [self addStatefullUpdate:update seq:[update seq] pts:[update pts] date:0 qts:0];
        
    }
    
    if([update isKindOfClass:[TL_updateShort class]]) {
        [self updateShort:update];
    }
    if([update isKindOfClass:[TL_updatesCombined class]]) {
        TL_updatesCombined *combined = update;
        
        if(_updateState.seq+1 == combined.seq_start) {
            
            [SharedManager proccessGlobalResponse:update];
            
            for (TGUpdate *one in combined.updates) {
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
        if(![[UsersManager sharedManager] find:shortMessage.from_id] || ![[ChatsManager sharedManager] find:shortMessage.chat_id]) {
            [self failSequence];
            return;
        }
        [self addStatefullUpdate:update seq:[shortMessage seq] pts:[shortMessage pts] date:[shortMessage date] qts:0];
        
    }
    
    if([update isKindOfClass:[TL_updateShortMessage class]]) {
        TL_updateShortMessage *shortMessage = update;
        if(![[UsersManager sharedManager] find:shortMessage.from_id]) {
            [self failSequence];
            return;
        }
        [self addStatefullUpdate:update seq:[shortMessage seq] pts:[shortMessage pts] date:[shortMessage date] qts:0];
        
    }
    
    
    if([update isKindOfClass:[TL_updatesTooLong class]]) {
        [self updateDifference];
    }
    
}

-(void)addStatefullUpdate:(id)update seq:(int)seq pts:(int)pts date:(int)date qts:(int)qts {
    
    TGUpdateContainer *statefulMessage = [[TGUpdateContainer alloc] initWithSequence:seq pts:pts date:date qts:qts update:update];
    
   
    if(_updateState.seq+1 == statefulMessage.beginSeq && !_holdUpdates) {
        [self proccessStatefulMessage:statefulMessage needSave:YES];
        return;
    }
    
    [_statefulUpdates addObject:statefulMessage];
    
    
    
    
    [self cancelSequenceTimer];
    
    _sequenceTimer = [[TGTimer alloc] initWithTimeout:2.0 repeat:NO completion:^{
        [self failSequence];
    } queue:dispatch_get_current_queue()];
    
    [_sequenceTimer start];
    
    [self checkSequence];
}

-(void)failSequence {
    [self cancelSequenceTimer];
    [_statefulUpdates removeAllObjects];
   
    [self updateDifference];
}

-(void)checkSequence {
    
    if(!_statefulUpdates.count || _holdUpdates)
        return;
    
    
    
    [_statefulUpdates sortUsingComparator:^NSComparisonResult(TGUpdateContainer * obj1, TGUpdateContainer * obj2) {
        return obj1.beginSeq < obj2.beginSeq ? NSOrderedAscending : NSOrderedDescending;
    }];
    
   
    
   
    
    NSMutableArray *successful = [[NSMutableArray alloc] init];
    
    
    if(_updateState.seq+1 != [_statefulUpdates[0] beginSeq])
        return;
    
    
    
    int lastSeq = _updateState.seq;
    TGUpdateContainer *lastUpdate;
    for (int i = 0; i < _statefulUpdates.count; i++) {
       if(lastSeq+1 == [_statefulUpdates[i] beginSeq]) {
            lastUpdate = _statefulUpdates[i];
            [successful addObject:lastUpdate];
            lastSeq = lastUpdate.beginSeq;
       } else {
           break;
       }
        
    }
    
    if(!lastUpdate)
        return;
    
    [successful sortUsingComparator:^NSComparisonResult(TGUpdateContainer * obj1, TGUpdateContainer * obj2) {
        return obj1.pts < obj2.pts ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    
    for (TGUpdateContainer *successUpdate in successful) {
        [self proccessStatefulMessage:successUpdate needSave:NO];
        [_statefulUpdates removeObject:successUpdate];
    }
    
    [self applyUpdate:lastUpdate];
    
    
    if (_statefulUpdates.count == 0)
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


-(void)proccessStatefulMessage:(TGUpdateContainer *)container needSave:(BOOL)needSave {
    
    if(needSave)
        [self applyUpdate:container];
    
    
    if([container.update isKindOfClass:[TL_updateShortChatMessage class]]) {
        
        TL_updateShortChatMessage *shortMessage = (TL_updateShortChatMessage *) container.update;
        
        TL_localMessage *message = [TL_localMessage createWithN_id:shortMessage.n_id from_id:[shortMessage from_id] to_id:[TL_peerChat createWithChat_id:shortMessage.chat_id] n_out:NO unread:YES date:shortMessage.date message:shortMessage.message media:[TL_messageMediaEmpty create] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() state:DeliveryStateNormal];
        
        [MessagesManager addAndUpdateMessage:message];
    }
    
    if([container.update isKindOfClass:[TL_updateShortMessage class]]) {
        TL_updateShortMessage *shortMessage = (TL_updateShortMessage *) container.update;
        
        TL_localMessage *message = [TL_localMessage createWithN_id:shortMessage.n_id from_id:[shortMessage from_id] to_id:[TL_peerUser createWithUser_id:UsersManager.currentUserId] n_out:NO unread:YES date:shortMessage.date message:shortMessage.message media:[TL_messageMediaEmpty create] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() state:DeliveryStateNormal];
        
        [MessagesManager addAndUpdateMessage:message];
    }
    
    if([container.update isKindOfClass:[NSArray class]]) {
        for (TGUpdate *update in container.update) {
            [self proccessUpdate:update];
        }
    }
    
}


-(void)updateShort:(TL_updateShort *)shortUpdate {
    _updateState.date = [shortUpdate date];
    [self saveUpdateState];
    
    [self proccessUpdate:shortUpdate.update];
}

-(void)proccessUpdate:(TGUpdate *)update {
    
    
    if([update isKindOfClass:[TL_updateNewMessage class]]) {
        
        TL_localMessage *message = [TL_localMessage convertReceivedMessage:[update message]];
        
        return [MessagesManager addAndUpdateMessage:message];
    }
    
    if([update isKindOfClass:[TL_updateReadMessages class]]) {
        
        for(NSNumber *mgsId in [update messages]) {
            TL_localMessage *message = [[MessagesManager sharedManager] find:[mgsId intValue]];
            message.unread = NO;
        }
        
        [Notification perform:MESSAGE_READ_EVENT data:@{KEY_MESSAGE_ID_LIST:[update messages]}];
        return;
    }
    
    if([update isKindOfClass:[TL_updateDeleteMessages class]]) {
        [[Storage manager] deleteMessages:[update messages] completeHandler:^(BOOL result) {
            [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_MESSAGE_ID_LIST:[update messages]}];
        }];
        return;
    }
    
    if([update isKindOfClass:[TL_updateUserName class]]) {
        
        return;
    }
    
    if([update isKindOfClass:[TL_updateNotifySettings class]]) {
        
        TL_updateNotifySettings *notifyUpdate = (TL_updateNotifySettings *)update;
        
        TL_conversation *dialog = [[DialogsManager sharedManager] find:notifyUpdate.peer.peer.peer_id];
        if(dialog) {
            [dialog updateNotifySettings:notifyUpdate.notify_settings];
        }
        return;
    }
    
    if([update isKindOfClass:[TL_updateChatParticipants class]]) {
        TGChatParticipants *chatParticipants = ((TL_updateChatParticipants *)update).participants;
        
        TGChatFull *fullChat = [[FullChatManager sharedManager] find:chatParticipants.chat_id];
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
        TL_encryptedChat *chat = (TL_encryptedChat *) [update chat];
        if(chat) {
            
            if([chat isKindOfClass:[TL_encryptedChatRequested class]]) {
                [[ChatsManager sharedManager] acceptEncryption:(TL_encryptedChatRequested *)chat]; 
            }
            
            if([chat isKindOfClass:[TL_encryptedChat class]]) {
               
                EncryptedParams *params = [EncryptedParams findAndCreate:chat.n_id];
                
                NSData *key_hash = [Crypto exp:[chat g_a_or_b] b:[params a] dhPrime:params.dh_prime];
                NSData *key_fingerprints = [[Crypto sha1:key_hash] subdataWithRange:NSMakeRange(12, 8)];
                long keyId;
                [key_fingerprints getBytes:&keyId];
                
                
                params.key_fingerprints = keyId;
                params.encrypt_key = key_hash;
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
               
                [MessagesManager notifyConversation:chat.dialog.peer.peer_id title:chat.peerUser.fullName text:NSLocalizedString(@"MessageService.Action.JoinedSecretChat", nil)];
                
                [Notification perform:[Notification notificationNameByDialog:chat.dialog action:@"message"] data:nil];
                
            }
            
            if([chat isKindOfClass:[TL_encryptedChatDiscarded class]]) {
                
                TL_encryptedChat *local = [[ChatsManager sharedManager] find:[chat n_id]];
                if(!local)
                    return;
                
                
                
                EncryptedParams *params = [EncryptedParams findAndCreate:[chat n_id]];
                [params setState:EncryptedDiscarted];
                [params save];
                
                [Notification perform:[Notification notificationNameByDialog:local.dialog action:@"message"] data:nil];
                
                
                [SecretChatAccepter removeChatId:chat.n_id];
                
            }
            if([chat isKindOfClass:[TL_encryptedChatEmpty class]]) {
                
            }
        }
        return;
    }
    
    if([update isKindOfClass:[TL_updateNewEncryptedMessage class]]) {
        TL_encryptedChat *chat = [[ChatsManager sharedManager] find:[[update encrypted_message] chat_id]];
        if(chat) {
            TL_encryptedMessage *message = (TL_encryptedMessage *) [update encrypted_message];
            TGMessage *msg = [MessagesManager defaultMessage:message];
            [MessagesManager addAndUpdateMessage:msg];
        }
       
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
        TGUser *user = [[UsersManager sharedManager] find:update.user_id];
        user.photo = [update photo];
        
        if(user) {
            [[Storage manager] insertUser:user completeHandler:nil];
            PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:(int)[@(rand_long()) hash] media:user.photo.photo_big peer_id:user.n_id];
            [Notification perform:USER_UPDATE_PHOTO data:@{KEY_USER:user,KEY_PREVIOUS:@([update previous]), KEY_PREVIEW_OBJECT:previewObject}];
        }
        
        return;
    }
    
    if([update isKindOfClass:[TL_updateUserStatus class]]) {
        
        if(update.user_id == [UsersManager currentUserId]) {
            [[Telegram sharedInstance] setIsOnline:NO];
            [[Telegram sharedInstance] setAccountOnline];
        
            return;
        }
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
        TGUser *user = [[UsersManager sharedManager] find:777000];
        if(!conversation) {
            conversation = [[DialogsManager sharedManager] createDialogForUser:user];
            [conversation save];
        }
        
         NSString *displayDate = [[NSString alloc] initWithFormat:@"%@, %@ at %@", [TGDateUtils stringForDayOfWeek:update.date], [TGDateUtils stringForDialogTime:update.date], [TGDateUtils stringForShortTime:update.date]];
        
        NSString *messageText = [[NSString alloc] initWithFormat:NSLocalizedString(@"Notification.NewAuthDetected",nil), [UsersManager currentUser].first_name, displayDate, update.device, update.location];;
        
        TL_localMessage *msg = [TL_localMessage createWithN_id:0 from_id:777000 to_id:[TL_peerUser createWithUser_id:[UsersManager currentUserId]] n_out:NO unread:YES date:[[MTNetwork instance] getTime] message:messageText media:[TL_messageMediaEmpty create] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() state:DeliveryStateNormal];
        
        [MessagesManager addAndUpdateMessage:msg];
        
        return;
    }
    
    if([update isKindOfClass:[TL_updateContactRegistered class]]) {
        
        TGUser *user = [[UsersManager sharedManager] find:[update user_id]];
        
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Notification.UserRegistred", nil),user.fullName];
        
        TL_localMessageService *message = [TL_localMessageService createWithN_id:0 from_id:[update user_id] to_id:[TL_peerUser createWithUser_id:[update user_id]] n_out:YES unread:NO date:[update date] action:[TL_messageActionEncryptedChat createWithTitle:text] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
        
        [MessagesManager addAndUpdateMessage:message];

        return;
    }
    
}

-(void)cancelSequenceTimer {
    if(_sequenceTimer) {
        
        [_sequenceTimer invalidate];
        _sequenceTimer = nil;
        
    }
}

-(void)updateDifference {
    [self updateDifference:NO];
}

-(void)updateDifference:(BOOL)force {
    
   if(_holdUpdates || ![[MTNetwork instance] isAuth] ) return;
   
    _holdUpdates = YES;
    
    if( !_updateState || force) {
        
        [RPCRequest sendRequest:[TLAPI_updates_getState create] successHandler:^(RPCRequest *request, TL_updates_state * state) {
    
            _updateState = [[TGUpdateState alloc] initWithPts:_updateState.pts == 0 ? state.pts : _updateState.pts qts:_updateState.qts == 0 ? state.qts : _updateState.qts date:_updateState.date == 0 ? state.date : _updateState.date seq:_updateState.seq == 0 ? state.seq : _updateState.seq];

            [self saveUpdateState];
            
            MessagesManager *manager = [MessagesManager sharedManager];
            
            manager.unread_count = state.unread_count;
            
            _holdUpdates = NO;
            
            [self uptodate:_updateState.pts qts:_updateState.qts date:_updateState.date];
            
        } errorHandler:nil];
    } else {
        _holdUpdates = NO;
        [self uptodate:_updateState.pts qts:_updateState.qts date:_updateState.date];
    }
}





-(void)uptodate:(int)pts qts:(int)qts date:(int)date {
    
    if(_holdUpdates || ![[MTNetwork instance] isAuth] ) return;
    
    _holdUpdates = YES;
    
    [[Telegram rightViewController].messagesViewController.connectionController setState:ConnectingStatusTypeUpdating];
    
    TLAPI_updates_getDifference *dif = [TLAPI_updates_getDifference createWithPts:pts date:date qts:qts];
    [[NSApp delegate] setConnectionStatus:NSLocalizedString(@"App.updating", nil)];
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
        
        
        TGupdates_State * intstate;
        if([response isKindOfClass:[TL_updates_differenceSlice class]]) {
            intstate = [response intermediate_state];
            
            stateQts = [intstate qts];
            statePts = [intstate pts];
            stateDate = [intstate date];
            stateSeq = [intstate seq];
        }
        
        
        for (TL_encryptedMessage *enmsg in [updates n_encrypted_messages]) {
            TGMessage *msg = [MessagesManager defaultMessage:enmsg];
            if(msg) [[updates n_messages] addObject:msg];
        }
        
        NSMutableArray *copy = [[response n_messages] mutableCopy];
       
        
        
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        NSMutableArray *randomIds = [[NSMutableArray alloc] init];
        
        
        [copy enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            if([obj isKindOfClass:[TL_destructMessage class]]) {
                [randomIds addObject:@(obj.randomId)];
            } else {
                [ids addObject:@(obj.n_id)];
            }
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
        
        
        if(randomIds.count > 0) {
            [[Storage manager] messages:^(NSArray *res) {
                if(res.count > 0) {
                    [randomIds removeAllObjects];
                    
                    [res enumerateObjectsUsingBlock:^(TL_destructMessage *obj, NSUInteger idx, BOOL *stop) {
                        [randomIds addObject:@(obj.randomId)];
                    }];
                    
                    NSArray *f = [copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.randomId IN %@",randomIds]];
                    
                    [copy removeObjectsInArray:f];
                }
            } forIds:randomIds random:YES sync:YES];
        }
        
        
        [response setN_messages:copy];
        
        [SharedManager proccessGlobalResponse:updates];
        
        
        for (TGUpdate *update in [updates other_updates]) {
            [self proccessUpdate:update];
        }
        
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
            [self uptodate:statePts qts:stateQts date:stateDate];
        } else {
            [[NSApp delegate] setConnectionStatus:nil];
            [Notification perform:PROTOCOL_UPDATED data:nil];
            [[Telegram rightViewController].messagesViewController.connectionController setState:ConnectingStatusTypeNormal];
        }
       
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        _holdUpdates = NO;
        if(error.error_code == 502) {
            [self uptodate:pts qts:qts date:date];
        } else {
            [[NSApp delegate] setConnectionStatus:@"updating failed"];
            [self updateDifference:YES];
        }
    } timeout:10 queue:[ASQueue globalQueue].nativeQueue];

}


-(void)saveUpdateState {
    [[Storage manager] saveUpdateState:_updateState];
}


@end
