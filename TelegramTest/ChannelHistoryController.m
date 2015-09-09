//
//  ChannelHistoryController.m
//  Telegram
//
//  Created by keepcoder on 08.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelHistoryController.h"
#import "MessageTableItem.h"
@implementation ChannelHistoryController



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
        
    }];
    
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


@end
