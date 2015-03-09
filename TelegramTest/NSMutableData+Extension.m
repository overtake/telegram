//
//  NSMutableData+Extension.m
//  TelegramTest
//
//  Created by keepcoder on 06.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "NSMutableData+Extension.h"

@implementation NSMutableData (Extension)

-(id)initWithRandomBytes:(int)length {
    if (self = [super init]) {
        [self addRandomBytes:length];
    }
    return self;
}
-(void)addRandomBytes:(int)length {
    for( unsigned int i = 0 ; i < length ; ++i )
    {
        u_int32_t randomBits = arc4random();
        [self appendBytes:&randomBits length:1];
    }
    
}

-(NSMutableData *)addPadding:(int)bits {

    [self addRandomBytes:(bits - self.length % bits) % bits];
    return self;
}
@end
