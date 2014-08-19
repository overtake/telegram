//
//  NSEventCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSEventCategory.h"

@implementation NSEvent (Category)

- (BOOL)isLeftMouseButtonClick {
    NSUInteger pressedButtonMask = [NSEvent pressedMouseButtons];
    return ((pressedButtonMask & (1 << 0))) != 0;
}

- (BOOL)isRightMouseButtonClick {
    NSUInteger pressedButtonMask = [NSEvent pressedMouseButtons];
    return ((pressedButtonMask & (1 << 1))) != 0;
}

@end
