//
//  TMImageUtils.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/17/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMImageUtils.h"

@implementation TMImageUtils

+ (NSImage *)roundedImage:(NSImage *)oldImage size:(NSSize)size {
    
    if(!oldImage)
        return oldImage;
    
    CALayer *layer = [CALayer layer];
    NSImage *image = nil;
    @autoreleasepool {
        CGFloat displayScale = [[NSScreen mainScreen] backingScaleFactor];
        
        size.width *= displayScale;
        size.height *= displayScale;
        
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[oldImage TIFFRepresentation], NULL);
        
        if(source != NULL) {
            CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
            CFRelease(source);
            
            [layer setContents:(__bridge id)(maskRef)];
            [layer setFrame:NSMakeRect(0, 0, size.width, size.height)];
            [layer setBounds:NSMakeRect(0, 0, size.width, size.height)];
            [layer setMasksToBounds:YES];
            [layer setCornerRadius:size.width / 2];
            
            CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, [[NSColorSpace genericRGBColorSpace] CGColorSpace], kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
            [layer renderInContext:context];
            
            CGImageRef cgImage = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            
            image = [[NSImage alloc] initWithCGImage:cgImage size:NSMakeSize(size.width * 0.5, size.height * 0.5)];
            CGImageRelease(cgImage);
            CGImageRelease(maskRef);
        }
    }
    
    return image;
}




+ (NSImage *) roundedImageNew:(NSImage *)oldImage size:(NSSize)size {
    NSImage *result = [[NSImage alloc] initWithSize:size];
    [result lockFocus];
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, size.width, size.height)
                                                         xRadius:size.width / 2
                                                         yRadius:size.height / 2];
    [path addClip];
    
    [oldImage drawInRect:NSMakeRect(0, 0, size.width, size.height)
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0];
    
    [result unlockFocus];
    return result;
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@end
