//
//  ChannelHistoryController.m
//  Telegram
//
//  Created by keepcoder on 08.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelHistoryController.h"
#import "MessageTableItem.h"
#import "TGChannelsPolling.h"


@interface ChannelHistoryController () <TGChannelPollingDelegate>

@end

@implementation ChannelHistoryController


static TGChannelsPolling *channelPolling;

-(id)initWithController:(id<MessagesDelegate>)controller historyFilter:(Class)historyFilter {
    if(self = [super initWithController:controller historyFilter:historyFilter]) {
        
        
        [self.queue dispatchOnQueue:^{
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                channelPolling = [[TGChannelsPolling alloc] initWithDelegate:self withUpdatesLimit:3];
                
            });
            
            [channelPolling setDelegate:self];
            [channelPolling setCurrentConversation:controller.conversation];
            
            
        } synchronous:YES];
        
    }
    
    return self;
}


-(void)request:(BOOL)next anotherSource:(BOOL)anotherSource sync:(BOOL)sync selectHandler:(selectHandler)selectHandler {
    
    [self.queue dispatchOnQueue:^{
        
        if([self checkState:ChatHistoryStateFull next:next] || self.isProccessing) {
            return;
        }
        
        
        self.proccessing = YES;
        
        [self.filter request:next callback:^(NSArray *result, ChatHistoryState state) {
            
            [TGProccessUpdates checkAndLoadIfNeededSupportMessages:result asyncCompletionHandler:^{
                
                
                NSArray *items = [self.controller messageTableItemsFromMessages:result];
                
                
                NSArray *converted = [self filterAndAdd:items isLates:NO];
                
                
                converted = [self sortItems:converted];
                
                [self setState:state next:next];
                
                
                
                [self performCallback:selectHandler result:converted range:NSMakeRange(0, converted.count)];
                
            }];
            
        }];
        
    } synchronous:sync];
    
}

-(void)setFilter:(HistoryFilter *)filter {
    
    [self.queue dispatchOnQueue:^{
        [self removeAllItems];
        [super setFilter:filter];
    }];
    
    

}

-(void)pollingDidSaidTooLongWithHole:(TGMessageHole *)hole {
    
    TL_localMessageService *service = [TL_localMessageService createWithHole:hole];
    
    NSArray *converted = [self filterAndAdd:[self.controller messageTableItemsFromMessages:@[service]] isLates:NO];
    
    converted = [self sortItems:converted];
    
    [ASQueue dispatchOnMainQueue:^{

         [self.controller receivedMessageList:converted inRange:NSMakeRange(0, converted.count) itsSelf:NO];
                    
    }];
    
    
    // add new holes after received too long update.
    
//     [self setState:ChatHistoryStateLocal next:NO];
//    
//    
//    [self removeAllItems];
//    
//    self.proccessing = YES;
//    
//    [self.filter request:YES callback:^(id response, ChatHistoryState state) {
//        
//        NSArray *converted = [self filterAndAdd:[self.controller messageTableItemsFromMessages:response] isLates:NO];
//        
//        converted = [self sortItems:converted];
//        
//        [self setState:self.filter.hole.max_id != INT32_MAX ? ChatHistoryStateFull : ChatHistoryStateLocal next:NO];
//        
//        [ASQueue dispatchOnMainQueue:^{
//            
//            self.proccessing = NO;
//            
//            [self.controller flushMessages];
//            
//            
//            [self.controller receivedMessageList:converted inRange:NSMakeRange(0, converted.count) itsSelf:NO];
//            
//        }];
//        
//        
//        
//    }];
//    
    
}



-(void)pollingReceivedUpdates:(id)updates endPts:(int)pts {
    
}



-(void)startChannelPolling {
    [channelPolling start];
}




-(int)min_id {
    
    NSArray *allItems = [self selectAllItems];
    
    if(allItems.count == 0)
        return 0;
    
    
    __block MessageTableItem *lastObject;
    
    [allItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.message.n_id > 0)
        {
            lastObject = obj;
            *stop = YES;
        }
        
    }];
    
    return lastObject.message.n_id;
    
}

-(int)minDate {
    NSArray *allItems = [self selectAllItems];
    
    if(allItems.count == 0)
        return 0;
    
    
    __block MessageTableItem *lastObject;
    
    [allItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.message.n_id > 0)
        {
            lastObject = obj;
            *stop = YES;
        }
        
    }];
    
    return lastObject.message.date - 1;
    
}



-(int)max_id {
    
    NSArray *allItems = [self selectAllItems];
    
    
    if(allItems.count == 0)
        return INT32_MAX;
    
    
    
    __block MessageTableItem *firstObject;
    
    [allItems enumerateObjectsWithOptions:0 usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.message.n_id > 0)
        {
            firstObject = obj;
            *stop = YES;
        }
        
    }];
    
    return firstObject.message.n_id;
}

-(int)maxDate {
    NSArray *allItems = [self selectAllItems];
    
    if(allItems.count == 0)
        return INT32_MAX;
    
    __block MessageTableItem *firstObject;
    
    [allItems enumerateObjectsWithOptions:0 usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.message.n_id > 0)
        {
            firstObject = obj;
            *stop = YES;
        }
        
    }];
    
    return firstObject.message.date + 1;
}

-(int)server_max_id {
    
    NSArray *allItems = [self selectAllItems];
    
    
    __block MessageTableItem *item;
    
    [allItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.message.n_id > 0 && obj.message.n_id < TGMINFAKEID)
        {
            item = obj;
            *stop = YES;
        }
        
    }];
    
    return item.message.n_id;
    
}

-(int)server_min_id {
    
    NSArray *allItems = [self selectAllItems];
    
    
    __block MessageTableItem *item;
    
    [allItems enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.message.n_id > 0 && obj.message.n_id < TGMINFAKEID)
        {
            item = obj;
            *stop = YES;
        }
        
    }];
    
    return item.message.n_id;
    
}

-(void)drop:(BOOL)dropMemory {
    
    [channelPolling stop];
    
    
    [super drop:YES];
}



@end
