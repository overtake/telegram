//
//  MCImage.h, BFImage.h
//
//  Created by Drew McCormack on 30/08/10.
//  Improved by Vladislav Alekseev on 01/01/12
//  Copyright (c) 2010 The Mental Faculty. All rights reserved.
//  Copyright (c) 2012 beefon software. All rights reserved.
//

#import "BFImage.h"
#import <AppKit/AppKit.h>

@implementation NSImage (MCStretchableImageExtensions)
- (NSImage *)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(CGFloat)topCapHeight {
    BFEdgeInsets insets = BFEdgeInsetsMake(topCapHeight, leftCapWidth, topCapHeight, leftCapWidth);
    BFImage *newImage = [[BFImage alloc] initWithImage:self insets:insets];
  
#if ! __has_feature(objc_arc)
    return [newImage autorelease];
#else
    return newImage;
#endif
}
- (NSImage *)stretchableImageWithEdgeInsets:(BFEdgeInsets)insets {
    BFImage *newImage = [[BFImage alloc] initWithImage:self insets:insets];
#if ! __has_feature(objc_arc)
    return [newImage autorelease];
#else
    return newImage;
#endif
}
@end

@interface BFImage ()

@property (assign) NSSize cachedImageSize;
@property (retain) NSImage *cachedImage;
@property (retain) NSArray *sliceImages;
@property (assign) BOOL slicing;

@end

@implementation BFImage

@synthesize cachedImageSize = _cachedImageSize;
@synthesize cachedImage = _cachedImage;
@synthesize sliceImages = _sliceImages;
@synthesize slicing = _slicing;
@synthesize stretchInsets = _stretchInsets;

#pragma mark - Init and Dealloc

- (id)initWithImage:(NSImage *)image insets:(BFEdgeInsets)insets {
    self = [super initWithData:[image TIFFRepresentation]];
    if (self) {
        self.stretchInsets = insets;
    }
    return self;
}

