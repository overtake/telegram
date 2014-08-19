
//
//  NSImageCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSImageCategory.h"

@implementation NSImage (Category)

- (NSImage *) imageWithInsets:(NSEdgeInsets)insets {
    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(self.size.width + insets.left + insets.right, self.size.height + insets.top + insets.bottom)];
    [newImage lockFocus];
    [self drawAtPoint:NSMakePoint(insets.left, insets.bottom) fromRect:NSMakeRect(0, 0, self.size.width, self.size.height) operation:NSCompositeSourceOver fraction:1];
    [newImage unlockFocus];
    return newImage;
}

@end
