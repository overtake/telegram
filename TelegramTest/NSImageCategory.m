
//
//  NSImageCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSImageCategory.h"
#import "webp/decode.h"
@implementation NSImage (Category)

- (NSImage *) imageWithInsets:(NSEdgeInsets)insets {
    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(self.size.width + insets.left + insets.right, self.size.height + insets.top + insets.bottom)];
    [newImage lockFocus];
    [self drawAtPoint:NSMakePoint(insets.left, insets.bottom) fromRect:NSMakeRect(0, 0, self.size.width, self.size.height) operation:NSCompositeSourceOver fraction:1];
    [newImage unlockFocus];
    return newImage;
}

-(CGImageRef)CGImage {
    NSData * imageData = [self TIFFRepresentation];
    CGImageRef imageRef;
    if(!imageData) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    return imageRef;
}


+ (NSImage *)imageWithWebP:(NSString *)filePath error:(NSError **)error
{
    // If passed `filepath` is invalid, return nil to caller and log error in console
    NSError *dataError = nil;;
    NSData *imgData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&dataError];
    if(dataError != nil) {
        NSLog(@"imageFromWebP: error: %@", dataError.localizedDescription);
        return nil;
    }
    
    // `WebPGetInfo` weill return image width and height
    int width = 0, height = 0;
    if(!WebPGetInfo([imgData bytes], [imgData length], &width, &height)) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Header formatting error." forKey:NSLocalizedDescriptionKey];
        if(error != NULL)
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain", [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:errorDetail];
        return nil;
    }
    
    const struct { int width, height; } targetContextSize = { width, height};
    
    size_t targetBytesPerRow = ((4 * (int)targetContextSize.width) + 15) & (~15);
    
    void *targetMemory = malloc((int)(targetBytesPerRow * targetContextSize.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef targetContext = CGBitmapContextCreate(targetMemory, (int)targetContextSize.width, (int)targetContextSize.height, 8, targetBytesPerRow, colorSpace, bitmapInfo);
    
   
    
    CGColorSpaceRelease(colorSpace);
    
    if (WebPDecodeBGRAInto(imgData.bytes, imgData.length, targetMemory, targetBytesPerRow * targetContextSize.height, targetBytesPerRow) == NULL)
    {
        NSLog(@"error decoding webp");
    }
    
    for (int y = 0; y < targetContextSize.height; y++)
    {
        for (int x = 0; x < targetContextSize.width; x++)
        {
            uint32_t *color = ((uint32_t *)&targetMemory[y * targetBytesPerRow + x * 4]);
            
            uint32_t a = (*color >> 24) & 0xff;
            uint32_t r = ((*color >> 16) & 0xff) * a;
            uint32_t g = ((*color >> 8) & 0xff) * a;
            uint32_t b = (*color & 0xff) * a;
            
            r = (r + 1 + (r >> 8)) >> 8;
            g = (g + 1 + (g >> 8)) >> 8;
            b = (b + 1 + (b >> 8)) >> 8;
            
            *color = (a << 24) | (r << 16) | (g << 8) | b;
        }
        
        for (size_t i = y * targetBytesPerRow + targetContextSize.width * 4; i < (targetBytesPerRow >> 2); i++)
        {
            *((uint32_t *)&targetMemory[i]) = 0;
        }
    }
    
    CGImageRef bitmapImage = CGBitmapContextCreateImage(targetContext);
    NSImage *image = [[NSImage alloc] initWithCGImage:bitmapImage size:NSMakeSize(width, height)];
    CGImageRelease(bitmapImage);
    
    CGContextRelease(targetContext);
    free(targetMemory);
    
    return image;
}





@end
