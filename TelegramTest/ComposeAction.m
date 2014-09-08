//
//  ComposeAction.m
//  Telegram
//
//  Created by keepcoder on 28.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeAction.h"


@implementation ComposeResult

-(id)initWithMultiObjects:(NSArray *)multiObjects {
    if(self = [super init]) {
        _multiObjects = multiObjects;
    }
    
    return self;
}

-(id)initWithSingleObject:(id)singleObject {
    if(self = [super init]) {
        _singleObject = singleObject;
    }
    
    return self;
}


@end

@implementation ComposeAction

-(id)initWithBehaviorClass:(Class)behavior {
    if(self = [super init])
    {
        _behavior = [[behavior alloc] initWithAction:self];
    }
    
    return self;
}

-(id)initWithBehaviorClass:(Class)behavior filter:(NSArray *)filter object:(id)object {
    if(self = [self initWithBehaviorClass:behavior]) {
        _filter = filter;
        _object = object;
    }
    
    return self;
}

@end
