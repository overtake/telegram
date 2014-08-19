//
//  SearchSeparatorItem.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchSeparatorItem.h"

@implementation SearchSeparatorItem

- (id)initWithOneName:(NSString *)oneName pluralName:(NSString *)pluralName {
    self = [super init];
    if(self) {
        self.oneName = oneName;
        self.pluralName = pluralName;
    }
    return self;
}

- (NSObject *)itemForHash {
    return self.oneName;
}

- (void)setItemCount:(int)itemCount {
    self->_itemCount = itemCount;
}

+ (NSUInteger)hash:(NSString *)object {
    NSString *hashStr = [NSString stringWithFormat:@"separator_%@", object];
    return [hashStr hash];
}

@end
