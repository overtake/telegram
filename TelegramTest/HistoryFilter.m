//
//  HistoryFilter.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "HistoryFilter.h"

#import "ChatHistoryController.h"
#import "PhotoHistoryFilter.h"
#import "PhotoVideoHistoryFilter.h"
#import "VideoHistoryFilter.h"
#import "DocumentHistoryFilter.h"
#import "TGMessage+Extensions.h"
#import "MessageTableItem.h"
@interface HistoryFilter ()

@end

@implementation HistoryFilter

static NSMutableArray * messageItems;
static NSMutableDictionary * messageKeys;

-(id)initWithController:(ChatHistoryController *)controller {
    if(self = [super init]) {
        self.controller = controller;
    }
    
    return self;
}



+(void)removeItems:(NSArray *)messageIds {
    
    NSArray *res = [[self messageItems] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat: @"self.message.n_id IN %@", messageIds]];
    [[self messageItems] removeObjectsInArray:res];
    
    for (MessageTableItem *item in res) {
        [[self messageKeys] removeObjectForKey:@(item.message.n_id)];
    }
}

+(void)removeAllItems:(int)peerId {
    
    NSArray *res = [[self messageItems] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.message.peer_id == %d AND self.message.n_id != 0",peerId]];
    
    [[self messageItems] removeObjectsInArray:res];
    
    for (MessageTableItem *item in res) {
        [[self messageKeys] removeObjectForKey:@(item.message.n_id)];
    }
    
    
}

- (NSMutableDictionary *)messageKeys {
    return messageKeys;
}

- (NSMutableArray *)messageItems {
    return messageItems;
}

+ (NSMutableDictionary *)messageKeys {
    return messageKeys;
}

+ (NSMutableArray *)messageItems {
    return messageItems;
}

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messageItems = [[NSMutableArray alloc] init];
        messageKeys = [[NSMutableDictionary alloc] init];
        
    });
}


-(int)type {
    return HistoryFilterNone;
}

+(int)type {
    return HistoryFilterNone;
}

+(void)drop {
    [messageKeys removeAllObjects];
    [messageItems removeAllObjects];
    
    [PhotoHistoryFilter drop];
    [DocumentHistoryFilter drop];
    [VideoHistoryFilter drop];
    [PhotoVideoHistoryFilter drop];
}

-(void)storageRequest:(BOOL)next callback:(void (^)(NSArray *result))callback {
    int source_id = next ? _controller.max_id : _controller.min_id;
    int maxDate = next ? _controller.maxDate : _controller.minDate;
    [[Storage manager] loadMessages:_controller.conversation.peer.peer_id localMaxId:source_id limit:(int)_controller.selectLimit next:next maxDate:maxDate filterMask:[self type] completeHandler:^(NSArray *result) {
        
        if(callback) {
            callback(result);
        }
        
    }];
    
}

-(void)remoteRequest:(BOOL)next callback:(void (^)(id response))callback {
    
    int source_id = next ? _controller.server_max_id : _controller.server_min_id;
    
    self.request = [RPCRequest sendRequest:[TLAPI_messages_getHistory createWithPeer:[_controller.conversation inputPeer] offset:next ||  source_id == 0 ? 0 : -(int)_controller.selectLimit max_id:source_id limit:(int)_controller.selectLimit] successHandler:^(RPCRequest *request, id response) {
        

        if(callback) {
            callback(response);
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(callback) {
            callback(nil);
        }
        
    } timeout:10 queue:[ASQueue globalQueue].nativeQueue];
    
}


-(void)dealloc {
    [self.request cancelRequest];
    self.request = nil;
}

@end
