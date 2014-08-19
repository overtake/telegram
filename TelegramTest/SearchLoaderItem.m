//
//  SearchLoaderItem.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/13/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchLoaderItem.h"

@implementation SearchLoaderItem

- (NSObject *)itemForHash {
    return self;
}

+ (NSUInteger)hash:(NSObject *)object {
    NSString *hash = [NSString stringWithFormat:@"loader_%@", object];
    return [hash hash];
}

@end
