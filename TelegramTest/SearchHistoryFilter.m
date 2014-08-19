//
//  SearchHistoryFilter.m
//  Telegram
//
//  Created by keepcoder on 20.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchHistoryFilter.h"

@implementation SearchHistoryFilter


static NSMutableArray * messageItems;
static NSMutableDictionary * messageKeys;

-(id)initWithController:(ChatHistoryController *)controller {
    if(self = [super initWithController:controller]) {
       
    }
    
    return self;
}


+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messageItems = [[NSMutableArray alloc] init];
        messageKeys = [[NSMutableDictionary alloc] init];
        
    });
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



-(int)type {
    return HistoryFilterSearch;
}

+(int)type {
    return HistoryFilterSearch;
}
@end
