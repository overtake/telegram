//
//  MCImage.h, BFImage.h
//
//  Created by Drew McCormack on 30/08/10.
//  Improved by Vladislav Alekseev on 01/01/12
//  Copyright (c) 2010 The Mental Faculty. All rights reserved.
//  Copyright (c) 2012 beefon software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct BFEdgeInsets {
    CGFloat top, left, bottom, right;
} BFEdgeInsets;

static inline BFEdgeInsets BFEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
    BFEdgeInsets insets = {top, left, bottom, right};
    return insets;
}

@interface NSImage (MCStretchableImageExtensions)
- (NSImage *)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(CGFloat)topCapHeight;
- (NSImage *)stretchableImageWithEdgeInsets:(BFEdgeInsets)insets;
@end


@interface BFImage : NSImage
- (id)initWithImage:(NSImage *)image insets:(BFEdgeInsets)insets;
@property (assign) BFEdgeInsets stretchInsets;
@end
