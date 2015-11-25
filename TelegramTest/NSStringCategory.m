
//
//  NSStringCategory.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSStringCategory.h"

@implementation NSString (Category)

+ (NSString *) randStringWithLength: (int) len {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return [NSString stringWithFormat:@"%@", randomString];
}

- (NSString *) md5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (int) strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return [NSString stringWithFormat:@"%@", output];
}

+ (NSString *) durationTransformedValue:(int) elapsedSeconds {
    NSUInteger h = elapsedSeconds / 3600;
    NSUInteger m = (elapsedSeconds / 60) % 60;
    NSUInteger s = elapsedSeconds % 60;
    
    NSString *formattedTime = nil;
    if(h) {
        formattedTime = [NSString stringWithFormat:@"%ld:%02ld:%02ld", h, m, s];
    } else {
        formattedTime = [NSString stringWithFormat:@"%02ld:%02ld", m, s];
    }
    
    return formattedTime;
}

+ (NSString *) sizeToTransformedValue:(NSUInteger)value {
    double convertedValue = value / 1.0;
    int multiplyFactor = 0;

    NSArray *tokens = [NSArray arrayWithObjects:@"Bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }

    return [NSString stringWithFormat:@"%4.2f %@", convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

+ (NSString *) sizeToTransformedValuePretty:(int)value {
    double convertedValue = value / 1.0;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"Bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.0f %@", convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

- (NSString *)stringByDecodingURLFormat
{
    NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

+ (NSString *) md5String:(NSString *)string {
    return [string md5];
}



@end
