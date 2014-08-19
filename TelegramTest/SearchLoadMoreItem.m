//
//  SearchLoadMoreItem.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchLoadMoreItem.h"

@implementation SearchLoadMoreItem

- (NSObject *)itemForHash {
    return self;
}

+ (NSUInteger)hash:(NSObject *)object {
    NSString *hash = [NSString stringWithFormat:@"more_%@", object];
    return [hash hash];
}

@end
