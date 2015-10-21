//
//  NSStringCategory.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (Category)

+ (NSString *) randStringWithLength: (int) len;

- (NSString *) md5;

+ (NSString *) md5String:(NSString *)string;

+ (NSString *) sizeToTransformedValue:(NSUInteger)value;
+ (NSString *) durationTransformedValue:(int) elapsedSeconds;
+ (NSString *) sizeToTransformedValuePretty:(int)value;
- (NSString *)stringByDecodingURLFormat;

+(NSRange)selectRange:(NSPoint)point frameSize:(NSSize)size;

@end
