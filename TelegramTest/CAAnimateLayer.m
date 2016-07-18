//
//  CAAnimateLayer.m
//  Telegram
//
//  Created by keepcoder on 18/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "CAAnimateLayer.h"

@implementation CAAnimateLayer

-(id<CAAction>)actionForKey:(NSString *)event {
    CAAnimation *anim = nil;
    
    if ([event isEqualToString:kCAOnOrderOut])
    {
        anim = [TMAnimations fadeWithDuration:0.1 fromValue:1.0f toValue:0.0f];
    }
    
    return anim;
}



@end
