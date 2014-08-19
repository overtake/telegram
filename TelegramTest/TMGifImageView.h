//
//  TMGifImageView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/15/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface TMGifImageView : IKImageView

@property (nonatomic) int roundRadius;

- (void)setImage:(NSImage *)image isRounded:(BOOL)isRounded;
- (void)startAnimation;

@end
