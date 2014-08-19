//
//  NSImageView+Extends.m
//  Messenger for Telegram
//
//  Created by keepcoder on 31.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSImageViewCategory.h"

@implementation NSImageView (Category)

DYNAMIC_PROPERTY(DCallback);

- (void)mouseDown:(NSEvent *)theEvent {
    
    void  (^callback)(void) = [self getDCallback];
    
    if(callback) {
        callback();
        return;
    }
    
    [super mouseDown:theEvent];
}

- (void)setCallback:(void (^)(void))callback {
    [self setDCallback:callback];
}



@end
