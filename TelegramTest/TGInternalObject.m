
//
//  TGInternalObject.m
//  TelegramModern
//
//  Created by keepcoder on 25.06.15.
//  Copyright (c) 2015 telegram. All rights reserved.
//

#import "TGInternalObject.h"

@interface TGInternalObject ()
@property (nonatomic,assign) NSUInteger randomId;
@end

@implementation TGInternalObject

-(instancetype)init {
    if(self = [super init]) {
        _randomId = arc4random();
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    
    
    return self;
}

@end
