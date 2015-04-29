//
//  MessageTableItemTyping.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/3/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemTyping.h"

@implementation MessageTableItemTyping

- (id) init {
    self = [super init];
    if(self) {
        self.viewSize = NSMakeSize(0, 22);
    }
    return self;
}

@end
