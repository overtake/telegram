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
@property (nonatomic,strong,readonly) TGMessageHole *botHole;
@property (nonatomic,strong,readonly) TGMessageHole *topHole;
@end

@implementation HistoryFilter


static NSMutableDictionary * classItems;


static NSString *kMessageKeys = @"kMessageKeys";
static NSString *kMessageItems = @"kMessageItems";

-(id)initWithController:(ChatHistoryController *)controller {
    if(self = [super init]) {
        self.controller = controller;
    }
    
    return self;
}


+(id)removeItemWithMessageId:(int)messageId withPeer_id:(int)peer_id  {
    
    __block id item;
    
    [ASQueue dispatchOnStageQueue:^{
        
        
        item = [self messageKeys:peer_id][@(messageId)];
        
        if(item) {
            [[self messageKeys:peer_id] removeObjectForKey:@(messageId)];
            [[self messageItems:peer_id] removeObject:item];
        }
        
      
    } synchronous:YES];
    
    return item;
    
}

+(NSMutableDictionary *)fClassData {
    
    NSMutableDictionary *classData = classItems[NSStringFromClass(self.class)];
    
    if(classData == nil) {
        classData = [NSMutableDictionary dictionary];
        classData[kMessageItems] = [NSMutableDictionary dictionary];
        classData[kMessageKeys] = [NSMutableDictionary dictionary];
        
        classItems[NSStringFromClass(self.class)] = classData;
    }
    
    return classData;
}

+(NSMutableDictionary *)fClassItems {
    
    id items = self.fClassData[kMessageItems];
    
    
    assert(items != nil);
    
    return items;
}
+(NSMutableDictionary *)fClassKeys {
    id keys = self.fClassData[kMessageKeys];
    
    assert(keys != nil);
    
    return keys;
}

+(void)items:(NSArray *)msgIds complete:(void (^)(NSArray *list))complete  {
    
    NSMutableArray *messageIds = [msgIds mutableCopy];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    [ASQueue dispatchOnStageQueue:^{
        [self.fClassKeys enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary *obj, BOOL *stop) {
            
            
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
        
        dispatch_async(dqueue, ^{
            complete([items copy]);
        });
    }];
    

}

+(void)updateItemId:(long)randomId withId:(int)n_id {
    
    [ASQueue dispatchOnStageQueue:^{
        
        [self.fClassItems enumerateKeysAndObjectsUsingBlock:^(NSNumber *peer_id, NSMutableArray *obj, BOOL *stop) {
            
            NSArray *f = [obj filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.message.randomId = %ld",randomId]];
            MessageTableItem *item = [f firstObject];
            
            if(item) {
                NSMutableDictionary *keys =[self messageKeys:[peer_id intValue]];
                [keys removeObjectForKey:@(item.message.n_id)];
                item.message.n_id = n_id;
                keys[@( item.message.n_id)] = item;
            }
            
        }];
        
    }];
    
}

+(void)items:(NSArray *)messageIds withPeer_id:(int)peer_id complete:(void (^)(NSArray *list))complete {
    
    __block NSMutableArray *items = [[NSMutableArray alloc] init];
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    [ASQueue dispatchOnStageQueue:^{
        
        NSDictionary *keys = [self messageKeys:peer_id];
        
        [messageIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            id item = keys[obj];
            
            if(item  != nil) {
                [items addObject:item];
            }
            
        }];
        
        dispatch_async(dqueue, ^{
            complete([items copy]);
        });
        
    }];
    


}

+(void)removeAllItems:(int)peerId {
    
    [ASQueue dispatchOnStageQueue:^{
        [[self messageKeys:peerId] removeAllObjects];
        [[self messageItems:peerId] removeAllObjects];
    }];
    
}

- (NSMutableDictionary *)messageKeys:(int)peer_id {
    
    NSMutableDictionary *messageKeys = self.class.fClassKeys[@(peer_id)];
    
    
    if(messageKeys == nil) {
        messageKeys = [NSMutableDictionary dictionary];
        self.class.fClassKeys[@(peer_id)] = messageKeys;
    }
    
    return messageKeys;
}

- (NSMutableArray *)messageItems:(int)peer_id {
    
    NSMutableArray *messageItems = self.class.fClassItems[@(peer_id)];
    
    
    if(messageItems == nil) {
        messageItems = [NSMutableArray array];
        self.class.fClassItems[@(peer_id)] = messageItems;
    }
    
    return messageItems;
}

+ (NSMutableDictionary *)messageKeys:(int)peer_id {
    
    __block NSMutableDictionary *messageKeys;
    [ASQueue dispatchOnStageQueue:^{
        
        messageKeys = self.fClassKeys[@(peer_id)];
        
        
        if(messageKeys == nil) {
            messageKeys = [NSMutableDictionary dictionary];
            self.fClassKeys[@(peer_id)] = messageKeys;
        }
        
    } synchronous:YES];
    
    return messageKeys;
}

+ (NSMutableArray *)messageItems:(int)peer_id {
    __block NSMutableArray *items;
    
    [ASQueue dispatchOnStageQueue:^{
        
        items = self.fClassItems[@(peer_id)];
        
        if(!items)
        {
            items = [[NSMutableArray alloc] init];
            self.fClassItems[@(peer_id)] = items;
        }
        
    } synchronous:YES];
    
    
    
    return items;
}



-(int)type {
    return HistoryFilterNone;
}

+(int)type {
    return HistoryFilterNone;
}

+(void)drop {
    [ASQueue dispatchOnStageQueue:^{
        [self.fClassItems removeAllObjects];
        [self.fClassItems removeAllObjects];
    }];
    
}

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        classItems = [NSMutableDictionary dictionary];
        
    });
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

    self.request = [RPCRequest sendRequest:[TLAPI_messages_getHistory createWithPeer:[[_controller.controller conversation] inputPeer] offset_id:source_id add_offset:next ||  source_id == 0 ? 0 : -(int)_controller.selectLimit limit:(int)_controller.selectLimit max_id:next ? 0 : INT32_MAX min_id:0] successHandler:^(RPCRequest *request, id response) {
        
        if(callback) {
            callback(response);
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(callback && _controller) {
            callback(nil);
        }
        
    } timeout:10 queue:[ASQueue globalQueue].nativeQueue];
    
}

-(BOOL)confirmHoleWithNext:(BOOL)next {
    return [self holeWithNext:next] && ( next ? [self holeWithNext:next].max_id <= self.controller.max_id : [self holeWithNext:next].max_id > [self holeWithNext:next].max_id);
}

-(int)additionSenderFlags {
    return 0 ;
}

-(TGMessageHole *)holeWithNext:(BOOL)next {
    return next ? _topHole : _botHole;
}

-(void)setHole:(TGMessageHole *)hole withNext:(BOOL)next {
    if(next)
        _topHole = hole;
    else
        _botHole = hole;
}

-(TGMessageHole *)proccessAndGetHoleWithHole:(TGMessageHole *)hole next:(BOOL)next messages:(NSArray *)messages {
    
    TGMessageHole *nHole;
    
    if(hole != nil) {
        
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
        
        
        if(nHole.min_id == nHole.max_id || abs(nHole.min_id - nHole.max_id) == 1) {
           
           [nHole remove];
            nHole = nil;
        } else
            [nHole save];
        
        
    }
    
    return nHole;
}

-(void)dealloc {
    
    
    [self.request cancelRequest];
    self.request = nil;
}

@end
