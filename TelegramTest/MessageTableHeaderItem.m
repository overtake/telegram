//
//  MessageTableHeaderItem.m
//  Telegram
//
//  Created by keepcoder on 22.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableHeaderItem.h"

@implementation MessageTableHeaderItem


-(id)init {
    if(self = [super init]) {
        self.viewSize = NSMakeSize(0, 300);
    }
    
    return self;
}

@end
