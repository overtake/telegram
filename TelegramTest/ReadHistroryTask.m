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
@property (nonatomic,strong) TGPeer *peer;
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
        _peer = [_params objectForKey:@"peer"];
        _taskId = [TMTaskRequest futureTaskId];
    }
    
    return self;
}

-(void)execute {
    
    if(!_conversation) {
        _conversation = [[Storage manager] selectConversation:_peer];
    }
    
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
    } else {
        request = [TLAPI_messages_readHistory createWithPeer:[_conversation inputPeer] max_id:_conversation.top_message offset:offset read_contents:YES];
    }
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
       
        if(![response isKindOfClass:[TL_boolTrue class]] && ![response isKindOfClass:[TL_boolFalse class]])  {
            TL_messages_affectedHistory *history = response;
            if(history.offset > 0) {
                [self loop:history.offset];
            } else {
                if([_delegate respondsToSelector:@selector(didCompleteTaskRequest:)]) {
                    [_delegate didCompleteTaskRequest:self];
                }
            }
        } else {
            if([_delegate respondsToSelector:@selector(didCompleteTaskRequest:)]) {
                [_delegate didCompleteTaskRequest:self];
            }
        }
        
    } errorHandler:nil];
    

}



-(void)deleteTask {
   
}





@end
