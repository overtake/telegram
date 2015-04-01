//
//  TGWebpageTWObject.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageYTObject.h"
#import "TGWebpageYTContainer.h"
@implementation TGWebpageYTObject

@synthesize size = _size;



-(void)makeSize:(int)width {
    
    _size = self.imageObject.imageSize;
    
    
    _size.height+=40;
    
}

-(Class)webpageContainer {
    return [TGWebpageYTContainer class];
}

@end
