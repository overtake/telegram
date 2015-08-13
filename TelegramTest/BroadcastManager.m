//
//  BroadcastManager.m
//  Telegram
//
//  Created by keepcoder on 06.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BroadcastManager.h"



@interface BroadcastMemberChecker ()
@property (nonatomic) int oldOnlineCount;
@property (nonatomic) int onlineCount;
@property (nonatomic) NSUInteger allCount;
@property (nonatomic) BOOL isFirstCall;


@property (nonatomic, strong) NSMutableArray *uids;
@property (nonatomic, strong) TL_broadcast *broadcast;
@property (nonatomic,strong) ASQueue *queue;
@end

@implementation BroadcastMemberChecker

- (id) initWithBroadcast:(TL_broadcast *)broadcast queue:(ASQueue *)queue {
    self = [super init];
    if(self) {
        self.queue = queue;
        self.broadcast = broadcast;

        
        [Notification addObserver:self selector:@selector(changeOnline:) name:USER_STATUS];
        //        [Notification addObserver:self selector:@selector(chatUpdate:) name:UPDATE_CHAT];
        [self reloadParticipants];
    }
    return self;
}

- (void) reloadParticipants {
    
    [self.queue dispatchOnQueue:^{
        [self.uids removeAllObjects];
        for(NSNumber *participant in self.broadcast.participants) {
            int user_id = [participant intValue];
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
        self.allCount = self.broadcast.participants.count;
        
        for(NSNumber *participant in self.broadcast.participants) {
            int user_id = [participant intValue];
            
            
            if(((TLUser *)[[UsersManager sharedManager] find:user_id]).isOnline)
                self.onlineCount++;
        }
        
        self.oldOnlineCount = self.onlineCount;
        
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
    
    [Notification perform:BROADCAST_STATUS data:@{KEY_CHAT_ID: @(self.broadcast.n_id), @"online": @(self.onlineCount), @"all": @(self.allCount)}];
}



- (void) dealloc {
    [Notification removeObserver:self];
}

@end


@interface BroadcastManager ()
@property (nonatomic,strong) NSMutableDictionary *membersChecker;
@end

@implementation BroadcastManager


-(id)initWithQueue:(ASQueue *)queue {
    if(self = [super initWithQueue:queue]) {
        self.membersChecker = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


-(void)save:(id)object {
    // [[Storage manager] insertBroadcast:object];
}

- (int)getOnlineCount:(int)broadcast_id {
    
    __block int count;
    
    [self.queue dispatchOnQueue:^{
        
        BroadcastMemberChecker *checker = [self.membersChecker objectForKey:@(broadcast_id)];
        if(!checker) {
            TL_broadcast *broadcast = [self find:broadcast_id];
            if(broadcast) {
                checker = [[BroadcastMemberChecker alloc] initWithBroadcast:broadcast queue:self.queue];
                [self.membersChecker setObject:checker forKey:@(broadcast_id)];
            }
        }
        
       
        
        count = checker ? checker.onlineCount : -1;
        
    } synchronous:YES];
    
    
    return count;
}

- (BroadcastMemberChecker *)broadcastMembersCheckerById:(int)broadcastId {
    
    __block id object;
    
    [self.queue dispatchOnQueue:^{
        object = [self.membersChecker objectForKey:@(broadcastId)];
    } synchronous:YES];
    
    return object;
}


+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}

@end
