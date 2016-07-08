//
//  SearchLoadMoreItem.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchLoadMoreItem.h"

@implementation SearchLoadMoreItem

-(id)initWithObject:(id)object callback:(void (^)(id item))callback {
    if(self = [super initWithObject:object]) {
        _items = object;
        _callback = callback;
    }
    
    return self;
}

- (NSObject *)itemForHash {
    return self;
}

+ (NSUInteger)hash:(NSObject *)object {
    NSString *hash = [NSString stringWithFormat:@"more_%@", object];
    return [hash hash];
}

-(Class)viewClass {
    return NSClassFromString(@"SearchLoadMoreCell");
}

-(int)height {
    return 40;
}

@end
