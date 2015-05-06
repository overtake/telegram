//
//  BTRView.m
//  Originally from Rebel
//
//  Created by Justin Spahr-Summers on 2012-07-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "BTRView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BTRView {
	BOOL drawFlag;
}



#pragma mark Properties

- (void)setFlipped:(BOOL)flipped {
	if (_btrFlipped != flipped) {
		_btrFlipped = flipped;
		self.needsLayout = YES;
		self.needsDisplay = YES;
	}
}

#pragma mark Lifecycle

- (id)initWithFrame:(NSRect)frame layerHosted:(BOOL)hostsLayer {
	self = [super initWithFrame:frame];
	if (self == nil) return nil;
	
	if (hostsLayer) {
		self.layer = [CALayer layer];
		self.layer.delegate = self;
	}

	BTRViewCommonInit(self);
	
	return self;
}

- (id)initWithFrame:(NSRect)frame {
	return [self initWithFrame:frame layerHosted:NO];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil) return nil;
	
	BTRViewCommonInit(self);
	
	return self;
}

static void BTRViewCommonInit(BTRView *self) {
	self.wantsLayer = YES;
	self.layerContentsPlacement = NSViewLayerContentsPlacementScaleAxesIndependently;
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawNever;
}

#pragma mark NSObject

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p>{ frame = %@, layer = <%@: %p> }", self.class, self, NSStringFromRect(self.frame), self.layer.class, self.layer];
}

#pragma mark NSView

- (NSColor *)backgroundColor {
	return [NSColor colorWithCGColor:self.layer.backgroundColor];
}

- (void)setBackgroundColor:(NSColor *)color {
	self.layer.backgroundColor = color.CGColor;
}

- (CGFloat)cornerRadius {
	return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)radius {
	self.layer.cornerRadius = radius;
}

- (BOOL)masksToBounds {
	return self.layer.masksToBounds;
}

- (void)setMasksToBounds:(BOOL)masksToBounds {
	self.layer.masksToBounds = masksToBounds;
}

- (BOOL)isOpaque {
	return self.layer.opaque;
}

- (void)setOpaque:(BOOL)opaque {
	self.layer.opaque = opaque;
}

#pragma mark Drawing and actions

- (void)displayAnimated {
	drawFlag = self.animatesContents;
	self.animatesContents = YES;
	[self display];
}

- (void)setAnimatesContents:(BOOL)animate {
	drawFlag = animate;
	_animatesContents = animate;
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
	if ([event isEqualToString:@"contents"]) {
		if (!self.animatesContents) {
			return (id<CAAction>)[NSNull null];
		}
		self.animatesContents = drawFlag;
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contents"];
		return animation;
	}
	
	return [super actionForLayer:layer forKey:event];
}

#pragma mark - View controller

// From http://www.cocoawithlove.com/2008/07/better-integration-for-nsviewcontroller.html
- (void)setViewController:(NSViewController *)newController {
    if (_viewController) {
        NSResponder *controllerNextResponder = _viewController.nextResponder;
        [super setNextResponder:controllerNextResponder];
		_viewController.nextResponder = nil;
    }
	
    _viewController = newController;
	
    if (newController) {
        NSResponder *ownNextResponder = self.nextResponder;
        [super setNextResponder:_viewController];
		_viewController.nextResponder = ownNextResponder;
    }
}

- (void)setNextResponder:(NSResponder *)newNextResponder {
    if (_viewController) {
		_viewController.nextResponder = newNextResponder;
        return;
    }
    [super setNextResponder:newNextResponder];
}

//- (void) setNeedsDisplay:(BOOL)flag {
//    
//}

#pragma mark Drawing block

//- (void)drawRect:(NSRect)dirtyRect {
//	[super drawRect:dirtyRect];
//	
//	if (self.drawRectBlock != nil) {
//		MTLog(@"%s",__PRETTY_FUNCTION__);
//		CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
//		self.drawRectBlock(self, ctx);
//	}
//}

@end
