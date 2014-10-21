//
//  RBLView.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-07-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLView.h"
#import "NSColor+RBLCGColorAdditions.h"

// The implementation pointer for -[RBLView drawRect:], used to identify when
// the method is overridden by subclasses.
static IMP RBLViewDrawRectIMP;

@interface RBLView () {
	struct {
		unsigned clearsContextBeforeDrawing:1;
		unsigned flipped:1;
		unsigned clipsToBounds:1;
		unsigned opaque:1;
	} _flags;
}

// Whether this subclass of RBLView overrides -drawRect:.
+ (BOOL)doesCustomDrawing;

// Applies all layer properties that the receiver knows about.
- (void)applyLayerProperties;

@end

@implementation RBLView

#pragma mark Properties

// Implemented by NSView.
@dynamic layerContentsRedrawPolicy;

- (void)setBackgroundColor:(NSColor *)color {
	_backgroundColor = color;
	[self applyLayerProperties];
}

- (void)setCornerRadius:(CGFloat)radius {
	_cornerRadius = radius;
	[self applyLayerProperties];
}

- (BOOL)clipsToBounds {
	return _flags.clipsToBounds;
}

- (void)setClipsToBounds:(BOOL)value {
	_flags.clipsToBounds = (value ? 1 : 0);
	[self applyLayerProperties];
}

- (BOOL)isOpaque {
	return _flags.opaque;
}

- (void)setOpaque:(BOOL)value {
	_flags.opaque = (value ? 1 : 0);
	[self applyLayerProperties];
}

- (BOOL)isFlipped {
	return _flags.flipped;
}

- (void)setFlipped:(BOOL)value {
	if (value == self.flipped) return;

	_flags.flipped = (value ? 1 : 0);

	// Not sure how necessary these are, but it's probably a good idea.
	self.needsLayout = YES;
	self.needsDisplay = YES;
}

- (BOOL)clearsContextBeforeDrawing {
	return _flags.clearsContextBeforeDrawing;
}

- (void)setClearsContextBeforeDrawing:(BOOL)value {
	_flags.clearsContextBeforeDrawing = (value ? 1 : 0);
}

- (void)setContents:(NSImage *)image {
	if (image != nil) {
		NSAssert(![self.class doesCustomDrawing], @"%@ should not have prerendered contents if -drawRect: is overridden", self);
	}

	_contents = image;

	// We don't need to call -updateLayer or -drawRect: right now, but AppKit
	// might later, so we still implement those methods despite doing this here.
	self.layer.contents = image;
}

#pragma mark Initialization

+ (void)initialize {
	if (self != [RBLView class]) return;

	RBLViewDrawRectIMP = [self instanceMethodForSelector:@selector(drawRect:)];
}

#pragma mark Lifecycle

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self == nil) return nil;

	self.wantsLayer = YES;
	self.layerContentsPlacement = NSViewLayerContentsPlacementScaleAxesIndependently;
	self.clearsContextBeforeDrawing = YES;

	if (self.class.doesCustomDrawing) {
		// Use more conservative defaults if -drawRect: is overridden, to ensure
		// correct drawing. Callers or subclasses can override these defaults
		// to optimize for performance instead.
		self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawDuringViewResize;
	} else {
		self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawNever;
	}

	return self;
}

#pragma mark Drawing

+ (BOOL)doesCustomDrawing {
	return [self instanceMethodForSelector:@selector(drawRect:)] != RBLViewDrawRectIMP;
}

- (void)drawRect:(NSRect)rect {
	CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;

	if (self.clearsContextBeforeDrawing && !self.opaque) {
		CGContextClearRect(context, rect);
	}

	if (self.contents != nil) {
		NSCompositingOperation operation = (self.opaque ? NSCompositeCopy : NSCompositeSourceOver);
		[self.contents drawInRect:self.bounds fromRect:NSZeroRect operation:operation fraction:1];
	}
}

#pragma mark View Hierarchy

// Before 10.8, AppKit may destroy the view's layer when changing superviews
// or windows, so reapply our properties when either of those events occur.
- (void)viewDidMoveToSuperview {
	[self applyLayerProperties];
}

- (void)viewDidMoveToWindow {
	[self applyLayerProperties];
}

#pragma mark Layer Management

- (void)applyLayerProperties {
	self.layer.backgroundColor = self.backgroundColor.rbl_CGColor;
	self.layer.cornerRadius = self.cornerRadius;
	self.layer.masksToBounds = self.clipsToBounds;
	self.layer.opaque = self.opaque;
}

- (void)setLayer:(CALayer *)layer {
	[super setLayer:layer];
	[self applyLayerProperties];
}

// 10.8+ only.
- (void)updateLayer {
	NSAssert(self.contents != nil, @"%@ does not have contents, %s should not be invoked", self, __func__);
	self.layer.contents = self.contents;
}

// 10.8+ only.
- (BOOL)wantsUpdateLayer {
	return self.contents != nil;
}

#pragma mark NSObject

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p>{ frame = %@, layer = <%@: %p>, contents = %@ }", self.class, self, NSStringFromRect(self.frame), self.layer.class, self.layer, self.contents];
}

@end
