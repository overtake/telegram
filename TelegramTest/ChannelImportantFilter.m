//
//  ChannelImportantFilter.m
//  Telegram
//
//  Created by keepcoder on 25.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelImportantFilter.h"
#import "ChatHistoryController.h"

@interface ChannelImportantFilter()

@end

@implementation ChannelImportantFilter


static NSMutableDictionary * messageItems;
static NSMutableDictionary * messageKeys;

-(id)initWithController:(ChatHistoryController *)controller {
    if(self = [super initWithController:controller]) {
        
    }
    return self;
}


-(int)type {
    return HistoryFilterChannelMessage;
}

+(int)type {
    return HistoryFilterChannelMessage;
}


- (NSMutableDictionary *)messageKeys:(int)peer_id {
    return [[self class] messageKeys:peer_id];
}

- (NSMutableArray *)messageItems:(int)peer_id {
    return [[self class] messageItems:peer_id];
}

+ (NSMutableDictionary *)messageKeys:(int)peer_id {
    
    __block NSMutableDictionary *keys;
    [ASQueue dispatchOnStageQueue:^{
        
        keys = messageKeys[@(peer_id)];
        
        if(!keys)
        {
            keys = [[NSMutableDictionary alloc] init];
            messageKeys[@(peer_id)] = keys;
        }
        
    } synchronous:YES];
    
    return keys;
}

+ (NSMutableArray *)messageItems:(int)peer_id {
    __block NSMutableArray *items;
    
    [ASQueue dispatchOnStageQueue:^{
        
        items = messageItems[@(peer_id)];
        
        if(!items)
        {
            items = [[NSMutableArray alloc] init];
            messageItems[@(peer_id)] = items;
        }
        
    } synchronous:YES];
    
    
    
    return items;
}
+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messageItems = [[NSMutableDictionary alloc] init];
        messageKeys = [[NSMutableDictionary alloc] init];
        
    });
}


+(void)drop {
    [ASQueue dispatchOnStageQueue:^{
        [messageKeys removeAllObjects];
        [messageItems removeAllObjects];
    }];
}

-(NSArray *)storageRequest:(BOOL)next state:(ChatHistoryState *)state {
    
    
    int maxId = next ? self.controller.min_id : INT32_MAX;
    int minId = next ? 0 : self.controller.max_id;
    
    int maxDate = next ? self.controller.minDate : INT32_MAX;
    int minDate = next ? 0 : self.controller.maxDate;
    
    
    TGHistoryResponse *response = [[Storage manager] loadChannelMessages:self.controller.conversation.peer_id min_id:minId max_id:maxId minDate:minDate maxDate:maxDate limit:(int)self.controller.selectLimit filterMask:[self type] important:YES];

    
    *state = [response.result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id > 0"]].count == 0 ? ChatHistoryStateRemote : ChatHistoryStateLocal;
    
    return response.result;
    
}

-(void)request:(BOOL)next callback:(void (^)(NSArray *response,ChatHistoryState state))callback {
    
    if([self.controller checkState:ChatHistoryStateRemote next:next]) {
        
        [self remoteRequest:next hole:nil callback:callback];
        
    } else {
        
        ChatHistoryState state;
        
        callback([self storageRequest:next state:&state],state);
        
    }
    
}

-(void)remoteRequest:(BOOL)next max_id:(int)max_id hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback {
    
    
    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_getImportantHistory createWithPeer:[self.controller.conversation inputPeer] max_id:max_id min_id:0 limit:(int)self.controller.selectLimit] successHandler:^(RPCRequest *request, TL_messages_channelMessages * response) {
        
        [SharedManager proccessGlobalResponse:response];
        
        
        NSArray *messages = [[response messages] arrayByAddingObjectsFromArray:[self fillGroupHoles:[response collapsed] peer_id:self.controller.conversation.peer_id bottom:next]];
        
        if(callback) {
            callback(messages,response.messages.count < self.controller.selectLimit ? ChatHistoryStateFull : ChatHistoryStateRemote);
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(callback && self.controller) {
            callback(nil,NO);
        }
        
    } timeout:10 queue:[ASQueue globalQueue].nativeQueue];
    
    
}


-(void)remoteRequest:(BOOL)next hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback {
    
    int maxId = next ? self.controller.server_max_id : self.controller.server_min_id;
    
    [self remoteRequest:next max_id:maxId hole:hole callback:callback];
    
}



-(NSArray *)fillGroupHoles:(NSArray *)collapsed peer_id:(int)peer_id bottom:(BOOL)bottom {
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    [collapsed enumerateObjectsUsingBlock:^(TL_messageGroup *obj, NSUInteger idx, BOOL *stop) {
        
        
        TGMessageGroupHole *groupHole = [[TGMessageGroupHole alloc] initWithUniqueId:-rand_int() peer_id:peer_id min_id:obj.min_id max_id:obj.max_id date:obj.date count:obj.n_count];
        
        TGMessageHole *hole = [[TGMessageHole alloc] initWithUniqueId:-rand_int() peer_id:peer_id min_id:obj.min_id max_id:obj.max_id date:obj.date count:0];
        
        TL_localMessageService *msg = [TL_localMessageService createWithN_id:hole.uniqueId flags:0 from_id:0 to_id:[TL_peerChannel createWithChannel_id:peer_id] date:obj.date action:[TL_messageActionEmpty create] fakeId:0 randomId:rand_long() dstate:DeliveryStateNormal];
        
        msg.hole = groupHole;
        
        [messages addObject:msg];
        
        [[Storage manager] insertMessagesHole:groupHole];
        [[Storage manager] insertMessagesHole:hole];
        
        
    }];
    
    
    return [messages copy];
    
    
}

@end
