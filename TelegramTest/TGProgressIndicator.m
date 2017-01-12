//
//  TGProgressIndicator.m
//  Telegram
//
//  Created by keepcoder on 14.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGProgressIndicator.h"

@interface TGProgressIndicator () {
@private
    BOOL    isAnimating;
}
@end


@implementation TGProgressIndicator

- (void) startAnimation:(id)sender
{
    isAnimating = YES;
    [super startAnimation:sender];
}

- (void) stopAnimation:(id)sender
{
    isAnimating = NO;
    [super stopAnimation:sender];
}



@end
