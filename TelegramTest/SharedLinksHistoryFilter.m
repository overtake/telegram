//
//  SharedLinksHistoryFilter.m
//  Telegram
//
//  Created by keepcoder on 24.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SharedLinksHistoryFilter.h"
#import "ChatHistoryController.h"
@implementation SharedLinksHistoryFilter


-(int)type {
    return HistoryFilterSharedLink;
}

+(int)type {
    return HistoryFilterSharedLink;
}

-(void)remoteRequest:(BOOL)next peer_id:(int)peer_id callback:(void (^)(id response))callback {
    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_search createWithFlags:0 peer:[self.controller.conversation inputPeer] q:@"" filter:[TL_inputMessagesFilterUrl create] min_date:0 max_date:0 offset:0 max_id:self.controller.max_id limit:(int)self.controller.selectLimit] successHandler:^(RPCRequest *request, id response) {
        
        
        if(callback && self != nil) {
            callback(response);
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(callback) {
            callback(nil);
        }
        
    } timeout:10 queue:[ASQueue globalQueue].nativeQueue];
    
}

-(NSString *)description {
    return NSLocalizedString(@"Conversation.Filter.SharedLinks", nil);
}
@end
