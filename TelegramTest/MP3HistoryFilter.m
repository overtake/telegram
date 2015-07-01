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

static NSMutableDictionary * messageItems;
static NSMutableDictionary * messageKeys;

-(id)initWithController:(ChatHistoryController *)controller {
    if(self = [super initWithController:controller]) {
        
    }
    
    return self;
}


+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messageItems = [[NSMutableDictionary alloc] init];
        messageKeys = [[NSMutableDictionary alloc] init];
        
    });
}


-(int)type {
    return HistoryFilterAudioDocument;
}

+(int)type {
    return HistoryFilterAudioDocument;
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


+(void)drop {
    [ASQueue dispatchOnStageQueue:^{
        [messageKeys removeAllObjects];
        [messageItems removeAllObjects];
    }];
}



-(void)remoteRequest:(BOOL)next peer_id:(int)peer_id callback:(void (^)(id response))callback {
    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_search createWithPeer:[self.controller.conversation inputPeer] q:@"" filter:[TL_inputMessagesFilterAudioDocuments create] min_date:0 max_date:0 offset:0 max_id:self.controller.max_id limit:(int)self.controller.selectLimit] successHandler:^(RPCRequest *request, id response) {
        
        
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
