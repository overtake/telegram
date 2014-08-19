//
//  TMTextLayer.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/3/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface TMTextLayer : CATextLayer

@property (nonatomic, strong) NSFont *textFont;
@property (nonatomic, strong) NSColor *textColor;

- (NSSize)size;
- (void)sizeToFit;

@end
