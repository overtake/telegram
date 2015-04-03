//
//  TGWebpageIGObject.m
//  Telegram
//
//  Created by keepcoder on 02.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageIGObject.h"

@implementation TGWebpageIGObject

@synthesize size = _size;

-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageIGContainer");
}

-(id)initWithWebPage:(TLWebPage *)webpage {
    if(self = [super initWithWebPage:webpage]) {
        
    }
    
    return self;
}


-(void)makeSize:(int)width {
    
    [super makeSize:width];
    
    _size = [super size];
    
    
}

-(NSImage *)siteIcon {
    return image_WebpageInstagramIcon();
}

@end
