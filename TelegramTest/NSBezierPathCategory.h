//
//  NSBezierPathCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/4/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface NSBezierPath (BezierPathQuartzUtilities)

- (CGPathRef)quartzPath;

@end
