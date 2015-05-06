//
//  TMNineImage.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/23/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMNineImage.h"

@implementation NSImage(TMNineImage)

- (TMNineImage*) imageWithNinePoint:(NSPoint)ninePoint {
    return [[TMNineImage alloc] initWithImage:self ninePoint:ninePoint];
}

@end

@interface TMNineImage()
@property (nonatomic, strong) NSImage* originImage;
@property (nonatomic) NSPoint ninePoint;

@property (nonatomic, strong) NSImage *topLeftCorner;
@property (nonatomic, strong) NSImage *topEdgeFill;
@property (nonatomic, strong) NSImage *topRightCorner;

@property (nonatomic, strong) NSImage *leftEdgeFill;
@property (nonatomic, strong) NSImage *centerFill;
@property (nonatomic, strong) NSImage *rightEdgeFill;

@property (nonatomic, strong) NSImage *bottomLeftCorner;
@property (nonatomic, strong) NSImage *bottomEdgeFill;
@property (nonatomic, strong) NSImage *bottomRightCorner;

@property (nonatomic, strong) NSString *colorSpace;

@property (nonatomic) NSSize cacheSize;
@property (nonatomic) float cacheScale;
@property (nonatomic) NSBitmapImageRep *cacheImage;

@property (nonatomic, strong) NSCache *cache;

@end

@implementation TMNineImage

- (id) initWithImage:(NSImage *)image ninePoint:(NSPoint)ninePoint {
    self = [super initWithData:[image TIFFRepresentation]];
    if(self) {
        self.originImage = image;
        self.ninePoint = ninePoint;
        self.cache = [[NSCache alloc] init];
        [self.cache setCountLimit:10];
        [self createNineCopies];
    }
    return self;
}

- (NSImage*) croppedImageWithRect:(NSRect)rect{
    NSImage *subImage = [[NSImage alloc] initWithSize:rect.size];
    NSRect drawRect = NSZeroRect;
    drawRect.size = rect.size;
    [subImage lockFocus];
    [self.originImage drawInRect:drawRect
             fromRect:rect
            operation:NSCompositeSourceOver
             fraction:1.0f];
    [subImage unlockFocus];
    return subImage;
}
//
//- (void)dealloc {
//    self.originImage = nil;
//    self.
//}


- (void) createNineCopies {
    int height = self.originImage.size.height - self.ninePoint.y - 1;
    int width = self.originImage.size.width - self.ninePoint.x - 1;
    
    self.topLeftCorner = [self croppedImageWithRect:NSMakeRect(0, self.ninePoint.y + 1, self.ninePoint.x, height)];
    self.topEdgeFill = [self croppedImageWithRect:NSMakeRect(self.ninePoint.x, self.ninePoint.y + 1, 1, height)];
    self.topRightCorner = [self croppedImageWithRect:NSMakeRect(self.ninePoint.x + 1, self.ninePoint.y + 1, width, height)];
    self.leftEdgeFill = [self croppedImageWithRect:NSMakeRect(0, self.ninePoint.y, self.ninePoint.x, 1)];
        self.centerFill = [self croppedImageWithRect:NSMakeRect(self.ninePoint.x, self.ninePoint.y, 1, 1)];
    self.rightEdgeFill = [self croppedImageWithRect:NSMakeRect(self.ninePoint.x + 1, self.ninePoint.y, width, 1)];
    
    self.bottomLeftCorner = [self croppedImageWithRect:NSMakeRect(0, 0, self.ninePoint.x, self.ninePoint.y)];
    self.bottomEdgeFill = [self croppedImageWithRect:NSMakeRect(self.ninePoint.x, 0, 1, self.ninePoint.y)];
    self.bottomRightCorner = [self croppedImageWithRect:NSMakeRect(self.ninePoint.x + 1, 0, width, self.ninePoint.y)];
    
    self.colorSpace = [[[self.originImage representations] lastObject] colorSpaceName];
}

- (CGFloat) deviceScale:(CGContextRef) context{
    CGSize backingSize = CGContextConvertSizeToDeviceSpace(context, CGSizeMake(1.0f, 1.0f));
    return backingSize.width;
}

- (void) drawInRect:(NSRect)dstSpacePortionRect fromRect:(NSRect)srcSpacePortionRect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha respectFlipped:(BOOL)respectContextIsFlipped hints:(NSDictionary *)hints {
    
//    MTLog(@"dstSpacePortionRect rect %@", NSStringFromRect(dstSpacePortionRect));
    
    //    MTLog(@"draw");
    
    //    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    //
    //    CGSize backingSize = CGContextConvertSizeToDeviceSpace(context, CGSizeMake(1.0f, 1.0f)).width;
    //    return backingSize.width;
    
    float scale = [NSScreen mainScreen].backingScaleFactor;
    
    
    NSString *key = [NSString stringWithFormat:@"%f_%f_%f", dstSpacePortionRect.size.width, dstSpacePortionRect.size.height, scale];
    
    self.cacheImage = [self.cache objectForKey:key];
    
    if(self.cacheImage == nil) {
        //        MTLog(@"new image");
        //        self.cacheSize = dstSpacePortionRect.size;
        //        self.cacheScale = scale;
        self.cacheImage =  [[NSBitmapImageRep alloc]
                            initWithBitmapDataPlanes:NULL
                            pixelsWide:dstSpacePortionRect.size.width * scale
                            pixelsHigh:dstSpacePortionRect.size.height * scale
                            bitsPerSample:8
                            samplesPerPixel:4
                            hasAlpha:YES
                            isPlanar:NO
                            colorSpaceName: self.colorSpace
                            bytesPerRow:0
                            bitsPerPixel:32];
        [self.cacheImage setSize:dstSpacePortionRect.size];
        
        NSGraphicsContext *newContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:self.cacheImage];
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:newContext];
        [[NSColor clearColor] setFill];
        NSRectFill(NSMakeRect(0.0f, 0.0f, dstSpacePortionRect.size.width, dstSpacePortionRect.size.height));
        NSDrawNinePartImage(dstSpacePortionRect, self.topLeftCorner, self.topEdgeFill, self.topRightCorner,
                            self.leftEdgeFill, self.centerFill, self.rightEdgeFill, self.bottomLeftCorner, self.bottomEdgeFill,
                            self.bottomRightCorner, NSCompositeSourceOver, 1.0f, NO);
        [NSGraphicsContext restoreGraphicsState];
        
        if(self.cacheImage)
            [self.cache setObject:self.cacheImage forKey:key];
    }
    
    if(self.cacheImage)
        [self.cacheImage drawInRect:dstSpacePortionRect fromRect:srcSpacePortionRect operation:op fraction:requestedAlpha respectFlipped:respectContextIsFlipped hints:hints];
}

-(void)drawInRect:(NSRect)rect{
    [self drawInRect:rect operation:NSCompositeSourceOver fraction:1.0f];
}

-(void)drawInRect:(NSRect)rect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha{
    [self drawInRect:rect operation:op fraction:requestedAlpha respectFlipped:YES hints:nil];
}
-(void)drawInRect:(NSRect)rect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha respectFlipped:(BOOL)respectContextIsFlipped hints:(NSDictionary *)hints{
    [self drawInRect:rect fromRect:NSZeroRect operation:op fraction:requestedAlpha respectFlipped:YES hints:nil];
}



@end
