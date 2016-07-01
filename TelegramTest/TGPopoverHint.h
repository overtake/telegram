//
//  TGPopoverHint.h
//  Telegram
//
//  Created by keepcoder on 01/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGMessagesHintView.h"
@interface TGPopoverHint : NSObject

+(TGMessagesHintView *)showHintViewForView:(NSView *)view ofRect:(NSRect)rect;

+(void)close;

+(BOOL)isShown;

+(TGMessagesHintView *)hintView;


@end
