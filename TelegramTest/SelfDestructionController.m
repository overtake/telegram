//
//  SelfDestructionController.m
//  Messenger for Telegram
//
//  Created by keepcoder on 24.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SelfDestructionController.h"
#import "Destructor.h"
#import "SpacemanBlocks.h"
#import "TGTimer.h"
#import "TLPeer+Extensions.h"
#import "SenderHeader.h"
@interface SelfDestructionController ()
{
   
}

@property (nonatomic,strong) TGTimer *ticker;
@property (nonatomic,strong) NSMutableArray *targets;
@property (nonatomic,strong) NSMutableArray *keyWindowWaiting;
@property (nonatomic,strong) NSMutableArray *readWaiting;
@end

@implementation SelfDestructionController

@synthesize keyWindowWaiting = _keyWindowWaiting;
-(id)init {
    if(self = [super init]) {
        _keyWindowWaiting = [[NSMutableArray alloc] init];
        _readWaiting = [[NSMutableArray alloc] init];
        self.targets = [[NSMutableArray alloc] init];
      
        self.ticker = [[TGTimer alloc] initWithTimeout:1.0 repeat:YES completion:^{
            [self loopAndCheckMessages];
        } queue:[ASQueue globalQueue].nativeQueue];
        
        [self.ticker start];
        [Notification addObserver:self selector:@selector(didReadMessages:) name:MESSAGE_READ_EVENT];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecomeNotification:) name:NSWindowDidBecomeKeyNotification object:[NSApp mainWindow]];
    }
    return self;
}

- (void)windowBecomeNotification:(NSNotification *)notification {
    if([[NSApp mainWindow] isKeyWindow]) {
        [ASQueue dispatchOnStageQueue:^{
            for (TL_destructMessage *msg in _keyWindowWaiting) {
                [self addMessage:msg force:NO];
            }
            [_keyWindowWaiting removeAllObjects];
        }];
    }
}


-(void)loopAndCheckMessages {
    
    NSArray *copy = [self.targets copy];
    NSMutableArray *todelete = [[NSMutableArray alloc] init];
    
    
    NSMutableDictionary *remoteDelete = [[NSMutableDictionary alloc] init];
    
    
    for (TL_destructMessage *msg in copy) {
        if(msg.destruction_time != 0 && msg.destruction_time < [[NSDate date] timeIntervalSince1970]) {
            [self.targets removeObject:msg];
            [todelete addObject:@(msg.n_id)];
            
            if(msg.params.layer > 1 && [msg.media isKindOfClass:[TL_messageMediaPhoto class]]) {
                NSMutableArray *array = [remoteDelete objectForKey:@(msg.peer_id)];
                
                if(!array) {
                     array = [[NSMutableArray alloc] init];
                    [remoteDelete setObject:array forKey:@(msg.peer_id)];
                }
                
                [array addObject:@(msg.randomId)];
            }
            
        }
    }
    if(todelete.count) {
        
        [[DialogsManager sharedManager] deleteMessagesWithMessageIds:todelete];
        
        [remoteDelete enumerateKeysAndObjectsUsingBlock:^(NSNumber *chat_id, NSMutableArray *obj, BOOL *stop) {
            
            DeleteRandomMessagesSenderItem *sender = [[DeleteRandomMessagesSenderItem alloc] initWithConversation:[[DialogsManager sharedManager] find:[chat_id intValue]] random_ids:obj];
            
            [sender send];
            
        }];
        
        
    }
}


-(void)dealloc {
    [Notification removeObserver:self];
}


-(void)didReadMessages:(NSNotification *)notification {
    
    [ASQueue dispatchOnStageQueue:^{
        NSArray *ids = [notification.userInfo objectForKey:KEY_MESSAGE_ID_LIST];
        NSMutableArray *tosave = [[NSMutableArray alloc] init];
        for (NSNumber *msg_id in ids) {
            int n_id = [msg_id intValue];
            if(n_id > TGMINSECRETID) {
                TL_destructMessage *message = [(MessagesManager *)[MessagesManager sharedManager] find:n_id];
                
                if(![message isKindOfClass:[TL_destructMessage class]])
                    return;
                
                if([message isKindOfClass:[TL_destructMessage class]] && message.params.layer > 1 && [message.media isKindOfClass:[TL_messageMediaPhoto class]] && message.ttl_seconds <  60*60)
                    continue;
                
                if(message.ttl_seconds != 0) {
                    message.destruction_time = [[NSDate date] timeIntervalSince1970]+message.ttl_seconds;
                    [tosave addObject:message];
                    [self.targets addObject:message];
                }
            }
        }
        
        if(tosave.count)
            [[Storage manager] insertMessages:tosave];
    }];
    
}


-(void)addMessage:(TL_destructMessage *)message force:(BOOL)force {
    
    [ASQueue dispatchOnStageQueue:^{
        if(![message isKindOfClass:[TL_destructMessage class]] ||
           (message.from_id == UsersManager.currentUserId && message.unread))
            return;
        
        if(![[NSApp mainWindow] isKeyWindow] && !force) {
            [_keyWindowWaiting addObject:message];
            return;
        }
        
        if(message.destruction_time != 0) {
            [self.targets addObject:message];
            return;
        }
        
        if(!force && message.params.layer > 1 && [message.media isKindOfClass:[TL_messageMediaPhoto class]] && message.ttl_seconds < 60*60)
            return;
        
        
        if(message.ttl_seconds != 0) {
            message.destruction_time = [[NSDate date] timeIntervalSince1970]+message.ttl_seconds;
            [self.targets addObject:message];
            [message save:NO];
        }
    }];
    
 

}


+(SelfDestructionController *)instance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


+(void)addMessage:(TL_destructMessage *)message force:(BOOL)force {
    [[self instance] addMessage:message force:force];
}

+(void)addMessages:(NSArray *)messages {
    [[self instance] addMessages:messages];
}



+(void)initialize {
    [super initialize];
    [self instance];
}


-(void)addMessages:(NSArray *)messages {
    for (TL_destructMessage * msg in messages) {
        [self addMessage:msg force:NO];
    }
}

@end
