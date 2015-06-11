//
//  TGHelpPopover.m
//  Telegram
//
//  Created by keepcoder on 28.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGHelpPopup.h"

@implementation TGHelpPopup


static TMMenuPopover *popover;
static Class classSetter;

+(TMMenuPopover *)popover {
    return popover;
}

+(void)setPopover:(TMMenuPopover *)p {
    popover = p;
    classSetter = [self class];
}

+(BOOL)isVisibility {
    return [popover isShown];
    
}

+(void)performSelected {
    if([self class] == classSetter)
        [popover.contentViewController performSelected];
}

+(void)selectNext {
    if([self class] == classSetter)
        [popover.contentViewController selectNext];
}

+(void)selectPrev {
    if([self class] == classSetter)
        [popover.contentViewController selectPrev];
}

+(void)close {
    [popover close];
    [self setPopover:nil];
    classSetter = [NSNull class];
}


@end
