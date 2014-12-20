//
//  NSImageCategory.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Category)

- (NSImage *) imageWithInsets:(NSEdgeInsets)insets;


-(CGImageRef)CGImage;


+(NSImage *)imageWithWebpData:(NSData *)data;
+ (NSImage *)imageWithWebP:(NSString *)filePath error:(NSError **)error;

@end
