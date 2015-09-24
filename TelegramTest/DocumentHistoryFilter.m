//
//  DocumentHistoryFilter.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DocumentHistoryFilter.h"
#import "ChatHistoryController.h"
@implementation DocumentHistoryFilter

-(int)type {
    return HistoryFilterDocuments;
}

+(int)type {
    return HistoryFilterDocuments;
}

-(void)remoteRequest:(BOOL)next peer_id:(int)peer_id callback:(void (^)(id response))callback {
    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_search createWithFlags:0 peer:[self.controller.conversation inputPeer] q:@"" filter:[TL_inputMessagesFilterDocument create] min_date:0 max_date:0 offset:0 max_id:self.controller.max_id  limit:(int)self.controller.selectLimit] successHandler:^(RPCRequest *request, id response) {
        
        
        if(callback && self != nil) {
            callback(response);
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(callback && self != nil) {
            callback(nil);
        }
        
    } timeout:10 queue:[ASQueue globalQueue].nativeQueue];
    
}

-(NSString *)description {
    return NSLocalizedString(@"Conversation.Filter.Files", nil);
}

@end
