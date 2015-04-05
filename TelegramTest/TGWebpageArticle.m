//
//  TGWebpageArticle.m
//  Telegram
//
//  Created by keepcoder on 05.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageArticle.h"

@implementation TGWebpageArticle

@synthesize size = _size;

-(id)initWithWebPage:(TLWebPage *)webpage {
    
    if(self = [super initWithWebPage:webpage]) {
        
        
    }
    
    return self;
}

-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageArticleContainer");
}

-(void)makeSize:(int)width {
    
    [super makeSize:width];
    
    _size = [super size];
    
    _size.width+=20;
    _size.height+=60;
    
    
}

@end
