//
//  NSViewCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CALayerOpacityAnimation = 1,
    CALayerPositionAnimation = 2
} CALayerAnimations;


@interface NSView (Category)

- (void)setCenterByView:(NSView *)view;

- (CGPoint)center;

- (void)prepareForAnimation;

- (void)setAnimation:(CAAnimation *)anim forKey:(NSString *)key;

@end
