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
                
                
                // updateMessageId;
                
                [[response other_updates] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    if([obj isKindOfClass:[TL_updateMessageID class]]) {
                        [[Storage manager] updateMessageId:[(TL_updateMessageID *)obj random_id] msg_id:[(TL_updateMessageID *)obj n_id]];
                    }
                    
                }];
                
                self.conversation.pts = [(TL_updates_channelDifference *)response pts];
                
                [self.conversation save];
                
                [TL_localMessage convertReceivedMessages:[response n_messages]];
                
                [[Storage manager] insertMessages:[response n_messages]];
                
                [Notification perform:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:[response n_messages]}];
                
                                
            } else if([response isKindOfClass:[TL_updates_channelDifferenceTooLong class]]) {
                
                _conversation.pts = [response pts];
                
                _conversation.top_message = [response top_message];
                _conversation.read_inbox_max_id = [response read_inbox_max_id];
                _conversation.unread_count = [response unread_count];
                
                [_conversation save];
                
                
                __block TL_localMessage *topMsg;
                __block TL_localMessage *minMsg;
                
                [[response messages] enumerateObjectsUsingBlock:^(TLMessage *obj, NSUInteger idx, BOOL *stop) {
                    
                    TL_localMessage *c = [TL_localMessage convertReceivedMessage:obj];
                    
                    if([response top_message] == c.n_id)
                        topMsg = c;
                    
                    if(!minMsg || c.n_id < minMsg.n_id)
                        minMsg = c;
                    
                }];
                
                {
                    if(minMsg.n_id != topMsg.n_id) {
                        TGMessageHole *hole = [[TGMessageHole alloc] initWithUniqueId:-rand_int() peer_id:minMsg.peer_id min_id:minMsg.n_id max_id:topMsg.n_id date:minMsg.date count:0];
                        
                        [[Storage manager] insertMessagesHole:hole];
                    }
                    
                    int maxSyncedId = [[Storage manager] lastSyncedMessageIdWithChannelId:self.conversation.peer_id important:NO];
                    
                    TGMessageHole *longHole = [[TGMessageHole alloc] initWithUniqueId:-rand_int() peer_id:topMsg.peer_id min_id:maxSyncedId max_id:minMsg.n_id date:minMsg.date count:0];
                    
                    [[Storage manager] insertMessagesHole:longHole];
                    
                }
                
                [SharedManager proccessGlobalResponse:response];
                
                [_delegate pollingDidSaidTooLong];
            }
            
            
            
            
            
            if(!repeat && !_isStoped)
                [self launchTimer:[response timeout] repeat:YES];
            
        } errorHandler:^(id request, RpcError *error) {
            
            
            
        } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
        
        
    } queue:[ASQueue globalQueue].nativeQueue];
    
    [_timer start];
    
}



@end
