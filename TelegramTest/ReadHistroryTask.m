//
//  ReadHistroryTask.m
//  Messenger for Telegram
//
//  Created by keepcoder on 28.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ReadHistroryTask.h"
#import "TMTaskRequest.h"
@interface ReadHistroryTask ()
@property (nonatomic,strong) TL_conversation *conversation;
@end

@implementation ReadHistroryTask

@synthesize params = _params;
@synthesize taskId = _taskId;
@synthesize delegate = _delegate;

-(id)initWithParams:(NSDictionary *)params taskId:(NSUInteger)taskId {
    if(self = [self initWithParams:params]) {
        _taskId = taskId;
    }
    
    return self;
}

-(id)initWithParams:(NSDictionary *)params {
    if(self = [super init]) {
        _params = params;
        _conversation = [_params objectForKey:@"conversation"];
        _taskId = [TMTaskRequest futureTaskId];
    }
    
    return self;
}

-(void)execute {
    
    
    if(_conversation) {
        
        if([_delegate respondsToSelector:@selector(didStartTaskRequest:)]) {
            [_delegate didStartTaskRequest:self];
        }
        
        [self loop:0];
    } else {
        if([_delegate respondsToSelector:@selector(didCompleteTaskRequest:)]) {
            [_delegate didCompleteTaskRequest:self];
        }
    }
    
}


-(void)loop:(int)offset {
    
    
    id request;
    if(_conversation.type == DialogTypeSecretChat) {
        
        request = [TLAPI_messages_readEncryptedHistory createWithPeer:[_conversation.encryptedChat inputPeer] max_date:[[MTNetwork instance] getTime]];
    } else if(_conversation.type != DialogTypeChannel) {
        request = [TLAPI_messages_readHistory createWithPeer:[_conversation inputPeer] max_id:_conversation.read_inbox_max_id];
    } else {
        request = [TLAPI_channels_readHistory createWithChannel:[_conversation inputPeer] max_id:_conversation.read_inbox_max_id]; //TODO
    }
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
       
        if(![response isKindOfClass:[TL_boolTrue class]] && ![response isKindOfClass:[TL_boolFalse class]])  {
            TL_messages_affectedMessages *history = response;
           
            [ASQueue dispatchOnMainQueue:^{
                if([_delegate respondsToSelector:@selector(didCompleteTaskRequest:)]) {
                    [_delegate didCompleteTaskRequest:self];
                }
            }];
            
        } else {
            
            [ASQueue dispatchOnMainQueue:^{
                if([_delegate respondsToSelector:@selector(didCompleteTaskRequest:)]) {
                    [_delegate didCompleteTaskRequest:self];
                }
            }];
        }
        
    } errorHandler:nil timeout:0 queue:taskQueue().nativeQueue];
    

}



-(void)deleteTask {
   
}





@end
