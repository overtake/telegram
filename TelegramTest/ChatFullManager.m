//
//  ChatFullManager.m
//  Telegram
//
//  Created by keepcoder on 22/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "ChatFullManager.h"
#import "TGMultipleRequestCallback.h"

@interface ChatFullMembersChecker : NSObject
@end

@interface ChatFullMembersChecker()

@property (nonatomic) int oldOnlineCount;
@property (nonatomic) int onlineCount;
@property (nonatomic) NSUInteger allCount;
@property (nonatomic) int chat_id;
@property (nonatomic) BOOL isFirstCall;
@property (nonatomic,strong) ASQueue *queue;


@property (nonatomic, strong) NSMutableArray *uids;
@property (nonatomic, strong) TLChatFull *chatFull;

@end

@implementation ChatFullMembersChecker

- (id) initWithFullChat:(TLChatFull *)chatFull queue:(ASQueue *)queue {
    self = [super init];
    if(self) {
        self.queue = queue;
        self.chat_id = chatFull.n_id;
        self.uids = [[NSMutableArray alloc] init];
        self.chatFull = chatFull;
        
        [Notification addObserver:self selector:@selector(changeOnline:) name:USER_STATUS];
        [self reloadParticipants];
    }
    return self;
}

- (void) reloadParticipants {
    
    [self.queue dispatchOnQueue:^{
        [self.uids removeAllObjects];
        for(TLChatParticipant *participant in self.chatFull.participants.participants) {
            int user_id = participant.user_id;
            [self.uids addObject:@(user_id)];
        }
        
        [self calcOnline];
    }];
    
}



- (void)calcOnline {
    [self.queue dispatchOnQueue:^{
        int oldOnline = self.oldOnlineCount;
        NSUInteger oldAllCount = self.allCount;
        
        self.onlineCount = 0;
        self.allCount = self.chatFull.participants.participants.count;
        
        for(TLChatParticipant *participant in self.chatFull.participants.participants) {
            int user_id = participant.user_id;
            
            
            if(((TLUser *)[[UsersManager sharedManager] find:user_id]).isOnline)
                self.onlineCount++;
        }
        
        if(oldOnline != self.onlineCount || self.allCount != oldAllCount)
            [self performNotification];
    }];
}

- (void) changeOnline:(NSNotification *)notification {
    int user_id = [[notification.userInfo objectForKey:KEY_USER_ID] intValue];
    
    [self.queue dispatchOnQueue:^{
        if([self.uids indexOfObject:@(user_id)] == NSNotFound)
            return;
        
        [self calcOnline];
    }];
    
}

- (void)performNotification {
    
    [Notification perform:CHAT_STATUS data:@{KEY_CHAT_ID: @(self.chat_id), @"online": @(self.onlineCount), @"all": @(self.allCount)}];
}



- (void) dealloc {
    [Notification removeObserver:self];
}

@end

@interface ChatFullManager ()
@property (nonatomic,strong) NSMutableDictionary *membersChecker;
@property (nonatomic,strong) NSMutableDictionary *requests;
@property (nonatomic,strong) NSMutableDictionary *lastTimeCalled;
@property (nonatomic,assign,getter=isLoaded) BOOL loaded;
@end


@implementation ChatFullManager


- (id)initWithQueue:(ASQueue *)queue {
    self = [super initWithQueue:queue];
    if(self) {
        _membersChecker = [[NSMutableDictionary alloc] init];
        _requests = [[NSMutableDictionary alloc] init];
        _lastTimeCalled = [[NSMutableDictionary alloc] init];
        [Notification addObserver:self selector:@selector(updateParticipantsNotification:) name:CHAT_UPDATE_PARTICIPANTS];
    }
    return self;
}

-(void)requestChatFull:(int)chat_id withCallback:(void (^) (TLChatFull *chatFull))callback {
    [self requestChatFull:chat_id force:NO withCallback:callback];
}
-(void)requestChatFull:(int)chat_id {
    [self requestChatFull:chat_id force:NO withCallback:nil];
}
-(void)requestChatFull:(int)chat_id force:(BOOL)force {
    [self requestChatFull:chat_id force:force withCallback:nil];
}

