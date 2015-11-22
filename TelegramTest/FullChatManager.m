//
//  FullChatManager.m
//  TelegramTest
//
//  Created by keepcoder on 04.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "FullChatManager.h"
#import "TL.h"

@interface FullChatMembersChecker()

@property (nonatomic) int oldOnlineCount;
@property (nonatomic) int onlineCount;
@property (nonatomic) NSUInteger allCount;
@property (nonatomic) int chat_id;
@property (nonatomic) BOOL isFirstCall;
@property (nonatomic,strong) ASQueue *queue;


@property (nonatomic, strong) NSMutableArray *uids;
@property (nonatomic, strong) TLChatFull *chatFull;

@end

@implementation FullChatMembersChecker

- (id) initWithFullChat:(TLChatFull *)chatFull queue:(ASQueue *)queue {
    self = [super init];
    if(self) {
        self.queue = queue;
        self.chat_id = chatFull.n_id;
        self.uids = [[NSMutableArray alloc] init];
        self.chatFull = chatFull;
        
        [Notification addObserver:self selector:@selector(changeOnline:) name:USER_STATUS];
//        [Notification addObserver:self selector:@selector(chatUpdate:) name:UPDATE_CHAT];
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
    if(!self.isFirstCall) {
        self.isFirstCall = YES;
        return;
    }
    
    [Notification perform:CHAT_STATUS data:@{KEY_CHAT_ID: @(self.chat_id), @"online": @(self.onlineCount), @"all": @(self.allCount)}];
}



- (void) dealloc {
    [Notification removeObserver:self];
}

@end

@interface FullChatManager()
@property (nonatomic, strong) NSMutableDictionary *membersCheker;
@end

@implementation FullChatManager

- (id)initWithQueue:(ASQueue *)queue {
    self = [super initWithQueue:queue];
    if(self) {
        self.membersCheker = [[NSMutableDictionary alloc] init];
        [Notification addObserver:self selector:@selector(updateParticipantsNotification:) name:CHAT_UPDATE_PARTICIPANTS];
    }
    return self;
}

+ (id)sharedManager {
    static FullChatManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FullChatManager alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}

- (void)updateParticipantsNotification:(NSNotification *)notify {
    int chat_id = [[notify.userInfo objectForKey:KEY_CHAT_ID] intValue];
    
    FullChatMembersChecker *checker = [self.membersCheker objectForKey:@(chat_id)];
    if(checker) {
        [checker reloadParticipants];
    }
    
   
}

- (FullChatMembersChecker *)fullChatMembersCheckerByChatId:(int)chatId {
    
    __block id object;
    
    [ASQueue dispatchOnMainQueue:^{
        object = [self.membersCheker objectForKey:@(chatId)];
    } synchronous:YES];
    
    return object;
}


- (void)loadStored {
    [[Storage manager] fullChats:^(NSArray *chats) {
        [self add:chats];
        self.isLoad = YES;
        if(self.loadHandler)
            self.loadHandler();
    }];
}


- (void) loadIfNeed:(int)chat_id force:(BOOL)force {
    if(!self.isLoad)
        return;
    
    TLChatFull *chat = [self find:chat_id];
    if(!chat || (chat.lastUpdateTime + 300 < [[MTNetwork instance] getTime]) || force || chat.class == [TL_chatFull_old29 class])
        [self loadFullChatByChatId:chat_id force:force];
}

- (void)performLoad:(int)chat_id callback:(void (^)(TLChatFull *fullChat))callback {
    [self loadFullChatByChatId:chat_id force:NO callback:callback];
}

- (void)performLoad:(int)chat_id force:(BOOL)force callback:(void (^)(TLChatFull *fullChat))callback {
    [self loadFullChatByChatId:chat_id force:force callback:callback];
}

- (void)loadFullChatByChatId:(int)chat_id force:(BOOL)force callback:(void (^)(TLChatFull *fullChat))callback {
    
    TLChatFull *fullChat = [self find:chat_id];
    
    if(fullChat ) {
        if(callback != nil && !force)
            callback(fullChat);
        if( (fullChat.lastUpdateTime + 300 > [[MTNetwork instance] getTime]) && !force) {
                return;
        }
        
    }
    
    
    TLChat *chat = [[ChatsManager sharedManager] find:chat_id];
    
    if([chat isKindOfClass:[TL_channelForbidden class]] || [chat isKindOfClass:[TL_chatForbidden class]])
        return;
    
    id request;
    
    if([chat isKindOfClass:[TL_channel class]]) {
        request = [TLAPI_channels_getFullChannel createWithChannel:chat.inputPeer];
    } else {
        request = [TLAPI_messages_getFullChat createWithChat_id:chat.n_id];
    }
    
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_chatFull *result) {
        
         [SharedManager proccessGlobalResponse:result];
        
        if([result isKindOfClass:[TL_messages_chatFull class]]) {
            TL_conversation *conversation = [[DialogsManager sharedManager] findByChatId:chat_id];
            
            conversation.notify_settings = result.full_chat.notify_settings;
            
            [conversation save];
        }
        
        if(![result full_chat]) {
            [ASQueue dispatchOnMainQueue:^{
                if(callback)
                    callback([result full_chat]);
            }];
            
            return;
        }
        
        
       
        [self add:@[[result full_chat]]];
        
        TLChatFull *current = [self find:chat_id];
        
        
        
        [current setLastLayerUpdated:YES];
        
        [[Storage manager] insertFullChat:[result full_chat] completeHandler:nil];
        
        
        [ASQueue dispatchOnMainQueue:^{
            if(callback)
                callback([result full_chat]);
        }];

    } errorHandler:^(RPCRequest *request, RpcError *error) {
        ELog(@"fullchat loading error %@", error.error_msg);
        [ASQueue dispatchOnMainQueue:^{
            if(callback)
                callback(fullChat);
        }];
    } timeout:0 queue:self.queue.nativeQueue];
    
}

