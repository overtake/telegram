//
//  AllMediaHistoryFilter.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhotoVideoHistoryFilter.h"
#import "ChatHistoryController.h"
@implementation PhotoVideoHistoryFilter

-(int)type {
    return HistoryFilterPhoto | HistoryFilterVideo;
}

+(int)type {
    return HistoryFilterPhoto | HistoryFilterVideo;
}


-(void)remoteRequest:(BOOL)next peer_id:(int)peer_id callback:(void (^)(NSArray *, ChatHistoryState))callback {
    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_search createWithFlags:0 peer:[self.conversation inputPeer] q:@"" filter:[TL_inputMessagesFilterPhotoVideo create] min_date:0 max_date:0 offset:0 max_id:self.min_id limit:(int)self.controller.selectLimit] successHandler:^(RPCRequest *request, TL_messages_messages *response) {
        
        [SharedManager proccessGlobalResponse:response];
        
        if(callback) {
            callback(response.messages,response.messages.count < self.controller.selectLimit ? ChatHistoryStateFull : ChatHistoryStateRemote);
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(callback) {
            callback(nil,ChatHistoryStateRemote);
        }
        
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    
}

-(NSString *)description {
    return NSLocalizedString(@"Conversation.Filter.PhotoVideo", nil);
}

@end