- (void)dealloc {
    self.sliceImages = nil;
#if ! __has_feature(objc_arc)
    [_cachedImage release];
#endif
    _cachedImage = nil;
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - Internal Methods

- (NSImage *)sliceFromRect:(NSRect)rect  {
    NSImage *newImage = [[NSImage alloc] initWithSize:rect.size];
    if (newImage.isValid && rect.size.width > 0.0f && rect.size.height > 0.0f) {
        NSRect toRect = rect;
        toRect.origin = NSZeroPoint;
        [newImage lockFocus];
        [self drawInRect:toRect fromRect:rect operation:NSCompositeCopy fraction:1.0f];
        [newImage unlockFocus];        
    }
#if ! __has_feature(objc_arc)
    return [newImage autorelease];
#else
    return newImage;
#endif
}

- (void)setSliceImages:(NSArray *)sliceImages {
    @synchronized(self) {
        if (_sliceImages == sliceImages) {
            return;
        }
#if ! __has_feature(objc_arc)
        [_sliceImages autorelease];
        _sliceImages = [sliceImages retain];
#else
        _sliceImages = sliceImages;
#endif
    }
}

- (NSArray *)sliceImages {
    @synchronized(self) {
        if (_sliceImages == nil) {
            self.slicing = YES;
            
            CGFloat leftCapWidth = self.stretchInsets.left;
            CGFloat topCapHeight = self.stretchInsets.top;
            CGFloat rightCapWidth = self.stretchInsets.right;
            CGFloat bottomCapHeight = self.stretchInsets.bottom;
            
            CGSize centerSize = CGSizeMake(self.size.width - leftCapWidth - rightCapWidth, self.size.height - topCapHeight - bottomCapHeight);
            
            NSImage *topLeft = [self sliceFromRect:NSMakeRect(0.0f, self.size.height - topCapHeight, leftCapWidth, topCapHeight)];
            NSImage *topEdge = [self sliceFromRect:NSMakeRect(leftCapWidth, self.size.height - topCapHeight, centerSize.width, topCapHeight)];
            NSImage *topRight = [self sliceFromRect:NSMakeRect(self.size.width - rightCapWidth, self.size.height - topCapHeight, rightCapWidth, topCapHeight)];
            
            NSImage *leftEdge = [self sliceFromRect:NSMakeRect(0.0f, bottomCapHeight, leftCapWidth, centerSize.height)];
            NSImage *center = [self sliceFromRect:NSMakeRect(leftCapWidth, bottomCapHeight, centerSize.width, centerSize.height)];
            NSImage *rightEdge = [self sliceFromRect:NSMakeRect(self.size.width - rightCapWidth, bottomCapHeight, rightCapWidth, centerSize.height)];
            
            NSImage *bottomLeft = [self sliceFromRect:NSMakeRect(0.0f, 0.0f, leftCapWidth, bottomCapHeight)];
            NSImage *bottomEdge = [self sliceFromRect:NSMakeRect(leftCapWidth, 0.0f, centerSize.width, bottomCapHeight)];
            NSImage *bottomRight = [self sliceFromRect:NSMakeRect(self.size.width - rightCapWidth, 0.0f, rightCapWidth, bottomCapHeight)];
            
            NSArray *slices = [NSArray arrayWithObjects:topLeft, topEdge, topRight, leftEdge, center, rightEdge, bottomLeft, bottomEdge, bottomRight, nil];
          
#if ! __has_feature(objc_arc)
            _sliceImages = [slices retain];
#else
            _sliceImages = slices;
#endif
          
            self.slicing = NO;
        }
#if ! __has_feature(objc_arc)
        return [[_sliceImages retain] autorelease];
#else
        return _sliceImages;
#endif
    }
}

#pragma mark - Slices Drawing

- (void)drawInRect:(NSRect)dstSpacePortionRect fromRect:(NSRect)srcSpacePortionRect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha respectFlipped:(BOOL)respectContextIsFlipped hints:(NSDictionary *)hints {
    if (self.slicing) {
        [super drawInRect:dstSpacePortionRect fromRect:srcSpacePortionRect operation:op fraction:requestedAlpha respectFlipped:respectContextIsFlipped hints:hints];
        return;
    }
    
    if (!NSEqualSizes(self.cachedImageSize, dstSpacePortionRect.size)) {
        self.cachedImage = nil;
        self.cachedImageSize = dstSpacePortionRect.size;
    }
    else if (self.cachedImage) {
        [self.cachedImage drawInRect:NSMakeRect(0, 0, self.cachedImageSize.width, self.cachedImageSize.height)
                            fromRect:NSZeroRect
                           operation:NSCompositeSourceOver
                            fraction:1.0];
        return;
    }
    
    NSArray *slices = [self sliceImages];
    
    NSImage *imageToCache = [[NSImage alloc] initWithSize:self.cachedImageSize];
    [imageToCache lockFocus];
    NSDrawNinePartImage(dstSpacePortionRect, 
                        [slices objectAtIndex:0], 
                        [slices objectAtIndex:1],
                        [slices objectAtIndex:2],
                        [slices objectAtIndex:3],
                        [slices objectAtIndex:4],
                        [slices objectAtIndex:5],
                        [slices objectAtIndex:6],
                        [slices objectAtIndex:7],
                        [slices objectAtIndex:8],
                        NSCompositeSourceOver, 1.0f, NO);
    [imageToCache unlockFocus];
  
#if ! __has_feature(objc_arc)
    self.cachedImage = [imageToCache autorelease];
#else
    self.cachedImage = imageToCache;
#endif
    
    [self.cachedImage drawInRect:NSMakeRect(0, 0, self.cachedImageSize.width, self.cachedImageSize.height)
                        fromRect:NSZeroRect
                       operation:NSCompositeSourceOver
                        fraction:1.0];
}

- (void)drawInRect:(NSRect)rect {
    if (self.slicing) {
        [super drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        return;
    }
    NSArray *slices = self.sliceImages;
    NSDrawNinePartImage(rect, 
                        [slices objectAtIndex:0], 
                        [slices objectAtIndex:1],
                        [slices objectAtIndex:2],
                        [slices objectAtIndex:3],
                        [slices objectAtIndex:4],
                        [slices objectAtIndex:5],
                        [slices objectAtIndex:6],
                        [slices objectAtIndex:7],
                        [slices objectAtIndex:8],
                        NSCompositeSourceOver, 1.0f, NO);
}

@end
