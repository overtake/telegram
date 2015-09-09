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


-(int)type {
    return HistoryFilterImportantChannelMessage;
}

+(int)type {
    return HistoryFilterImportantChannelMessage;
}

-(NSArray *)storageRequest:(BOOL)next state:(ChatHistoryState *)state {
    
    
    int maxId = next ? self.controller.min_id : INT32_MAX;
    int minId = next ? 0 : self.controller.max_id;
    
    int maxDate = next ? self.controller.minDate : INT32_MAX;
    int minDate = next ? 0 : self.controller.maxDate;
    
    
    TGHistoryResponse *response = [[Storage manager] loadChannelMessages:self.controller.conversation.peer_id min_id:minId max_id:maxId minDate:minDate maxDate:maxDate limit:(int)self.controller.selectLimit filterMask:[self type] important:YES];

    
    *state = [response.result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id > 0"]].count < self.controller.selectLimit ? ChatHistoryStateRemote : ChatHistoryStateLocal;
    
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
    
    
    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_getImportantHistory createWithPeer:[self.controller.conversation inputPeer] offset_id:max_id add_offset:next? 0 : -(int)self.controller.selectLimit limit:(int)self.controller.selectLimit max_id:hole ? hole.max_id : INT32_MAX min_id:hole ? hole.min_id : next ? 0 : max_id] successHandler:^(RPCRequest *request, TL_messages_channelMessages * response) {
        
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
        
        TL_localMessageService *msg = [TL_localMessageService createWithHole:groupHole];
        
        [messages addObject:msg];
        
        [[Storage manager] insertMessagesHole:groupHole];
        [[Storage manager] insertMessagesHole:hole];
        
        
    }];
    
    
    return [messages copy];
    
    
}

@end
