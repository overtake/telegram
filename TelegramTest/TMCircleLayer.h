//
//  TMCircleLayer.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/4/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface TMCircleLayer : CALayer

@property (nonatomic) float radius;
@property (nonatomic) float lineWidth;
@property (nonatomic, strong) NSColor *fillColor;
@property (nonatomic, strong) NSColor *strokeColor;

@end
