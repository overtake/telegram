
//
//  TokenItem.m
//  Telegram
//
//  Created by keepcoder on 29.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TokenItem.h"

@implementation TokenItem


-(id)initWithIdentified:(NSUInteger)identifier object:(id)object title:(NSString *)title {
    if(self = [super init]) {
        _identifier = identifier;
        _object = object;
        _title = title;
    }
    
    return self;
}

@end
