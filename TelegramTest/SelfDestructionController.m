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
#import "TGMessage+Extensions.h"
#import "TGDialog+Extensions.h"
#import "TGPeer+Extensions.h"
@interface SelfDestructionController ()
{
   
}

@property (nonatomic,strong) NSMutableDictionary *destructors;
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
        self.destructors = [[NSMutableDictionary alloc] init];
        [[Storage manager] selfDestructors:^(NSArray *destructors) {
            
            [ASQueue dispatchOnStageQueue:^{
                for (Destructor *destructor in destructors) {
                    NSMutableArray *group = [self.destructors objectForKey:@(destructor.chat_id)];
                    if(!group) {
                        group = [[NSMutableArray alloc] init];
                        [self.destructors setObject:group forKey:@(destructor.chat_id)];
                    }
                    [group addObject:destructor];
                }

            }];
            
        }];
        self.ticker = [[TGTimer alloc] initWithTimeout:1.0 repeat:YES completion:^{
            [self updateDestructors];
        } queue:[ASQueue globalQueue].nativeQueue];
        
        [self.ticker start];
        [Notification addObserver:self selector:@selector(destructSelfMessages:) name:MESSAGE_READ_EVENT];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecomeNotification:) name:NSWindowDidBecomeKeyNotification object:[[NSApp delegate] window]];
    }
    return self;
}

- (void)windowBecomeNotification:(NSNotification *)notification {
    if([[[NSApp delegate] window] isKeyWindow]) {
        [ASQueue dispatchOnStageQueue:^{
            for (TL_destructMessage *msg in _keyWindowWaiting) {
                [self addMessage:msg];
            }
            [_keyWindowWaiting removeAllObjects];
        }];
    }
}

-(void)updateDestructors {
    
    [ASQueue dispatchOnStageQueue:^{
        NSArray *copy = [self.targets copy];
        NSMutableArray *todelete = [[NSMutableArray alloc] init];
        for (TL_destructMessage *msg in copy) {
            if(msg.destruction_time != 0 && msg.destruction_time < [[NSDate date] timeIntervalSince1970]) {
                [self.targets removeObject:msg];
                [todelete addObject:@(msg.n_id)];
            }
        }
        if(todelete.count) {
            [[Storage manager] deleteMessages:todelete completeHandler:nil];
            [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_MESSAGE_ID_LIST:todelete}];
        }
    }];
}

-(void)addDestructor:(Destructor *)destructor {
    
    [ASQueue dispatchOnStageQueue:^{
        NSMutableArray *current = [self.destructors objectForKey:@(destructor.chat_id)];
        if(!current) {
            current = [[NSMutableArray alloc] init];
            [self.destructors setObject:current forKey:@(destructor.chat_id)];
        }
        [current insertObject:destructor atIndex:0];
        [[Storage manager] insertDestructor:destructor];

    }];
    
}

-(void)dealloc {
    [Notification removeObserver:self];
}


-(void)destructSelfMessages:(NSNotification *)notification {
    
    [ASQueue dispatchOnStageQueue:^{
        NSArray *ids = [notification.userInfo objectForKey:KEY_MESSAGE_ID_LIST];
        NSMutableArray *tosave = [[NSMutableArray alloc] init];
        for (NSNumber *msg_id in ids) {
            int n_id = [msg_id intValue];
            if(n_id > TGMINSECRETID) {
                TL_destructMessage *message = [(MessagesManager *)[MessagesManager sharedManager] find:n_id];
                Destructor *destructor = [self destructor:message];
                if(destructor.ttl > 0) {
                    message.destruction_time = [[NSDate date] timeIntervalSince1970]+destructor.ttl;
                    [tosave addObject:message];
                    [self.targets addObject:message];
                }
            }
        }
        
        if(tosave.count)
            [[Storage manager] insertMessages:tosave  completeHandler:nil];
    }];
    
}

-(Destructor *)destructor:(TGMessage *)message {
    
    
    TL_conversation *dialog = message.dialog;
    
    NSArray *search = [[self.destructors objectForKey:@(dialog.peer.peer_id)] copy];
    NSMutableArray *acceptDestructor = [[NSMutableArray alloc] init];
    for(Destructor *destructor in search) {
        if(message.n_id > destructor.max_id) {
            [acceptDestructor addObject:destructor];
            return destructor;
        }
    }
    
    
    return nil;
}


-(void)addMessage:(TL_destructMessage *)message {
    
    [ASQueue dispatchOnStageQueue:^{
        if(![message isKindOfClass:[TL_destructMessage class]] ||
           (message.from_id == UsersManager.currentUserId && message.unread))
            return;
        
        if(![[[NSApp delegate] window] isKeyWindow]) {
            [_keyWindowWaiting addObject:message];
            return;
        }
        
        if(message.destruction_time != 0) {
            [self.targets addObject:message];
            return;
        }
        
        Destructor *destructor = [self destructor:message];
        if(destructor.ttl > 0) {
            message.destruction_time = [[NSDate date] timeIntervalSince1970]+destructor.ttl;
            [self.targets addObject:message];
            [[Storage manager] insertMessage:message  completeHandler:nil];
        }
    }];
    
 

}


+(id)instance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


+(void)addDestructor:(Destructor *)destructor {
    [[self instance] addDestructor:destructor];
}

+(void)addMessage:(TL_destructMessage *)message {
    [[self instance] addMessage:message];
}

+(void)addMessages:(NSArray *)messages {
    [[self instance] addMessages:messages];
}


+(int)lastTTL:(TL_encryptedChat *)chat {
    
    __block Destructor *destructor;
    
    [ASQueue dispatchOnStageQueue:^{
        
        NSArray *group = [[[self instance] destructors] objectForKey:@(chat.n_id)];
        
        if(group.count > 0)
            destructor = group[0];
        
    } synchronous:YES];
    
    return destructor ? destructor.ttl : -1;
}

+(void)initialize {
    [super initialize];
    [self instance];
}


-(void)addMessages:(NSArray *)messages {
    for (TL_destructMessage * msg in messages) {
        [self addMessage:msg];
    }
}

@end
