//
//  TMImageUtils.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/17/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMImageUtils : NSObject

+ (NSImage *) roundedImage:(NSImage *)oldImage size:(NSSize)size;
+ (NSImage *) roundedImageNew:(NSImage *)oldImage size:(NSSize)size;
@end
