//
//  MessageTableItemSocial.m
//  Telegram
//
//  Created by keepcoder on 03.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemSocial.h"

@implementation MessageTableItemSocial


-(id)initWithObject:(TL_localMessage *)object socialClass:(Class)socialClass {
    if(self = [super initWithObject:object]) {
        
        _social = [[socialClass alloc] initWithSocialURL:object.message item:self];
        
        self.blockSize = NSMakeSize(250, 150);
        
        self.viewSize = self.blockSize;
        
        
       
        
    }
    
    return self;
}

-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    self.blockSize = NSMakeSize(MIN(250,width - 20), MAX( MIN(250,width - 20) - 80, 60));
        
    return YES;
}

@end
