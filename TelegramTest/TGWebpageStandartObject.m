//
//  TGWebpageStandartObject.m
//  Telegram
//
//  Created by keepcoder on 02.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageStandartObject.h"

@implementation TGWebpageStandartObject

@synthesize size = _size;


-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageStandartContainer");
}

-(void)makeSize:(int)width {
    
    [super makeSize:width];
    
    _size = [super size];
    
}

@end
