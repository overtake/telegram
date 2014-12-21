//
//  NSImageCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "webp/encode.h"

@interface NSImage (Category)

- (NSImage *) imageWithInsets:(NSEdgeInsets)insets;


-(CGImageRef)CGImage;


+ (NSImage *)imageWithWebpData:(NSData *)data error:(NSError **)error;
+ (NSImage *)imageWithWebP:(NSString *)filePath error:(NSError **)error;
+ (NSData *)convertToWebP:(NSImage *)image
                  quality:(CGFloat)quality
                   preset:(WebPPreset)preset
              configBlock:(void (^)(WebPConfig *))configBlock
                    error:(NSError **)error;

@end
