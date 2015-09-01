//
//  TGChannelsPolling.m
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGChannelsPolling.h"
#import "TGTimer.h"

@interface TGChannelsPolling ()
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,assign) int pts;
@property (nonatomic,assign) int limit;
@property (nonatomic,strong) TGTimer *timer;
@property (nonatomic,strong) RPCRequest *request;
@property (nonatomic,strong) NSMutableDictionary *lastRequestTime;

@property (nonatomic,assign) BOOL isStoped;

@end

@implementation TGChannelsPolling

static int pollingDelay = 5;

-(id)initWithDelegate:(id <TGChannelPollingDelegate>)delegate withUpdatesLimit:(int)limit {
    if(self = [super init]) {
        _delegate = delegate;
        _limit = limit;
        _lastRequestTime = [NSMutableDictionary dictionary];
    }
    
    return self;
}


-(void)setCurrentConversation:(TL_conversation *)conversation {
    
    [ASQueue dispatchOnStageQueue:^{
        
         _conversation = conversation;
        
        
    }];
   
}

-(void)stop {
    [ASQueue dispatchOnStageQueue:^{
        [_request cancelRequest];
        [_timer invalidate];
        _timer = nil;
        _isStoped = YES;
    }];
    
    
}

-(void)start {
    
    [ASQueue dispatchOnStageQueue:^{
        [self stop];
        
        _isStoped = NO;
        
        int time = [_lastRequestTime[@(_conversation.peer_id)] intValue];
        
        
        int dif = time;
        
        if(dif != 0)
            dif = MIN(time + pollingDelay  - [[MTNetwork instance] getTime],pollingDelay);
        
        [self launchTimer:dif repeat:NO];
        
        
    }];
    
    
}

-(void)launchTimer:(int)time repeat:(BOOL)repeat {
    
    _timer = [[TGTimer alloc] initWithTimeout:time repeat:repeat completion:^{
        
        _request = [RPCRequest sendRequest:[TLAPI_updates_getChannelDifference createWithPeer:[TL_inputPeerChannel createWithChannel_id:_conversation.peer.channel_id access_hash:_conversation.chat.access_hash] filter:[TL_channelMessagesFilterEmpty create] pts:_conversation.pts limit:_limit] successHandler:^(id request, id response) {
            
            
            _lastRequestTime[@(_conversation.peer_id)] = @([[MTNetwork instance] getTime]);
            
            if([response isKindOfClass:[TL_updates_channelDifferenceEmpty class]]) {
                
                
            } else if([response isKindOfClass:[TL_updates_channelDifference class]]) {
                
                [_delegate pollingReceivedUpdates:response endPts:[response pts]];
                
            } else if([response isKindOfClass:[TL_updates_channelDifferenceTooLong class]]) {
                [_delegate pollingDidSaidTooLong:[response pts]];
            }
            
            if(!repeat && !_isStoped)
                [self launchTimer:pollingDelay repeat:YES];
            
        } errorHandler:^(id request, RpcError *error) {
            
            
            
        } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
        
        
    } queue:[ASQueue globalQueue].nativeQueue];
    
    [_timer start];
    
}



@end
