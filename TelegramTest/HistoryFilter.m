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
#import "AudioHistoryFilter.h"
#import "MP3HistoryFilter.h"
#import "MessageTableItem.h"
#import "SharedLinksHistoryFilter.h"
#import "ChannelImportantFilter.h"
#import "ChannelFilter.h"
@interface HistoryFilter ()
{
    BOOL _de_alloc;
}

@end

@implementation HistoryFilter

static NSMutableDictionary * messageItems;
static NSMutableDictionary * messageKeys;

-(id)initWithController:(ChatHistoryController *)controller {
    if(self = [super init]) {
        self.controller = controller;
    }
    
    return self;
}



+(NSArray *)removeItems:(NSArray *)messageIds {
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [ASQueue dispatchOnStageQueue:^{
        
        [messageIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            TL_localMessage *msg = [[MessagesManager sharedManager] find:[obj intValue]];
            
            if(msg)
            {
                NSArray *f = [[self messageItems:msg.peer_id] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat: @"self.message.n_id IN %@", messageIds]];
                
                [items addObjectsFromArray:f];
                
                [[self messageItems:msg.peer_id] removeObjectsInArray:f];
                
                [[self messageKeys:msg.peer_id] removeObjectsForKeys:messageIds];
            }
            
        }];
        
    } synchronous:YES];
    
    return items;
    
}

+(NSArray *)items:(NSArray *)msgIds {
    

    
    NSMutableArray *messageIds = [msgIds mutableCopy];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [ASQueue dispatchOnStageQueue:^{
        [messageKeys enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary *obj, BOOL *stop) {
            
            
            NSMutableArray *finded = [[NSMutableArray alloc] init];
            
            [messageIds enumerateObjectsUsingBlock:^(NSNumber *msgId, NSUInteger idx, BOOL *stop) {
                
                if(obj[msgId] != nil) {
                    [items addObject:obj[msgId]];
                    [finded addObject:msgId];
                }
                
            }];
            
            [messageIds removeObjectsInArray:finded];
            
            if(messageIds.count == 0)
                *stop = YES;
            
            
        }];
        
    } synchronous:YES];
    
    
    
    return items;
}

+(void)removeAllItems:(int)peerId {
    
    [ASQueue dispatchOnStageQueue:^{
        [[self messageKeys:peerId] removeAllObjects];
        [[self messageItems:peerId] removeAllObjects];
    }];
    
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


-(int)type {
    return HistoryFilterNone;
}

+(int)type {
    return HistoryFilterNone;
}

+(void)drop {
    [ASQueue dispatchOnStageQueue:^{
        [messageKeys removeAllObjects];
        [messageItems removeAllObjects];
        
        
        [PhotoHistoryFilter drop];
        [DocumentHistoryFilter drop];
        [VideoHistoryFilter drop];
        [PhotoVideoHistoryFilter drop];
        [AudioHistoryFilter drop];
        [MP3HistoryFilter drop];
        [SharedLinksHistoryFilter drop];
        [ChannelImportantFilter drop];
        [ChannelFilter drop];
    }];
    
    
    
    
}

-(NSArray *)storageRequest:(BOOL)next {
    int source_id = next ? _controller.max_id : _controller.min_id;
    int maxDate = next ? _controller.maxDate : _controller.minDate;
    
    return [[Storage manager] loadMessages:_controller.conversation.peer.peer_id localMaxId:source_id limit:(int)_controller.selectLimit next:next maxDate:maxDate filterMask:[self type]];

    
}



-(void)remoteRequest:(BOOL)next peer_id:(int)peer_id callback:(void (^)(id response))callback {
    
   int source_id = next ? _controller.server_max_id : _controller.server_min_id;
    
    if(!_controller)
        return;

    self.request = [RPCRequest sendRequest:[TLAPI_messages_getHistory createWithPeer:[[_controller.controller conversation] inputPeer] offset:next ||  source_id == 0 ? 0 : -(int)_controller.selectLimit max_id:source_id min_id:0 limit:(int)_controller.selectLimit] successHandler:^(RPCRequest *request, id response) {
        
        if(callback) {
            callback(response);
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(callback && _controller) {
            callback(nil);
        }
        
    } timeout:10 queue:[ASQueue globalQueue].nativeQueue];
    
}


-(void)dealloc {
    
    _de_alloc = YES;
    
 //   NSLog(@"dealloc %@ : %@",self,[NSThread currentThread]);
    
    
    [self.request cancelRequest];
    self.request = nil;
}

@end
