//
//  TMImageCache.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/19/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMImageManager.h"
#include <vector>
#include <string>
@interface TMImageManager()
@property std::vector<std::string> *cacheDisk;
@property (strong, nonatomic) NSCache *cacheMemory;
@end

@implementation TMImageManager

+ (TMImageManager *)instance {
    static TMImageManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TMImageManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        self.cacheDisk = new std::vector<std::string>;

        self.cacheMemory = [[NSCache alloc] init];
        [self.cacheMemory setCountLimit:200];
        [self.cacheMemory setTotalCostLimit:1500000];
    }
    return self;
}

- (void)dealloc {
    delete self.cacheDisk;
}

- (NSImage *) getImageFromCache:(TLFileLocation*)location {
    return [self getImageFromCache:location round:0];
}

- (NSImage *) getImageFromCache:(TLFileLocation*)location round:(int)roundSize {
    __block NSImage *imageCache = nil;
    runOnMainQueueWithoutDeadlocking(^{
        
        NSString *hashString = [NSString stringWithFormat:@"%lu_%d_%lu", location.volume_id, location.local_id, location.secret];
        
        if(!roundSize) {
            imageCache = [self.cacheMemory objectForKey:hashString];
        } else {
             NSString *hashStringRound = [NSString stringWithFormat:@"%lu_%d_%lu_%d", location.volume_id, location.local_id, location.secret, roundSize];
            imageCache = [self.cacheMemory objectForKey:hashStringRound];
            if(imageCache)
                return;
            
            imageCache = [self.cacheMemory objectForKey:hashString];
            if(imageCache) {
                imageCache = [self createRoundImageFromImage:imageCache roundSize:roundSize hash:hashStringRound];
                return;
            } else {
                std::string hashStringSTD = std::string([hashString UTF8String]);
                if(std::find(self.cacheDisk->begin(), self.cacheDisk->end(), hashStringSTD) != self.cacheDisk->end()) {
                    
                }
            }
            
        }
    });
    return imageCache;
}

- (NSImage *) createRoundImageFromImage:(NSImage*)image roundSize:(int)roundSize hash:(NSString*)hashStringRound {
    NSImage *imageCache = [self roundCornersImageCornerRadius:roundSize image:image];
    [self.cacheMemory setObject:imageCache forKey:hashStringRound];
    return imageCache;
}

- (NSImage *) tryToLoadFromFile {
    return nil;
}

void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) {
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
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

- (NSImage *)roundCornersImageCornerRadius:(NSInteger)radius image:(NSImage*)image {
//    int w = (int) image.size.width;
//    int h = (int) image.size.height;
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
//    
//    CGContextBeginPath(context);
//    CGRect rect = CGRectMake(0, 0, w, h);
//    addRoundedRectToPath(context, rect, radius, radius);
//    CGContextClosePath(context);
//    CGContextClip(context);
//    
//    CGImageRef cgImage = [[NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]] CGImage];
//    
//    CGContextDrawImage(context, CGRectMake(0, 0, w, h), cgImage);
//    
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
    
//    NSImage *tmpImage = [[NSImage alloc] initWithCGImage:imageMasked size:image.size];
//    NSData *imageData = [tmpImage TIFFRepresentation];
//    NSImage *newImage = [[NSImage alloc] initWithData:imageData];
    return nil;
//    return newImage;
}

void runOnMainQueueWithoutDeadlocking(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
