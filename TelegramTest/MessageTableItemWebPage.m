//
//  MessageTableItemWebPage.m
//  Telegram
//
//  Created by keepcoder on 26.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "MessageTableItemWebPage.h"

@implementation MessageTableItemWebPage

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        
        
        self.blockSize = NSMakeSize(200, 200);
        
        [self updateWebPage];
    }
    
    return self;
}


-(void)updateWebPage {
    
    
    
}

@end