-(void)requestChatFull:(int)chat_id force:(BOOL)force withCallback:(void (^) (TLChatFull *chatFull))callback {
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    dispatch_block_t block = ^{
        
        TLChat *chat = [[ChatsManager sharedManager] find:chat_id];
        
        TLChatFull *chatFull = [self find:chat.n_id];
        
        int time = [_lastTimeCalled[@(chat.n_id)] intValue];
        
        if(time > [[MTNetwork instance] getTime]) {
            
            if(chatFull)
            {
                if(callback) {
                    dispatch_async(dqueue, ^{
                        callback(chatFull);
                    });
                    
                }
                if(!force)
                    return;
            }
            
        }
        
        if([chat isKindOfClass:[TL_channelForbidden class]] || [chat isKindOfClass:[TL_chatForbidden class]] || (chat.isChannel && chat.access_hash == 0))
            return;
        
        TGMultipleRequestCallback *multiRequest = _requests[@(chat.n_id)];
        
        if(!multiRequest) {
            
            
            id r = [TLAPI_messages_getFullChat createWithChat_id:chat.n_id];
            
            if(chat.isChannel)
                r = [TLAPI_channels_getFullChannel createWithChannel:chat.inputPeer];
            
            
            RPCRequest *q = [RPCRequest sendRequest:r successHandler:^(id request, TL_messages_chatFull *response) {
                
                [SharedManager proccessGlobalResponse:response];
                
                if([response isKindOfClass:[TL_messages_chatFull class]]) {
                    TL_conversation *conversation = chat.dialog;
                    
                    if(conversation && conversation.notify_settings.mute_until != response.full_chat.notify_settings.mute_until)  {
                        conversation.notify_settings = response.full_chat.notify_settings;
                        [conversation save];
                    }
                    
                    [self add:@[[response full_chat]]];
                    
                    [[Storage manager] insertFullChat:response.full_chat completeHandler:nil];
                    
                    TLChatFull *current = [self find:chat_id];
                    
                    [ASQueue dispatchOnMainQueue:^{
                        
                        ChatFullMembersChecker *checker = _membersChecker[@(chat_id)];
                        
                        if(!checker)
                        {
                            checker = [[ChatFullMembersChecker alloc] initWithFullChat:current queue:self.queue];
                            _membersChecker[@(chat_id)] = checker;
                        }
                        
                        [checker reloadParticipants];
                        
                        TGMultipleRequestCallback *multiRequest = _requests[@(chat.n_id)];
                        
                        [multiRequest.callbacks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            void (^callback) (TLChatFull *chatFull) = obj;
                            callback(current);
                        }];
                        
                        [_requests removeObjectForKey:@(chat.n_id)];
                        _lastTimeCalled[@(chat.n_id)] = @([[MTNetwork instance] getTime] + 60*5);
                    }];

                    
                }
                
            } errorHandler:^(id request, RpcError *error) {
                [ASQueue dispatchOnMainQueue:^{
                    TGMultipleRequestCallback *multiRequest = _requests[@(chat.n_id)];
                    
                    [multiRequest.callbacks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        void (^callback) (TLChatFull *chatFull) = obj;
                        callback(chatFull);
                    }];
                    
                    [_requests removeObjectForKey:@(chat.n_id)];
                }];
            } timeout:10 queue:self.queue.nativeQueue];
            
            multiRequest = [[TGMultipleRequestCallback alloc] initWithRequest:q];
            
            _requests[@(chat.n_id)] = multiRequest;
        }
        
        if(callback != nil) {
            [ASQueue dispatchOnMainQueue:^{
                [multiRequest.callbacks addObject:callback];
            }];
        }
        
    
    };
    
    
    if(self.isLoaded)
        [self.queue dispatchOnQueue:block];
    else
        [[Storage manager] fullChats:^(NSArray *chats) {
            
            [self add:chats];
            
            self.loaded = YES;
            
            [self.queue dispatchOnQueue:block];
        }];
}


