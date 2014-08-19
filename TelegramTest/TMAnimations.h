//
//  TMAnimations.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/6/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMAnimations : NSObject

+ (CAAnimation *)fadeWithDuration:(float)duration fromValue:(float)fromValue toValue:(float)toValue;
+ (CAAnimation *)shakeWithDuration:(float)duration fromValue:(CGPoint)fromValue toValue:(CGPoint)toValue;
+ (CAAnimation *)postionWithDuration:(float)duration fromValue:(CGPoint)fromValue toValue:(CGPoint)toValue;

+ (CAAnimation *)resizeLayer:(CALayer*)layer to:(CGSize)size;

@end
