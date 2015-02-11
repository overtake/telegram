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
    
    [self.queue dispatchOnQueue:^{
        FullChatMembersChecker *checker = [self.membersCheker objectForKey:@(chat_id)];
        if(checker) {
            [checker reloadParticipants];
        }
    }];
    
   
}

- (FullChatMembersChecker *)fullChatMembersCheckerByChatId:(int)chatId {
    
    __block id object;
    
    [self.queue dispatchOnQueue:^{
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
    [self.queue dispatchOnQueue:^{
        NSArray *array =[[ChatsManager sharedManager] all];
        NSMutableArray *needToLoad = [[NSMutableArray alloc] init];
        for(TLChat *chat in array) {
            if([chat isKindOfClass:[TL_chat class]]) {
                if(![self find:chat.n_id]) {
                    [needToLoad addObject:@(chat.n_id)];
                }
            }
        }
        
        NSLog(@"need to load full chats%@", needToLoad);
        [self loadFullChats:needToLoad];
    }];
}

- (void)loadFullChats:(NSArray *)array {
    for(NSNumber *number in array) {
        int chat_id = [number intValue];
        [self loadFullChatByChatId:chat_id];
    }
}

- (void) loadIfNeed:(int)chat_id {
    if(!self.isLoad)
        return;
    
    TLChatFull *chat = [self find:chat_id];
    if(!chat || chat.lastUpdateTime + 300 < [[MTNetwork instance] getTime])
        [self loadFullChatByChatId:chat_id];
}

- (void)performLoad:(int)chat_id callback:(dispatch_block_t)callback {
    [self loadFullChatByChatId:chat_id callback:callback];
}

- (void)loadFullChatByChatId:(int)chat_id callback:(dispatch_block_t)callback {
    
        
    [RPCRequest sendRequest:[TLAPI_messages_getFullChat createWithChat_id:chat_id] successHandler:^(RPCRequest *request, id result) {
        
        [SharedManager proccessGlobalResponse:result];
        
        [self.queue dispatchOnQueue:^{
            
            [self add:[[NSArray alloc] initWithObjects:[result full_chat], nil]];
            
            [[Storage manager] insertFullChat:[result full_chat] completeHandler:nil];
            
            
            [LoopingUtils runOnMainQueueAsync:^{
                if(callback)
                    callback();
            }];
        }];
        
       
        
       
       
        
        NSLog(@"fullchat loaded");
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        ELog(@"fullchat loading error %@", error.error_msg);
        if(callback)
            callback();
    }];
    
}

- (void)loadFullChatByChatId:(int)chat_id {
    [self loadFullChatByChatId:chat_id callback:nil];
}

- (int)getOnlineCount:(int)chat_id {
    
    __block int count;
    
    [self.queue dispatchOnQueue:^{
        
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
                
                
                //            if(currentChat.notify_settings.mute_until != newChatFull.notify_settings.mute_until) {
                //                currentChat.notify_settings = newChatFull.notify_settings;
                //
                //                [[PushNotificationsManager sharedManager] set:currentChat.notify_settings.mute_until forPeer:-currentChat.n_id save:YES];
                //            }
                
            } else {
                [self->keys setObject:newChatFull forKey:@(newChatFull.n_id)];
                currentChat = newChatFull;
                
                //            [[PushNotificationsManager sharedManager] set:currentChat.notify_settings.mute_until forPeer:-currentChat.n_id save:NO];
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
