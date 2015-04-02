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

-(id)initWithWebPage:(TLWebPage *)webpage {
    
    if([webpage.type isEqualToString:@"photo"]) {
        webpage.n_description = nil;
        webpage.title = nil;
        webpage.author = nil;
        webpage.date = 0;
    }
    
    if(self = [super initWithWebPage:webpage]) {
        

    }
    
    return self;
}

-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageStandartContainer");
}

-(void)makeSize:(int)width {
    
    [super makeSize:width];
    
    _size = [super size];
    
}

@end
