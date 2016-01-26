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
#import "FullUsersManager.h"
#import "TGUpdateChannels.h"
#import "TGForceChannelUpdate.h"
@interface TGProccessUpdates ()
@property (nonatomic,strong) TGUpdateState *updateState;
@property (nonatomic,strong) NSMutableArray *statefulUpdates;
@property (nonatomic,strong) TGTimer *sequenceTimer;
@property (atomic,assign) BOOL holdUpdates;
@property (nonatomic,strong) TGModernEncryptedUpdates *encryptedUpdates;
@property (nonatomic,strong) TGUpdateChannels *channelsUpdater;


@end

@implementation TGProccessUpdates

static NSString *kUpdateState = @"kUpdateState";

static ASQueue *queue;

@synthesize updateState = _updateState;
@synthesize statefulUpdates = _statefulUpdates;
@synthesize sequenceTimer = _sequenceTimer;
@synthesize holdUpdates = _holdUpdates;



static NSArray *channelUpdates;

-(id)initWithQueue:(ASQueue *)q {
    if(self = [self init]) {
        self.holdUpdates = NO;
        _statefulUpdates = [[NSMutableArray alloc] init];
        
        _updateState = [[Storage manager] updateState];
        
        if(_updateState.pts == 0) {
            _updateState = nil;
        }
        
       // _updateState = [[TGUpdateState alloc] initWithPts:1 qts:1 date:_updateState.date seq:1 pts_count:1];
        _encryptedUpdates = [[TGModernEncryptedUpdates alloc] init];
        _channelsUpdater = [[TGUpdateChannels alloc] initWithQueue:q];
        
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            
            channelUpdates = @[NSStringFromClass([TL_updateNewChannelMessage class]),NSStringFromClass([TL_updateReadChannelInbox class]),NSStringFromClass([TL_updateDeleteChannelMessages class]),NSStringFromClass([TGForceChannelUpdate class]),NSStringFromClass([TL_updateChannelTooLong class]),NSStringFromClass([TL_updateChannelGroup class]),NSStringFromClass([TL_updateChannelMessageViews class]),NSStringFromClass([TL_updateChannel class])];
        });
        
        queue = q;
        
        [_encryptedUpdates setQueue:queue];
    }
    return self;
}

- (void)resetStateAndSync {
    
    [queue dispatchOnQueue:^{
        _updateState = [[TGUpdateState alloc] initWithPts:989352 qts:1 date:_updateState.date seq:1 pts_count:1];
        
        [self saveUpdateState];
        
        [self uptodateWithConnectionState:YES];
    }];
}

