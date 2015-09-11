//
//  MP3HistoryFilter.m
//  Telegram
//
//  Created by keepcoder on 24.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "MP3HistoryFilter.h"
#import "ChatHistoryController.h"
@implementation MP3HistoryFilter


-(int)type {
    return HistoryFilterAudioDocument;
}

+(int)type {
    return HistoryFilterAudioDocument;
}

-(void)remoteRequest:(BOOL)next peer_id:(int)peer_id callback:(void (^)(id response))callback {
    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_search createWithFlags:0 peer:[self.controller.conversation inputPeer] q:@"" filter:[TL_inputMessagesFilterAudioDocuments create] min_date:0 max_date:0 offset:0 max_id:self.controller.max_id limit:(int)self.controller.selectLimit] successHandler:^(RPCRequest *request, id response) {
        
        
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
    return NSLocalizedString(@"Conversation.Filter.MP3", nil);
}

@end
