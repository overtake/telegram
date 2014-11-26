//
//  BTRView.h
//  Originally from Rebel
//
//  Created by Justin Spahr-Summers on 2012-07-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// A base class for layer-backed views.
@interface BTRView : NSView

// Optional initializer which opts to provide the option to create a
// layer-hosted view instead of a layer-backed view.
- (id)initWithFrame:(NSRect)frame layerHosted:(BOOL)hostsLayer;

// A background color for the view, or nil if none has been set.
@property (nonatomic, strong) NSColor *backgroundColor;

// Whether the view's content and subviews masks to its bounds
//
// Defaults to NO.
@property (nonatomic, assign) BOOL masksToBounds;

// A radius used to draw rounded corners for the view's background.
//
// Typically, you will want to enable clipsToBounds when setting this property
// to a non-zero value.
//
// Defaults to 0.
@property (nonatomic, assign) CGFloat cornerRadius;

// Whether the view's drawing completely fills its bounds with opaque content.
//
// Defaults to NO.
@property (atomic, assign, getter = isOpaque) BOOL opaque;

// Whether the view's drawing and layout uses a flipped (top-left origin)
// coordinate system.
//
// Defaults to NO.
@property (atomic, assign, getter = isFlipped) BOOL btrFlipped;

// Whether the content is redrawn with a default animation applied.
//
// Defaults to NO.
@property (nonatomic, assign) BOOL animatesContents;

// The view's parent view controller.
//
// Used to patch the view controller into the responder chain.
@property (nonatomic, assign) IBOutlet NSViewController *viewController;

// A wrapper around -display that enables the animation on view redrawing,
// draws the view, and changes back to default content animation setting.
//
// The animation can be customized by wrapping the call in a NSView animation.
- (void)displayAnimated;

// TODO: Disabled due to an AppKit bug getting in the way. Will be implemented
// in the future.
//@property (nonatomic, copy) void (^drawRectBlock)(BTRView *view, CGContextRef ctx);

@end
