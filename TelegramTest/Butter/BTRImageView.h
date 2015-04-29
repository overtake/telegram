//
//  BTRImageView.h
//  Butter
//
//  Created by Jonathan Willing on 12/12/12.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//

#import "BTRView.h"
#import "BTRImage.h"

// Equivalent to UIViewContentMode. See "Providing CALayer Content"
// in the Core Animation guide for more information about the modes.
typedef enum {
    BTRViewContentModeScaleToFill,
    BTRViewContentModeScaleAspectFit,
    BTRViewContentModeScaleAspectFill,
    BTRViewContentModeCenter,
    BTRViewContentModeTop,
    BTRViewContentModeBottom,
    BTRViewContentModeLeft,
    BTRViewContentModeRight,
    BTRViewContentModeTopLeft,
    BTRViewContentModeTopRight,
    BTRViewContentModeBottomLeft,
    BTRViewContentModeBottomRight,
} BTRViewContentMode;

// BTRImageView is an extremely lightweight replacement for NSImageView that is based
// off of CALayers. The image layer itself can have a transform directly applied without
// any consequence, as this is a layer-hosting view. BTRImageView can also display animated
// images, such as animated GIFs.
@interface BTRImageView : BTRView

// The dedicated initializer. The bounds of the image view will
// be adjusted to match the size of the image.
- (id)initWithImage:(NSImage *)image;

// The image displayed in the image view.
@property (nonatomic, strong) NSImage *image;

// The transform applied to the image.
@property (nonatomic, assign) CATransform3D transform;

// Add an animation to the image.
- (void) addAnimation:(CAAnimation *)animation forKey:(NSString *)key;

- (void) removeAnimationForKey:(NSString *)key;

- (void) startGifAnimation;
- (void) stopGifAnimation;

-(CALayer *)currentLayer;

// The content mode for the image view. Directly modifies the layer's contentsGravity.
//
// Defaults to BTRViewContentModeScaleToFill.
@property (nonatomic, assign) BTRViewContentMode contentMode;

@end