- (void) add:(NSArray *)all {
    
    [self.queue dispatchOnQueue:^{
        for (TLChatFull *newChatFull in all) {
            
            TLChatFull *currentChat = [self->keys objectForKey:@(newChatFull.n_id)];
            if(currentChat) {
                if([currentChat isKindOfClass:[TL_chatFull class]] && currentChat.participants.participants.count != newChatFull.participants.participants.count) {
                    currentChat.participants = newChatFull.participants;
                    [Notification performOnStageQueue:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT_ID: @(currentChat.n_id), KEY_PARTICIPANTS: currentChat.participants}];
                }
                
                currentChat.flags = newChatFull.flags;
                currentChat.chat_photo = newChatFull.chat_photo;
                currentChat.lastUpdateTime = [[MTNetwork instance] getTime];
                currentChat.exported_invite = newChatFull.exported_invite;
                currentChat.bot_info = newChatFull.bot_info;
                currentChat.migrated_from_chat_id = newChatFull.migrated_from_chat_id;
                currentChat.migrated_from_max_id = newChatFull.migrated_from_max_id;
                
                
                if(currentChat.pinned_msg_id != newChatFull.pinned_msg_id) {
                    currentChat.pinned_msg_id = newChatFull.pinned_msg_id;
                    
                    [Notification perform:UPDATE_PINNED_MESSAGE data:@{KEY_PEER_ID:@(-[currentChat n_id]),KEY_MESSAGE_ID:@(currentChat.pinned_msg_id)}];
                }
                
                if([currentChat isKindOfClass:[TL_channelFull class]] && (currentChat.participants_count != newChatFull.participants_count || currentChat.admins_count != newChatFull.admins_count || currentChat.kicked_count != newChatFull.kicked_count)) {
                    
                    currentChat.participants_count = newChatFull.participants_count;
                    currentChat.kicked_count = newChatFull.kicked_count;
                    currentChat.admins_count = newChatFull.admins_count;
                    
                    [Notification perform:CHAT_STATUS data:@{KEY_CHAT_ID: @(currentChat.n_id)}];
                    
                    if(currentChat.chat)
                        [Notification performOnStageQueue:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT_ID: @(currentChat.n_id), KEY_PARTICIPANTS: currentChat.participants}];
                }
                
                
            } else {
                [self->keys setObject:newChatFull forKey:@(newChatFull.n_id)];
                [self->list addObject:newChatFull];
                
               currentChat = newChatFull;
                
                if(currentChat.chat) {
                    
                    if(currentChat.participants == nil)
                    {
                        currentChat.participants = [TL_chatParticipants createWithChat_id:currentChat.n_id participants:[NSMutableArray array] version:0];
                    }
                    
                    if(currentChat.chat.isMegagroup)
                        [self loadParticipantsWithMegagroupId:currentChat.n_id];
                    else
                        [Notification performOnStageQueue:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT_ID: @(currentChat.n_id), KEY_PARTICIPANTS: currentChat.participants}];
                
                }
                
                
                [Notification perform:CHAT_STATUS data:@{KEY_CHAT_ID: @(currentChat.n_id)}];
            }
            
            
            
            if([newChatFull.participants isKindOfClass:[TL_chatParticipantsForbidden class]]) {
                
            }
        }
        
    }];
    
}

-(void)loadParticipantsWithMegagroupId:(int)chat_id {
    
    
    
    TLChatFull *chatFull = [self find:chat_id];
    
    if(chatFull.chat.isMegagroup && chatFull.chat.type != TLChatTypeForbidden) {
        if(!chatFull.participants)
            chatFull.participants = [TL_chatParticipants createWithChat_id:chat_id participants:[NSMutableArray array] version:0];
        
        if(chatFull) {
            int offset = (int) chatFull.participants.participants.count;
            
            [RPCRequest sendRequest:[TLAPI_channels_getParticipants createWithChannel:chatFull.chat.inputPeer filter:[TL_channelParticipantsRecent create] offset:offset limit:500] successHandler:^(id request, TL_channels_channelParticipants *response) {
                
                [SharedManager proccessGlobalResponse:response];
                
                [chatFull.participants.participants addObjectsFromArray:response.participants];
                
                [Notification performOnStageQueue:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT_ID: @(chatFull.n_id), KEY_PARTICIPANTS: chatFull.participants}];
                
                
            } errorHandler:^(id request, RpcError *error) {
                
            } timeout:0 queue:self.queue.nativeQueue];
        }
    }
    
}

- (int)getOnlineCount:(int)chat_id {
    
    __block int count;
    

    ChatFullMembersChecker *checker = [_membersChecker objectForKey:@(chat_id)];
    if(!checker) {
        
        TLChatFull *chatFull = [self find:chat_id];
        
        if(chatFull) {
            checker = [[ChatFullMembersChecker alloc] initWithFullChat:chatFull queue:self.queue];
            [_membersChecker setObject:checker forKey:@(chatFull.n_id)];
        }
    }
    
    count = checker ? checker.onlineCount : -1;
    

    
    
    return count;
}


- (void)updateParticipantsNotification:(NSNotification *)notify {
    int chat_id = [[notify.userInfo objectForKey:KEY_CHAT_ID] intValue];
    
    [ASQueue dispatchOnMainQueue:^{
        ChatFullMembersChecker *checker = [_membersChecker objectForKey:@(chat_id)];
        if(checker) {
            [checker reloadParticipants];
        }
        
    }];
}

+ (id)sharedManager {
    static ChatFullManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ChatFullManager alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}


@end
