//
//  TGChannelsPolling.m
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGChannelsPolling.h"
#import "TGTimer.h"
#import "TGForceChannelUpdate.h"
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


-(BOOL)isActive {
    return !_isStoped;
}

-(void)setCurrentConversation:(TL_conversation *)conversation {
    
    [ASQueue dispatchOnStageQueue:^{
        
        [self stop];
        
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
        
        [[MTNetwork instance].updateService.proccessor failUpdateWithChannelId:_conversation.peer.channel_id limit:_limit withCallback:^(id response, TGMessageHole *longHole) {
            
            [ASQueue dispatchOnStageQueue:^{
                
                _lastRequestTime[@(_conversation.peer_id)] = @([[MTNetwork instance] getTime]);
                
                if([response isKindOfClass:[TL_updates_channelDifferenceEmpty class]]) {
                    
                    
                } else if([response isKindOfClass:[TL_updates_channelDifference class]]) {
                    
                } else if([response isKindOfClass:[TL_updates_channelDifferenceTooLong class]]) {
                    
                    [_delegate pollingDidSaidTooLongWithHole:longHole];
                }
                
                 if(!repeat && !_isStoped)
                    [self launchTimer:[response timeout] repeat:YES];
                
            }];
        
            
        } errorCallback:^(RpcError *error) {
            if(!repeat && !_isStoped)
                [self launchTimer:15 repeat:YES];
        }];
        
        
    } queue:[ASQueue globalQueue].nativeQueue];
    
    [_timer start];
    
}


-(void)checkInvalidatedMessages:(NSArray *)result important:(BOOL)important {
    
    
    
    
    result = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id > 0"]];
    
    BOOL invalidate = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.invalidate == 1"]].count > 0;
    
    
    
    if(!invalidate || _conversation.pts == 0 || result.count == 0)
    {
        return;
    }
    
    TL_localMessage *firstObject = [result firstObject];
    TL_localMessage *lastObject = [result lastObject];
    
    int pts = lastObject.n_id;
    
    int limit = _conversation.pts - pts;
    
    
    [RPCRequest sendRequest:[TLAPI_updates_getChannelDifference createWithChannel:[TL_inputChannel createWithChannel_id:_conversation.chat.n_id access_hash:_conversation.chat.access_hash] filter:[TL_channelMessagesFilter createWithFlags:important ? (1 << 0) : 0 ranges:[@[[TL_messageRange createWithMin_id:lastObject.n_id max_id:firstObject.n_id]] mutableCopy]] pts:pts limit:limit] successHandler:^(id request, TL_updates_channelDifference *response) {
        
        
        if([response isKindOfClass:[TL_updates_channelDifference class]]) {
            [response.other_updates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                [[MTNetwork instance].updateService.proccessor addUpdate:[[TGForceChannelUpdate alloc] initWithUpdate:obj]];
                
            }];
            
        }
        
        NSMutableArray *ids = [NSMutableArray array];
        
        [result enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            [ids addObject:@(obj.channelMsgId)];
        }];

        [[Storage manager] validateChannelMessages:ids];
        
        
    } errorHandler:^(id request, RpcError *error) {
        
        
    } timeout:0 queue:dispatch_get_current_queue()];
    
}


@end
