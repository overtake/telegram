//
//  TGSendTypingManager.m
//  Telegram
//
//  Created by keepcoder on 03.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGSendTypingManager.h"
#import "TGTimer.h"
#import "TMTypingObject.h"
@interface TGSendingAction : NSObject
@property (nonatomic,strong,readonly) TLSendMessageAction *action;
@property (nonatomic,assign,readonly) NSUInteger time;
@property (nonatomic,strong,readonly) TL_conversation *conversation;
@property (nonatomic,strong,readonly) RPCRequest *request;

@property (nonatomic,assign,readonly) BOOL isExecuting;
@end

@implementation TGSendingAction

-(id)initWithAction:(TLSendMessageAction *)action time:(NSUInteger)time conversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        _action = action;
        _time = time;
        _conversation = conversation;
    }
    
    return self;
}

-(void)perform {
    
    id api;
    
    
    
    if(_conversation.type == DialogTypeSecretChat)
        api = [TLAPI_messages_setEncryptedTyping createWithPeer:(TLInputEncryptedChat *)[_conversation.encryptedChat inputPeer] typing:YES];
    else
        api = [TLAPI_messages_setTyping createWithPeer:[_conversation inputPeer] action:_action];
    
    
    _isExecuting = YES;
    
    
    
    dispatch_after_seconds_queue(3, ^{
        
        [self cancel];
        
    }, dispatch_get_current_queue());
    
    _request = [RPCRequest sendRequest:api successHandler:^(RPCRequest *request, id response) {
        
     } errorHandler:^(RPCRequest *request, RpcError *error) {
        
    }];
}

-(void)cancel {
    _isExecuting = NO;
    [_request cancelRequest];
    _request = nil;
}

-(void)dealloc {
    [self cancel];
}

-(NSComparisonResult)compare:(TGSendingAction *)anotherObject {
    return [_action compare:anotherObject.action];
}

@end


@interface TGSendTypingManager ()
@property (nonatomic,strong) NSMutableDictionary *conversations;
@property (nonatomic,strong) TGTimer *timer;
@end

@implementation TGSendTypingManager


-(id)init {
    if(self = [super init]) {
        _conversations = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


+(void)addAction:(TLSendMessageAction *)action forConversation:(TL_conversation *)conversation {
    [ASQueue dispatchOnStageQueue:^{
        [[self manager] addAction:action forConversation:conversation];
    }];
}

+(void)clear:(TL_conversation *)conversation {
    [ASQueue dispatchOnStageQueue:^{
        [[self manager] clear:conversation];
    }];
}

-(void)addAction:(TLSendMessageAction *)action forConversation:(TL_conversation *)conversation {
    
    TGSendingAction *saction = [[TGSendingAction alloc] initWithAction:action time:[[NSDate date] timeIntervalSince1970]+3 conversation:conversation];
    
    if(conversation.type == DialogTypeChannel) {
        if(conversation.chat.isBroadcast)
            return;
    }
    
    NSMutableDictionary *actions = _conversations[@(conversation.peer_id)];
    
    
    
    if(!actions)
    {
        actions = [[NSMutableDictionary alloc] init];
        _conversations[@(conversation.peer_id)] = actions;
    }
    
    if(actions[NSStringFromClass(action.class)] == nil) {
        
        [actions setObject:saction forKey:NSStringFromClass(action.class)];
        
        [self perform];
        
        [self check];
        
    }
    
    
}


-(void)check {
    
    if(self.timer)
        return;
    
    self.timer = [[TGTimer alloc] initWithTimeout:3 repeat:YES completion:^{
        
        __block BOOL checkNext = NO;
        
        NSMutableArray *userActionsToRemove = [[NSMutableArray alloc] init];
        
        [self.conversations enumerateKeysAndObjectsUsingBlock:^(NSNumber *peerId, NSMutableDictionary *obj, BOOL *stop) {
            
            NSMutableArray *actionsToRemove = [[NSMutableArray alloc] init];
            
            [obj enumerateKeysAndObjectsUsingBlock:^(NSString *key, TGSendingAction *action, BOOL *stop) {
                
                if(action.time < [[NSDate date] timeIntervalSince1970]) {
                    [action cancel];
                    [actionsToRemove addObject:key];
                }
                
            }];
            
            [obj removeObjectsForKeys:actionsToRemove];
            
            if(obj.count > 0)
                checkNext = YES;
            else
                [userActionsToRemove addObject:peerId];
            
        }];
        
        [self.conversations removeObjectsForKeys:userActionsToRemove];
        
        
        if(!checkNext) {
            [self.timer invalidate];
            self.timer = nil;
        }
        
        
        [self perform];
        
    } queue:[ASQueue globalQueue].nativeQueue];
    
    [self.timer start];
}


-(void)perform {
        
    [_conversations enumerateKeysAndObjectsUsingBlock:^(NSNumber *userKey, NSMutableDictionary *obj, BOOL *stop) {
            
        NSArray *allObjects = obj.allValues;
            
        allObjects = [allObjects sortedArrayUsingSelector:@selector(compare:)];
        
        TGSendingAction *action = allObjects[0];
        
        [allObjects enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, allObjects.count - 1)] options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [action cancel];
        }];
        
        if(!action.isExecuting)
            [action perform];
            
    }];
    
}


-(void)clear:(TL_conversation *)conversation {
    [_conversations removeObjectForKey:@(conversation.peer_id)];
}

+(TGSendTypingManager *)manager {
    static TGSendTypingManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TGSendTypingManager alloc] init];
    });
    
    return instance;
}

@end