- (void)loadFullChatByChatId:(int)chat_id force:(BOOL)force {
    [self loadFullChatByChatId:chat_id force:force callback:nil];
}

- (int)getOnlineCount:(int)chat_id {
    
    __block int count;
    
    [ASQueue dispatchOnMainQueue:^{
        
        FullChatMembersChecker *checker = [self.membersCheker objectForKey:@(chat_id)];
        if(!checker) {
            TLChatFull *chatFull = [[FullChatManager sharedManager] find:chat_id];
            if(chatFull && ![chatFull isKindOfClass:[TL_channelFull class]]) {
                checker = [[FullChatMembersChecker alloc] initWithFullChat:chatFull queue:self.queue];
                [self.membersCheker setObject:checker forKey:@(chat_id)];
            }
        }
        
        count = checker ? checker.onlineCount : -1;
        
    } synchronous:YES];
    
    
    return count;
}

- (void) add:(NSArray *)all {
    
    [self.queue dispatchOnQueue:^{
        for (TLChatFull *newChatFull in all) {
            
            TLChatFull *currentChat = [self->keys objectForKey:@(newChatFull.n_id)];
            if(currentChat) {
                if([currentChat isKindOfClass:[TL_chatFull class]] && currentChat.participants.participants.count != newChatFull.participants.participants.count) {
                    currentChat.participants = newChatFull.participants;
                    [Notification perform:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT_ID: @(currentChat.n_id), KEY_PARTICIPANTS: currentChat.participants}];
                }
                currentChat.chat_photo = newChatFull.chat_photo;
                currentChat.lastUpdateTime = [[MTNetwork instance] getTime];
                currentChat.exported_invite = newChatFull.exported_invite;
                currentChat.bot_info = newChatFull.bot_info;
                currentChat.migrated_from_chat_id = newChatFull.migrated_from_chat_id;
                currentChat.migrated_from_max_id = newChatFull.migrated_from_max_id;

                if([currentChat isKindOfClass:[TL_channelFull class]] && (currentChat.participants_count != newChatFull.participants_count || currentChat.admins_count != newChatFull.admins_count || currentChat.kicked_count != newChatFull.kicked_count)) {
                    
                    currentChat.participants_count = newChatFull.participants_count;
                    currentChat.kicked_count = newChatFull.kicked_count;
                    currentChat.admins_count = newChatFull.admins_count;
                    
                    [Notification perform:CHAT_STATUS data:@{KEY_CHAT_ID: @(currentChat.n_id)}];
                    
                    if(currentChat.chat)
                        [Notification perform:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT:currentChat.chat}];
                }
                
                
            } else {
                [self->keys setObject:newChatFull forKey:@(newChatFull.n_id)];
                [self->list addObject:newChatFull];
                
                
                currentChat = newChatFull;
                
                if([currentChat isKindOfClass:[TL_channelFull class]]) {
                    [Notification perform:CHAT_STATUS data:@{KEY_CHAT_ID: @(currentChat.n_id)}];
                    
                    if(currentChat.chat)
                        [Notification perform:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT:currentChat.chat}];
                }
                
                if(currentChat.lastUpdateTime == 0)
                    currentChat.lastUpdateTime = [[MTNetwork instance] getTime];
            }
            
            if([currentChat isKindOfClass:[TL_chatFull class]]) {
                NSArray *copy = [currentChat.participants.participants copy];
                
                for (TL_chatParticipant *user in copy) {
                    TLUser *find = [[UsersManager sharedManager] find:user.user_id];
                    
                    if([find isKindOfClass:[TL_userEmpty class]] || !find) {
                        [currentChat.participants.participants removeObject:user];
                    }
                }
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
                
                
            } errorHandler:^(id request, RpcError *error) {
                
            }];
        }
    }
    
    
}

@end
