//
//  TMFastQueue.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/27/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMFastQueue : NSObject
- (NSView *) popElement;
- (void) push:(NSView *)view;
@end
