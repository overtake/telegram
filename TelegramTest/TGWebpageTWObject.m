//
//  TGWebpageTWObject.m
//  Telegram
//
//  Created by keepcoder on 02.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageTWObject.h"

@implementation TGWebpageTWObject

@synthesize size = _size;
-(id)initWithWebPage:(TLWebPage *)webpage {
    if(self = [super initWithWebPage:webpage]) {
        
        
    }
    
    return self;
}

-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageTWContainer");
}

-(void)makeSize:(int)width {
    
    [super makeSize:width];
    
    _size = [super size];
    
}


-(NSImage *)siteIcon  {
    return image_WebpageTwitterIcon();
}

@end
