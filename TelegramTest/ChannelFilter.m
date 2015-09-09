//
//  ChannelFilter.m
//  Telegram
//
//  Created by keepcoder on 25.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelFilter.h"
#import "ChatHistoryController.h"

@interface ChannelFilter()

@end

@implementation ChannelFilter


-(int)type {
    return HistoryFilterChannelMessage;
}

+(int)type {
    return HistoryFilterChannelMessage;
}

-(NSArray *)storageRequest:(BOOL)next state:(ChatHistoryState *)state {
    
    
    int maxId = next ? self.controller.min_id : INT32_MAX;
    int minId = next ? 0 : self.controller.max_id;
    
    int maxDate = next ? self.controller.minDate : INT32_MAX;
    int minDate = next ? 0 : self.controller.maxDate;
    
    
    TGHistoryResponse *response = [[Storage manager] loadChannelMessages:self.controller.conversation.peer_id min_id:minId max_id:maxId minDate:minDate maxDate:maxDate limit:(int)self.controller.selectLimit filterMask:[self type] important:NO];
    
    self.topHole = response.topHole;
    self.botHole = response.botHole;
    
    
    *state = response.result.count < self.controller.selectLimit || (self.botHole || self.topHole) ? ChatHistoryStateRemote : ChatHistoryStateLocal;
    
    return response.result;
    
}

-(void)request:(BOOL)next callback:(void (^)(NSArray *response,ChatHistoryState state))callback {
    
    if([self.controller checkState:ChatHistoryStateRemote next:next]) {
        
        [self remoteRequest:next hole:next ? self.topHole : self.botHole callback:callback];
        
    } else {
        
        ChatHistoryState state;
        
        callback([self storageRequest:next state:&state],state);
        
    }
    
}

-(void)remoteRequest:(BOOL)next max_id:(int)max_id hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback {
    
    
    NSLog(@"remote_max_id:%d, offset:%d",max_id,next? 0 : -(int)self.controller.selectLimit);

    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_getHistory createWithPeer:[self.controller.conversation inputPeer] offset_id:max_id add_offset:next? 0 : -(int)self.controller.selectLimit limit:(int)self.controller.selectLimit max_id:hole ? hole.max_id : INT32_MAX min_id:hole ? hole.min_id : next ? 0 : max_id] successHandler:^(RPCRequest *request, TL_messages_channelMessages * response) {
        
         
        [SharedManager proccessGlobalResponse:response];
        
        
        NSArray *messages = [[response messages] copy];
        
        
        
        [self fillGroupHoles:messages bottom:!next];

        
        
         TGMessageHole *nHole = nil;
         
        if(messages.count == response.messages.count && messages.count < self.controller.selectLimit) {
            
            [[Storage manager] removeHole:next ? self.topHole : self.botHole];
            
        } else if(hole != nil) {
            
            int min = hole.min_id;
            int max = hole.max_id;
            
            if(messages.count > 0)
            {
                TL_localMessage *first = [messages firstObject];
                TL_localMessage *last = [messages lastObject];
                
                max = first.n_id;
                min = last.n_id;
            }
            
            
            
           nHole = [[TGMessageHole alloc] initWithUniqueId:hole.uniqueId peer_id:hole.peer_id min_id:next ? hole.min_id : max max_id:next ? min : hole.max_id date:hole.date count:0];
            
            
            if(nHole.min_id == nHole.max_id) {
                [[Storage manager] removeHole:nHole];
                nHole = nil;
            } else
                [[Storage manager] insertMessagesHole:nHole];
            
            
        }
         
         if(next)
             self.topHole = nHole;
         else
             self.botHole = nHole;
        
        if(callback) {
            callback(messages,!nHole ? ChatHistoryStateLocal : ChatHistoryStateRemote);
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(callback && self.controller) {
            callback(nil,NO);
        }
        
    } timeout:10 queue:[ASQueue globalQueue].nativeQueue];
    

}


-(void)remoteRequest:(BOOL)next hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback {
    
    int maxId = next ? self.controller.server_max_id : self.controller.server_min_id;
    
    if(hole != nil && !next) {
        maxId = hole.min_id;
    } else if(hole != nil && next) {
        maxId = hole.max_id;
    }
    
    if(next)
        self.topHole = hole;
    else
        self.botHole = hole;
    
    [self remoteRequest:next max_id:maxId hole:hole callback:callback];
    
}


-(void)fillGroupHoles:(NSArray *)messages bottom:(BOOL)bottom {
    
    if(messages.count == 0)
        return;
    
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    
    
    TL_localMessage *first = [messages firstObject];
    TL_localMessage *last = [messages lastObject];
    
    int max = first.n_id;
    int min = last.n_id;
    
    [groups addObjectsFromArray:[[Storage manager] groupHoles:self.controller.conversation.peer_id min:min max:max]];
    
    // max to min
    [messages enumerateObjectsWithOptions:bottom ? NSEnumerationReverse : 0  usingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
        
        TGMessageGroupHole *slamHole = [[groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.max_id > %d AND self.min_id <= %d",obj.n_id,obj.n_id]] firstObject];
        
        if(slamHole != nil) {
            
                if([obj isImportantMessage]) {
                    
                    if(bottom) {
                        slamHole.max_id = obj.n_id;
                    } else {
                        slamHole.min_id = obj.n_id;
                    }
                } else {
                    slamHole.messagesCount++;
                }
        } else  if(![obj isImportantMessage]) {
            [groups addObject:[[TGMessageGroupHole alloc] initWithUniqueId:-rand_int() peer_id:obj.peer_id min_id:bottom?obj.n_id:0 max_id:bottom?INT32_MAX:obj.n_id+1 date:bottom?INT32_MAX:obj.date count:1]];
        }
        
   }];
    
    [groups enumerateObjectsUsingBlock:^(TGMessageHole *obj, NSUInteger idx, BOOL *stop) {
        [[Storage manager] insertMessagesHole:obj];
    }];
    
}


@end
