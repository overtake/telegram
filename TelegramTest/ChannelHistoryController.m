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

#import "ChannelImportantFilter.h"
#import "ChannelFilter.h"
@interface ChannelHistoryController () <TGChannelPollingDelegate>
@property (nonatomic,assign) BOOL pollingIsStarted;
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
            
            _pollingIsStarted = NO;
            
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
            
            NSArray *items = [self.controller messageTableItemsFromMessages:result];
            
            
            NSArray *converted = [self filterAndAdd:items isLates:NO];
            
            
            converted = [self sortItems:converted];
            
            [self setState:state next:next];
            
            [self performCallback:selectHandler result:converted range:NSMakeRange(0, converted.count)];
            
            [channelPolling checkInvalidatedMessages:converted important:[self.filter isKindOfClass:[ChannelImportantFilter class]]];
            
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
    
    if(hole != nil) {
        if([self selectAllItems].count > 0) {
            TL_localMessageService *service = [TL_localMessageService createWithHole:hole];
            
            NSArray *converted = [self filterAndAdd:[self.controller messageTableItemsFromMessages:@[service]] isLates:NO];
            
            converted = [self sortItems:converted];
            
            [ASQueue dispatchOnMainQueue:^{
                
                [self.controller receivedMessageList:converted inRange:NSMakeRange(0, converted.count) itsSelf:NO];
                
            }];
        } else {
            
            [ASQueue dispatchOnMainQueue:^{
                [self.controller flushMessages];
                [self removeAllItems];
                
                [self.controller jumpToLastMessages:YES];
            }];
            
        }
    }
    
    
    
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



-(void)loadAroundMessagesWithMessage:(MessageTableItem *)item limit:(int)limit selectHandler:(selectHandler)selectHandler {
    
    
    [self.queue dispatchOnQueue:^{
        
        [self addItemWithoutSavingState:item];
    
        [[Storage manager] addHolesAroundMessage:item.message];
        
        [[Storage manager] insertMessage:item.message];
        
        NSMutableArray *prevResult = [NSMutableArray array];
        NSMutableArray *nextResult = [NSMutableArray array];
        
        self.proccessing = YES;
        [self loadAroundMessagesWithSelectHandler:selectHandler limit:(int)limit prevResult:prevResult nextResult:nextResult];
        
      
    } synchronous:YES];
    
    
}

-(void)loadAroundMessagesWithSelectHandler:(selectHandler)selectHandler limit:(int)limit prevResult:(NSMutableArray *)prevResult nextResult:(NSMutableArray *)nextResult {
    
    
    BOOL nextLoaded = nextResult.count >= limit/2 || self.nextState == ChatHistoryStateFull;
    BOOL prevLoaded = prevResult.count >= limit/2 || self.prevState == ChatHistoryStateFull;
    
    
    if(nextLoaded && prevLoaded) {
        
        NSArray *result = [self selectAllItems];
        
        [self performCallback:selectHandler result:result range:NSMakeRange(0, result.count)];

        [channelPolling checkInvalidatedMessages:result important:[self.filter isKindOfClass:[ChannelImportantFilter class]]];
        
        self.proccessing = NO;
        return;
    }
    
    BOOL nextRequest = prevLoaded;
    
    
    
    [self.filter request:nextRequest callback:^(NSArray *result, ChatHistoryState state) {
        
        NSArray *items = [self.controller messageTableItemsFromMessages:result];
        
        NSArray *converted = [self filterAndAdd:items isLates:NO];
        
        converted = [self sortItems:converted];
        
        if(nextRequest) {
            [nextResult addObjectsFromArray:converted];
        } else {
            [prevResult addObjectsFromArray:converted];
        }
        
        
        [self setState:state next:nextRequest];
        
    
        [self loadAroundMessagesWithSelectHandler:selectHandler limit:(int)limit prevResult:prevResult nextResult:nextResult];
        
    }];
    
}



-(void)pollingReceivedUpdates:(id)updates endPts:(int)pts {
    
}



-(void)startChannelPolling {
    
    if(!channelPolling.isActive) {
        [channelPolling start];
        _pollingIsStarted = YES;
    }
}

-(void)startChannelPollingIfAlreadyStoped {
    if(!channelPolling.isActive && _pollingIsStarted) {
        [channelPolling start];
    }
}

-(void)stopChannelPolling {
    [channelPolling stop];
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
    
    return lastObject.message.date ;
    
}



-(int)max_id {
    
    NSArray *allItems = [self selectAllItems];
    
    
    if(allItems.count == 0)
        return self.conversation.last_marked_message;
    
    
    
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
        return self.conversation.last_marked_date;
    
    __block MessageTableItem *firstObject;
    
    [allItems enumerateObjectsWithOptions:0 usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.message.n_id > 0)
        {
            firstObject = obj;
            *stop = YES;
        }
        
    }];
    
    return firstObject.message.date;
}

-(int)server_max_id {
    
    NSArray *allItems = [self selectAllItems];
    
    
    __block int msgId;
    
    [allItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        
        if(((MessageTableItem *)allItems[0]).message.n_id && ((MessageTableItem *)allItems[0]).message.n_id < 0 && ((MessageTableItem *)allItems[0]).message.hole.date == INT32_MAX) {
            msgId = ((MessageTableItem *)allItems[0]).message.hole.max_id;
            *stop = YES;
            return;
        }
        
        if(obj.message.n_id > 0 && obj.message.n_id < TGMINFAKEID)
        {
            msgId = obj.message.n_id;
            *stop = YES;
        }
        
    }];
    
    return msgId;
    
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
    
    [super drop:YES];
}

-(void)dealloc {
    [channelPolling stop];
}


@end
