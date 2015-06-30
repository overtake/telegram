//
//  SearchHistoryFilter.m
//  Telegram
//
//  Created by keepcoder on 20.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchHistoryFilter.h"

@implementation SearchHistoryFilter


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

- (NSMutableDictionary *)messageKeys:(int)peer_id {
    return [[self class] messageKeys:peer_id];
}

- (NSMutableArray *)messageItems:(int)peer_id {
    return [[self class] messageItems:peer_id];
}

+ (NSMutableDictionary *)messageKeys:(int)peer_id {
    NSMutableDictionary *keys = messageKeys[@(peer_id)];
    
    if(!keys)
    {
        keys = [[NSMutableDictionary alloc] init];
        messageKeys[@(peer_id)] = keys;
    }
    
    return keys;
}

+ (NSMutableArray *)messageItems:(int)peer_id {
    NSMutableArray *items = messageItems[@(peer_id)];
    
    if(!items)
    {
        items = [[NSMutableArray alloc] init];
        messageItems[@(peer_id)] = items;
    }
    
    return items;
}



-(int)type {
    return HistoryFilterSearch;
}

+(int)type {
    return HistoryFilterSearch;
}
@end
