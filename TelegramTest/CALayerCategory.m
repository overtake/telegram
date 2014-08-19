//
//  CALayerCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "CALayerCategory.h"

@implementation CALayer (Category)

- (void)disableActions {
    self.actions = @{
                 @"onOrderIn": [NSNull null],
                 @"onOrderOut": [NSNull null],
                 @"sublayers": [NSNull null],
                 @"contents": [NSNull null],
                 @"bounds": [NSNull null],
                 @"position": [NSNull null],
                 @"color": [NSNull null],
                 @"foregroundColor": [NSNull null],
//                 @""
                 };
    
}

- (void)setNormalContentScale {
    self.contentsScale = [[NSScreen mainScreen] backingScaleFactor];
}

- (void)setFrameSize:(CGSize)size {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

- (void)setFrameOrigin:(CGPoint)point {
    self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
}

@end