-(void)failUpdateWithChannelId:(int)channel_id limit:(int)limit withCallback:(void (^)(id response, TGMessageHole *longHole))callback errorCallback:(void (^)(RpcError *error))errorCallback {
    [queue dispatchOnQueue:^{
        
        [_channelsUpdater failUpdateWithChannelId:channel_id limit:limit withCallback:callback errorCallback:errorCallback];
        
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

/*
 -(void)processUpdates:(NSArray *)updates stateSeq:(int)stateSeq {
 
 
 
 
 for(TLUpdate *update in updates) {
 
 [self addStatefullUpdate:update seq:stateSeq pts:[update pts] date:[update date] qts:[update qts] pts_count:[update pts_count]];
 }
 
 
 }
 */

-(void)processUpdates:(NSArray *)updates stateSeq:(int)stateSeq {
    
    for(TLUpdate *update in updates) {
        [self addStatefullUpdate:update seq:0 pts:[update pts] date:[update date] qts:[update qts] pts_count:[update pts_count]];
    }
    
}





-(void)addUpdate:(id)update {
    
    [queue dispatchOnQueue:^{
        
       
        
        
        if([channelUpdates indexOfObject:[update className]] != NSNotFound)
        {
            [_channelsUpdater addUpdate:update];
            
            return;
        } else if([update respondsToSelector:@selector(update)] && [channelUpdates indexOfObject:[[(TL_updateShort *)update update] className]] != NSNotFound) {
            [_channelsUpdater addUpdate:[(TL_updateShort *)update update]];
            
            [_updateState setDate:[(TL_updateShort *)update date]];
            [self saveUpdateState];
            return;
        }
        
        if([update isKindOfClass:[TL_updates class]]) {
            
            [SharedManager proccessGlobalResponse:update];
            
            [[update updates] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                if([obj isKindOfClass:[TL_updateMessageID class]]) {
                    [self proccessUpdate:obj];
                }
                
                if([channelUpdates indexOfObject:[obj className]] != NSNotFound)
                {
                    [_channelsUpdater addUpdate:obj];
                }
                
            }];
            
            [_updateState setDate:[(TL_updates *)update date]];
            [self saveUpdateState];
            
        }
        
        if([update isKindOfClass:[TL_messages_affectedMessages class]]) {
            
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
            
            NSArray *updates = [[[update updates] copy] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                
                return [channelUpdates indexOfObject:[evaluatedObject className]] == NSNotFound;
                
            }]];
            
            if(updates.count > 0)
                [self processUpdates:updates stateSeq:[update seq]];
        }
        
        
        if([update isKindOfClass:[TL_updateShortChatMessage class]]) {
            TL_updateShortChatMessage *shortMessage = update;
            
            [self addStatefullUpdate:update seq:[shortMessage seq] pts:[shortMessage pts] date:[shortMessage date] qts:0 pts_count:[shortMessage pts_count]];
            
        }
        
        if([update isKindOfClass:[TL_updateShortMessage class]] || [update isKindOfClass:[TL_updateShortSentMessage class]]) {
            TL_updateShortMessage *shortMessage = update;
            
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
    
   
    if(statefulMessage.pts > 0 && ((_updateState.pts + statefulMessage.pts_count == statefulMessage.pts) || _updateState.pts >= statefulMessage.pts) && !_holdUpdates) {
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
    
    if([statefulMessage isEmpty] && _updateState != nil) {
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
        
        
        
        TL_localMessage *message = [TL_localMessage createWithN_id:shortMessage.n_id flags:shortMessage.flags from_id:[shortMessage from_id] to_id:[TL_peerChat createWithChat_id:shortMessage.chat_id] fwd_from_id:shortMessage.fwd_from_id fwd_date:shortMessage.fwd_date reply_to_msg_id:shortMessage.reply_to_msg_id date:shortMessage.date message:shortMessage.message media:[TL_messageMediaEmpty create] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() reply_markup:nil entities:shortMessage.entities views:0 isViewed:YES state:DeliveryStateNormal];
        
        if(![[UsersManager sharedManager] find:shortMessage.from_id] || ![[ChatsManager sharedManager] find:shortMessage.chat_id] || (message.fwd_from_id != nil && !message.fwdObject)) {
            
            if(![[ChatsManager sharedManager] find:shortMessage.chat_id]) {
                [[FullChatManager sharedManager] loadIfNeed:shortMessage.chat_id force:YES];
            }
            
            [self failSequence];
            return NO;
        }
        
        [MessagesManager addAndUpdateMessage:message];
    }
    
    if([container.update isKindOfClass:[TL_updateShortMessage class]]) {
        TL_updateShortMessage *shortMessage = (TL_updateShortMessage *) container.update;
        
        TL_localMessage *message = [TL_localMessage createWithN_id:shortMessage.n_id flags:shortMessage.flags from_id:[shortMessage user_id] to_id:[TL_peerUser createWithUser_id:[shortMessage user_id]] fwd_from_id:shortMessage.fwd_from_id fwd_date:shortMessage.fwd_date reply_to_msg_id:shortMessage.reply_to_msg_id date:shortMessage.date message:shortMessage.message media:[TL_messageMediaEmpty create] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() reply_markup:nil entities:shortMessage.entities views:0 isViewed:YES state:DeliveryStateNormal];
        
        
        if(![[UsersManager sharedManager] find:shortMessage.user_id] || (message.fwd_from_id != nil && !message.fwdObject)) {
            [self failSequence];
            return NO;
        }
        
        if(message.n_out) {
            message.from_id = [UsersManager currentUserId];
        } else {
            message.to_id.user_id = [UsersManager currentUserId];
        }
        
        [MessagesManager addAndUpdateMessage:message];
        
    }
    
   [self proccessUpdate:container.update];
    
    if(needSave)
        [self applyUpdate:container];
    
    return YES;
    
}


-(void)updateShort:(TL_updateShort *)shortUpdate {
    
    _updateState.date = [shortUpdate date];
    [self saveUpdateState];
    
    [self proccessUpdate:shortUpdate.update];
}


-(void)proccessUpdate:(TLUpdate *)update {
    
    @try {
        if([update isKindOfClass:[TL_updateWebPage class]]) {
            
            TLWebPage *page = [update webpage];
            
            TLMessageMedia *media = [TL_messageMediaWebPage createWithWebpage:page];
            
            [[Storage manager] messagesWithWebpage:media callback:^(NSDictionary *peers) {
                
                [Notification perform:UPDATE_WEB_PAGES data:@{KEY_WEBPAGE:page}];
                
                [Notification perform:UPDATE_WEB_PAGE_ITEMS data:@{KEY_DATA:peers,KEY_WEBPAGE:page}];
            }];
            
            
            return;
        }
        
        
        if([update isKindOfClass:[TL_updateStickerSets class]]) {
        
            [Notification perform:STICKERS_ALL_CHANGED data:@{}];
            
            return;
        }
        
        if([update isKindOfClass:[TL_updateNewStickerSet class]]) {
            
            [Notification perform:STICKERS_NEW_PACK data:@{KEY_STICKERSET:update.stickerset}];
            
            return;
        }
        
        if([update isKindOfClass:[TL_updateStickerSetsOrder class]]) {
            
            [Notification perform:STICKERS_REORDER data:@{KEY_ORDER:update.order}];
            
            return;
        }
        
        
        
        if([update isKindOfClass:[TL_updateMessageID class]]) {
            
            [[Storage manager] updateMessageId:update.random_id msg_id:[update n_id]];
            
            [Notification performOnStageQueue:MESSAGE_UPDATE_MESSAGE_ID data:@{KEY_MESSAGE_ID:@(update.n_id),KEY_RANDOM_ID:@(update.random_id)}];
            
            return;
            
        }
        
        if([update isKindOfClass:[TL_updateNewMessage class]]) {
            
            if([[update message] isKindOfClass:[TL_messageEmpty class]])
                return;
            
            TL_localMessage *message = [TL_localMessage convertReceivedMessage:(TL_localMessage *)[update message]];
            
            if(message.reply_to_msg_id != 0 && message.replyMessage == nil) {
                [self failSequence];
                return;
            }
            
            
            
            return [MessagesManager addAndUpdateMessage:message];
        }
        
        
        if([update isKindOfClass:[TL_updateReadHistoryInbox class]]) {
            [[DialogsManager sharedManager] markAllMessagesAsRead:update.peer max_id:update.max_id out:NO];
            return;
        }
        
        if([update isKindOfClass:[TL_updateReadHistoryOutbox class]]) {
            [[DialogsManager sharedManager] markAllMessagesAsRead:update.peer max_id:update.max_id out:YES];
            return;
        }
        
        if([update isKindOfClass:[TL_updateReadMessagesContents class]]) {
            [[MessagesManager sharedManager] readMessagesContent:[[update messages] copy]];
        }
        
        if([update isKindOfClass:[TL_updateDeleteMessages class]]) {
            
            [[DialogsManager sharedManager] deleteMessagesWithMessageIds:[update messages]];
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
            
            TL_localMessage *msg = [TL_localMessage createWithN_id:0 flags:TGUNREADMESSAGE from_id:777000 to_id:[TL_peerUser createWithUser_id:[UsersManager currentUserId]] fwd_from_id:0 fwd_date:0 reply_to_msg_id:0  date:[[MTNetwork instance] getTime] message:(NSString *)updateNotification.message media:updateNotification.media fakeId:[MessageSender getFakeMessageId] randomId:rand_long() reply_markup:nil entities:nil views:0 isViewed:YES state:DeliveryStateNormal];
            
            [MessagesManager addAndUpdateMessage:msg];
            
            
            if(updateNotification.popup) {
                [[ASQueue mainQueue] dispatchOnQueue:^{
                    alert(NSLocalizedString(@"UpdateNotification.Alert", nil), (NSString *)updateNotification.message);
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
            
            [[FullChatManager sharedManager] performLoad:chatParticipants.chat_id force:YES callback:nil];
            
            if(fullChat) {
                fullChat.participants = chatParticipants;
                [[Storage manager] insertFullChat:fullChat completeHandler:nil];
                
                [Notification perform:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT_ID: @(fullChat.n_id), @"participants": fullChat.participants}];
            }
            
            return;
        }
        
        if([update isKindOfClass:[TL_updateContactLink class]]) {
            TL_updateContactLink *contactLink = (TL_updateContactLink *)update;
            
            BOOL isContact = [contactLink.my_link isKindOfClass:[TL_contactLinkContact class]];
            
            
            MTLog(@"%@ contact %d", isContact ? @"add" : @"delete", contactLink.user_id);
            
            
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
                    
                    if(chat.dialog) {
                        [Notification perform:[Notification notificationNameByDialog:chat.dialog action:@"message"] data:@{KEY_DIALOG:chat.dialog,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:chat.dialog]}];
                        
                        [MessagesManager notifyConversation:chat.dialog.peer.peer_id title:chat.peerUser.fullName text:NSLocalizedString(@"MessageService.Action.JoinedSecretChat", nil)];
                    }
                    
                    
                    
                }
                
                if([chat isKindOfClass:[TL_encryptedChatDiscarded class]]) {
                    
                    TL_encryptedChat *local = [[ChatsManager sharedManager] find:[chat n_id]];
                    if(!local)
                        return;
                    
                    
                    
                    EncryptedParams *params = [EncryptedParams findAndCreate:[chat n_id]];
                    [params setState:EncryptedDiscarted];
                    [params save];
                    
                    [Notification perform:[Notification notificationNameByDialog:local.dialog action:@"message"] data:@{KEY_DIALOG:chat.dialog,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:chat.dialog]}];
                    
                    
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
                [[DialogsManager sharedManager] markAllMessagesAsRead:dialog.peer max_id:INT32_MAX out:YES];
            }
            return;
        }
        
        if([update isKindOfClass:[TL_updateUserPhoto class]]) {
            TLUser *user = [[UsersManager sharedManager] find:update.user_id];
            
            if(user.photo.photo_id != [update photo].photo_id) {
                user.photo = [update photo];
                
                if(user) {
                    [[Storage manager] insertUser:user completeHandler:nil];
                    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:user.photo.photo_id media:[TL_photoSize createWithType:@"x" location:user.photo.photo_big w:640 h:640 size:0] peer_id:user.n_id];
                    [Notification perform:USER_UPDATE_PHOTO data:@{KEY_USER:user,KEY_PREVIOUS:@([update previous]), KEY_PREVIEW_OBJECT:previewObject}];
                }
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
        
        
        if([update isKindOfClass:[TL_updateChatParticipantAdmin class]]) {
            
            TLChatFull *chatFull = [[FullChatManager sharedManager] find:[update chat_id]];
            
            NSArray *f = [chatFull.participants.participants filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.user_id == %d",update.user_id]];
            
            if(f.count == 1)
            {
                TLChatParticipant *participant = [f firstObject];
                
                TLChatParticipant *newParticipant = [update is_admin] ? [TL_chatParticipantAdmin createWithUser_id:participant.user_id inviter_id:participant.inviter_id date:participant.date] : [TL_chatParticipant createWithUser_id:participant.user_id inviter_id:participant.inviter_id date:participant.date];
                
                [chatFull.participants.participants replaceObjectAtIndex:[chatFull.participants.participants indexOfObject:participant] withObject:newParticipant];
                
             }
            
            [Notification perform:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT_ID:@([update chat_id]),@"participants":chatFull.participants}];
            
        }
        
        if([update isKindOfClass:[TL_updateChatAdmins class]]) {
            
            TLChat *chat = [[ChatsManager sharedManager] find:[update chat_id]];
            
            if(chat.version != update.version) {
                [[FullChatManager sharedManager] loadIfNeed:[update chat_id] force:YES];
            }
            
            
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
            
            TL_localMessage *msg = [TL_localMessage createWithN_id:0 flags:TGUNREADMESSAGE from_id:777000 to_id:[TL_peerUser createWithUser_id:[UsersManager currentUserId]] fwd_from_id:0 fwd_date:0 reply_to_msg_id:0 date:[[MTNetwork instance] getTime] message:messageText media:[TL_messageMediaEmpty create] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() reply_markup:nil entities:nil views:0 isViewed:YES state:DeliveryStateNormal];
            
            [MessagesManager addAndUpdateMessage:msg];
            
            return;
        }
        
        if([update isKindOfClass:[TL_updateContactRegistered class]]) {
            
            TLUser *user = [[UsersManager sharedManager] find:[update user_id]];
            
            if(!user) {
                [self failSequence];
                return;
            }
            
            NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Notification.UserRegistred", nil),user.fullName];
            
            TL_localMessageService *message = [TL_localMessageService createWithFlags:0 n_id:0 from_id:[update user_id] to_id:[TL_peerUser createWithUser_id:[update user_id]] date:[update date] action:[TL_messageActionEncryptedChat createWithTitle:text] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
            
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
    @catch (NSException *exception) {
        
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
    
   if(![[MTNetwork instance] isAuth] ) return;
   
    _holdUpdates = YES;
    
    if( !_updateState || force) {
        
        [RPCRequest sendRequest:[TLAPI_updates_getState create] successHandler:^(RPCRequest *request, TL_updates_state * state) {
    
            _updateState = [[Storage manager] updateState];
            
            MTLog(@"update dif broken pts:%d, date:%d, qts:%d,seq:%d",_updateState.pts,_updateState.date,_updateState.qts,_updateState.seq);
            
            _updateState = [[TGUpdateState alloc] initWithPts:_updateState.pts == 0 ? state.pts : _updateState.pts qts:_updateState.qts == 0 ? state.qts : _updateState.qts date:_updateState.date == 0 ? state.date : _updateState.date seq:_updateState.seq == 0 ? state.seq : _updateState.seq pts_count:_updateState.pts_count];

            [self saveUpdateState];
            
            
            [MessagesManager updateUnreadBadge];
            
            _holdUpdates = NO;
            
            [self uptodateWithConnectionState:updateConnectionState];
            
        } errorHandler:^(id request, RpcError *error) {
            _holdUpdates = NO;
        } timeout:0 queue:queue.nativeQueue];
    } else {
        _holdUpdates = NO;
        [self uptodateWithConnectionState:updateConnectionState];
    }
}





-(void)uptodateWithConnectionState:(BOOL)updateConnectionState {
    
    if( ![[MTNetwork instance] isAuth] )
        return;
    
    _holdUpdates = YES;
    
    if(updateConnectionState)
        [Telegram setConnectionState:ConnectingStatusTypeUpdating];
    
    
    MTLog(@"updateDifference:%@, pts:%d,date:%d,qts:%d",_updateState,_updateState.pts,_updateState.date,_updateState.qts);
    
    TLAPI_updates_getDifference *dif = [TLAPI_updates_getDifference createWithPts:_updateState.pts date:_updateState.date qts:_updateState.qts];
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
        
        [TL_localMessage convertReceivedMessages:copy];
        
        
        
        [[response n_messages] removeAllObjects];
        
        [SharedManager proccessGlobalResponse:response];
       
        
        [[Storage manager] insertMessages:copy completeHandler:^{
            
            [response setN_messages:copy];
            
            for (TLUpdate *update in [updates other_updates]) {
                
                if([channelUpdates indexOfObject:update.className] != NSNotFound)
                    [self.channelsUpdater addUpdate:update];
                else
                    [self proccessUpdate:update];
            }
            
            if([response n_messages].count > 0) {
                [Notification performOnStageQueue:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:[response n_messages]}];
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
                dispatch_after_seconds_queue(0.5, ^{
                    [self uptodateWithConnectionState:updateConnectionState];
                }, queue.nativeQueue);
                
            } else {
                [Notification perform:PROTOCOL_UPDATED data:nil];
                [Telegram setConnectionState:ConnectingStatusTypeNormal];
            }

        }];
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        _holdUpdates = NO;
        
        if(error.error_code == 502) {
            [self uptodateWithConnectionState:updateConnectionState];
        } else if(error.error_code == 400) {
            [self updateDifference:YES updateConnectionState:updateConnectionState];
        }
    } timeout:0 queue:queue.nativeQueue];

}


-(void)saveUpdateState {
    [[Storage manager] saveUpdateState:_updateState];
}


@end
