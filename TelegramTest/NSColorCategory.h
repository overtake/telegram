//
//  NSColorCategory.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/17/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSColor (Category)

//- (CGColorRef)CGColorNew;

+ (NSColor *)colorWithCGColor:(CGColorRef)CGColor;

@end
