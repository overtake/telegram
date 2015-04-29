//
//  BTRImageView.m
//  Butter
//
//  Created by Jonathan Willing on 12/12/12.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//

#import "BTRImageView.h"
#import "BTRGeometryAdditions.h"
#import "BTRImage.h"

@interface BTRImageView()

@property (nonatomic, strong, readwrite) CALayer *imageLayer;
@property (nonatomic, strong) NSTimer *animatedTimer;

@property (nonatomic) BOOL isAnimationRunning;

@property (nonatomic) NSUInteger currentFrame;

@end

@implementation BTRImageView

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame layerHosted:YES];
	if (self == nil)
        return nil;
	BTRImageViewCommonInit(self);
	return self;
}

- (id)initWithImage:(BTRImage *)image {
	self = [self initWithFrame:(CGRect){ .size = image.size }];
	self.image = image;
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil)
        return nil;
	self.layer = [CALayer layer];
	self.wantsLayer = YES;
	BTRImageViewCommonInit(self);
	return self;
}

- (id<CAAction>)actionForLayer:(CALayer *)theLayer
                        forKey:(NSString *)theKey {

    return (id <CAAction>)[NSNull null]; // Prevent the action from animating
}


static void BTRImageViewCommonInit(BTRImageView *self) {
	self.imageLayer = [CALayer layer];
	self.imageLayer.delegate = self;
    
    
    self.imageLayer.actions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"onOrderIn",
     [NSNull null], @"onOrderOut",
     [NSNull null], @"sublayers",
     [NSNull null], @"contents",
     [NSNull null], @"bounds",
     nil];
    
	self.imageLayer.masksToBounds = YES;
	[self.layer addSublayer:self.imageLayer];
	 
    
	self.contentMode = BTRViewContentModeScaleToFill;
	self.imageLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
}

- (void)layout {
	[super layout];
	
	self.imageLayer.bounds = self.bounds;
	self.imageLayer.position = CGPointMake(NSMidX(self.bounds), NSMidY(self.bounds));
}

- (void)setImage:(NSImage *)image {
	//if (self->_image == image)
	//	return;
    
    
    
    [self stopGifAnimation];
	self->_image = image;
	    
	if ([image isKindOfClass:BTRImage.class]) {
		BTRImage *btrImage = (BTRImage *)image;
        NSSize imageSize = image.size;
		NSEdgeInsets insets = ((BTRImage *)image).capInsets;
		self.imageLayer.contentsCenter = BTRCAContentsCenterForInsets(insets, imageSize);
        
        self.imageLayer.contents = btrImage.isAnimated ? image : nil;
	} else {
        //[CATransaction begin];
        //[CATransaction setDisableActions:YES];
		self.imageLayer.contentsCenter = CGRectMake(0.0, 0.0, 1.0, 1.0);
        self.imageLayer.contents = image;
      //  [CATransaction commit];
	}
    
    [self layout];
}

- (void)imageAnimationTimerFired:(NSTimer *)timer {
    if(!self.isAnimationRunning)
        return;
    
    BTRImage *btrImage = (BTRImage *)self.image;

    
    [self.animatedTimer invalidate];
    
    if(self.visibleRect.size.width == 0 || !self.superview.superview || self.isHidden) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self imageAnimationTimerFired:nil];
        });
        return;
    }
    
	if (timer) {
        self.currentFrame++;
    }
    
    if (self.currentFrame > btrImage.totalImageFrames - 1)
		self.currentFrame = 0;

    AnimatedFrameImage *frame = [btrImage.cacheFrames objectAtIndex:self.currentFrame];
    self.imageLayer.contents = frame;
    self.animatedTimer = [NSTimer scheduledTimerWithTimeInterval:frame.duration target:self selector:@selector(imageAnimationTimerFired:) userInfo:nil repeats:NO];
}

- (void) viewWillDraw {
    if(!self.isHidden)
        [self startGifAnimation];
}

- (void) startGifAnimation {
    BTRImage *btrImage = (BTRImage *)self.image;

    if(!self.isAnimationRunning && [btrImage isKindOfClass:BTRImage.class] && btrImage.isAnimated) {
        [self stopGifAnimation];
        self.isAnimationRunning = YES;
        [self imageAnimationTimerFired:nil];
    }
}

- (void) stopGifAnimation {
    BTRImage *btrImage = (BTRImage *)self.image;

    self.isAnimationRunning = NO;
    if([self.image isKindOfClass:BTRImage.class] && btrImage.isAnimated) {
        [self.animatedTimer invalidate];
        self.animatedTimer = nil;
    }
    
    self.imageLayer.contents = nil;
}

- (void)viewDidChangeBackingProperties {
	self.layer.contentsScale = self.window.backingScaleFactor;
	self.imageLayer.contentsScale = self.layer.contentsScale;
}

#pragma mark Layer properties

- (void)setCornerRadius:(CGFloat)cornerRadius {
	self.imageLayer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
	return self.imageLayer.cornerRadius;
}

- (void)setTransform:(CATransform3D)transform {
	self.imageLayer.transform = transform;
}

- (CATransform3D)transform {
	return self.imageLayer.transform;
}

- (void)addAnimation:(CAAnimation *)animation forKey:(NSString *)key {
	[self.imageLayer addAnimation:animation forKey:key];
}

- (void)removeAnimationForKey:(NSString *)key {
    [self.imageLayer removeAnimationForKey:key];
}

-(CALayer *)currentLayer {
    return _imageLayer;
}

#pragma mark Content mode

- (void)setContentMode:(BTRViewContentMode)contentMode {
	_contentMode = contentMode;
	self.imageLayer.contentsGravity = [self contentsGravityFromContentMode:contentMode];
}

- (NSString *)contentsGravityFromContentMode:(BTRViewContentMode)contentMode {
	switch (contentMode) {
		case BTRViewContentModeScaleToFill:
			return kCAGravityResize;
			break;
		case BTRViewContentModeScaleAspectFit:
			return kCAGravityResizeAspect;
			break;
		case BTRViewContentModeScaleAspectFill:
			return kCAGravityResizeAspectFill;
			break;
		case BTRViewContentModeCenter:
			return kCAGravityCenter;
			break;
		case BTRViewContentModeTop:
			return kCAGravityTop;
			break;
		case BTRViewContentModeBottom:
			return kCAGravityBottom;
			break;
		case BTRViewContentModeLeft:
			return kCAGravityLeft;
			break;
		case BTRViewContentModeRight:
			return kCAGravityRight;
			break;
		case BTRViewContentModeTopLeft:
			return kCAGravityTopLeft;
			break;
		case BTRViewContentModeTopRight:
			return kCAGravityTopRight;
			break;
		case BTRViewContentModeBottomLeft:
			return kCAGravityBottomLeft;
			break;
		case BTRViewContentModeBottomRight:
			return kCAGravityBottomRight;
			break;
		default:
			break;
	}
}

#pragma mark Accessibility

- (BOOL)accessibilityIsIgnored {
	return NO;
}

@end
