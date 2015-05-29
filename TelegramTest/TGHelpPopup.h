//
//  TGHelpPopover.h
//  Telegram
//
//  Created by keepcoder on 28.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGHelpPopup : NSObject

+(TMMenuPopover *)popover;
+(void)setPopover:(TMMenuPopover *)popover;

+(BOOL)isVisibility;

+(void)selectNext;
+(void)selectPrev;

+(void)performSelected;

+(void)close;

@end
