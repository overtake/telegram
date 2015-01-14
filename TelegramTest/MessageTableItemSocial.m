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

@end
