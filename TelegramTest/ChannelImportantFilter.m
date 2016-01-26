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
    
    
    ChatHistoryState nstate;
    
    NSArray *result = [super storageRequest:next state:&nstate];
    
    *state = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id > 0"]].count < self.controller.selectLimit  || [self confirmHoleWithNext:next] ? ChatHistoryStateRemote : ChatHistoryStateLocal;
    
    return result;
    
}


-(void)remoteRequest:(BOOL)next max_id:(int)max_id hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback {
    
    
    TLChat *chat = [[ChatsManager sharedManager] find:self.peer.channel_id];
    
    
    
    self.request = [RPCRequest sendRequest:[TLAPI_channels_getImportantHistory createWithChannel:[TL_inputChannel createWithChannel_id:self.peer.channel_id access_hash:chat.access_hash] offset_id:max_id add_offset:next? 0 : -(int)self.controller.selectLimit limit:(int)self.controller.selectLimit max_id:hole ? hole.max_id : INT32_MAX min_id:hole ? hole.min_id : next ? 0 : max_id] successHandler:^(RPCRequest *request, TL_messages_channelMessages * response) {
        
        [SharedManager proccessGlobalResponse:response];
        
        
        NSArray *messages = [[response messages] arrayByAddingObjectsFromArray:[self fillGroupHoles:[response collapsed] peer_id:self.peer_id bottom:next]];
         
         [self setHole:[self proccessAndGetHoleWithHole:hole next:next messages:[response messages]] withNext:next];
        
        if(callback) {
            callback(messages,hole && ![self holeWithNext:next] ? ChatHistoryStateLocal : messages.count < self.controller.selectLimit && !hole && ![self holeWithNext:next] ? ChatHistoryStateFull : ChatHistoryStateRemote);
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(callback && self.controller) {
            callback(nil,ChatHistoryStateRemote);
        }
        
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    
    
}


-(void)remoteRequest:(BOOL)next hole:(TGMessageHole *)hole callback:(void (^)(id response,ChatHistoryState state))callback {
    
    int maxId = next ? self.server_min_id : self.server_max_id;
    
    [self remoteRequest:next max_id:maxId hole:hole callback:callback];
    
}



-(NSArray *)fillGroupHoles:(NSArray *)collapsed peer_id:(int)peer_id bottom:(BOOL)bottom {
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    
    
    [collapsed enumerateObjectsUsingBlock:^(TL_messageGroup *obj, NSUInteger idx, BOOL *stop) {
        
           
        int uniqueId =  -rand_int();
        
        NSArray *holes = [[Storage manager] groupHoles:peer_id min:obj.min_id max:obj.max_id];
        
        TGMessageGroupHole *unslamHole = [holes lastObject];
        
        if(unslamHole)
            uniqueId = unslamHole.uniqueId;
        
    
        
        TGMessageGroupHole *groupHole = [[TGMessageGroupHole alloc] initWithUniqueId:uniqueId peer_id:peer_id min_id:obj.min_id max_id:obj.max_id date:obj.date count:obj.n_count isImploded:YES];
        
        [[Storage manager] insertMessagesHole:groupHole];

        
        if(groupHole.uniqueId != unslamHole.uniqueId) {
            TGMessageHole *hole = [[TGMessageHole alloc] initWithUniqueId:-rand_int() peer_id:peer_id min_id:obj.min_id max_id:obj.max_id date:obj.date count:0];
            
            TL_localMessageService *msg = [TL_localMessageService createWithHole:groupHole];
            
            [messages addObject:msg];
            
            [hole save];
        } else {
            [Notification perform:UPDATE_MESSAGE_GROUP_HOLE data:@{KEY_GROUP_HOLE:groupHole}];
        }
        
        
        
        
    }];
    
    
    return [messages copy];
    
    
}


-(int)additionSenderFlags {
    return (1 << 4);
}

@end
