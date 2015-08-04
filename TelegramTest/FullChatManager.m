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
    
    [self loadFullChatByChatId:chat_id force:YES];
    
   
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
        
        [self loadChatFull];
    }];
}

- (void)loadChatFull {
//    [self.queue dispatchOnQueue:^{
//        NSArray *array =[[ChatsManager sharedManager] all];
//        NSMutableArray *needToLoad = [[NSMutableArray alloc] init];
//        for(TLChat *chat in array) {
//            if([chat isKindOfClass:[TL_chat class]]) {
//                if(![self find:chat.n_id]) {
//                    [needToLoad addObject:@(chat.n_id)];
//                }
//            }
//        }
//        
//        MTLog(@"need to load full chats%@", needToLoad);
//        [self loadFullChats:needToLoad];
//    }];
}

- (void)loadFullChats:(NSArray *)array {
    for(NSNumber *number in array) {
        int chat_id = [number intValue];
        [self loadFullChatByChatId:chat_id force:NO];
    }
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
        if(callback != nil)
            callback(fullChat);
        if( (fullChat.lastUpdateTime + 300 > [[MTNetwork instance] getTime]) && !force) {
                return;
        }
        
    }
    
        
    [RPCRequest sendRequest:[TLAPI_messages_getFullChat createWithChat_id:chat_id] successHandler:^(RPCRequest *request, TL_messages_chatFull *result) {
        
        if([result isKindOfClass:[TL_messages_chatFull class]]) {
            TL_conversation *conversation = [[DialogsManager sharedManager] findByChatId:chat_id];
            
            conversation.notify_settings = result.full_chat.notify_settings;
            
            [conversation save];
        }
        
        [SharedManager proccessGlobalResponse:result];
        
        [self.queue dispatchOnQueue:^{
            
            [self add:@[[result full_chat]]];
            
            TLChatFull *current = [self find:chat_id];
            
            
            
            [current setLastLayerUpdated:YES];
            
            [[Storage manager] insertFullChat:[result full_chat] completeHandler:nil];
            
            
            [ASQueue dispatchOnMainQueue:^{
                if(callback)
                    callback([result full_chat]);
            }];

        }];

    } errorHandler:^(RPCRequest *request, RpcError *error) {
        ELog(@"fullchat loading error %@", error.error_msg);
        if(callback)
            callback(nil);
    }];
    
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
            if(chatFull) {
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
                if(currentChat.participants.participants.count != newChatFull.participants.participants.count) {
                    currentChat.participants = newChatFull.participants;
                    [Notification perform:CHAT_UPDATE_PARTICIPANTS data:@{KEY_CHAT_ID: @(currentChat.n_id), KEY_PARTICIPANTS: currentChat.participants}];
                }
                currentChat.chat_photo = newChatFull.chat_photo;
                currentChat.lastUpdateTime = [[MTNetwork instance] getTime];
                currentChat.exported_invite = newChatFull.exported_invite;
                currentChat.bot_info = newChatFull.bot_info;

            } else {
                [self->keys setObject:newChatFull forKey:@(newChatFull.n_id)];
                currentChat = newChatFull;
                if(currentChat.lastUpdateTime == 0)
                    currentChat.lastUpdateTime = [[MTNetwork instance] getTime];
            }
            
            NSArray *copy = [currentChat.participants.participants copy];
            
            for (TL_chatParticipant *user in copy) {
                TLUser *find = [[UsersManager sharedManager] find:user.user_id];
                
                if([find isKindOfClass:[TL_userEmpty class]] || !find) {
                    [currentChat.participants.participants removeObject:user];
                }
            }
            
            
            if([newChatFull.participants isKindOfClass:[TL_chatParticipantsForbidden class]]) {
                
            }
        }

    }];
    
}

@end
