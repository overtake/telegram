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

+(TMMenuPopover *)popover {
    return popover;
}

+(void)setPopover:(TMMenuPopover *)p {
    popover = p;
}

+(BOOL)isVisibility {
    return [popover isShown];
    
}

+(void)performSelected {
    [popover.contentViewController performSelected];
}

+(void)selectNext {
    [popover.contentViewController selectNext];
}

+(void)selectPrev {
    [popover.contentViewController selectPrev];
}

+(void)close {
    [popover close];
    [self setPopover:nil];
}


@end
