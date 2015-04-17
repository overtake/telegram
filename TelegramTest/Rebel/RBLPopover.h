//
//  RBLPopover.h
//  Rebel
//
//  Created by Danny Greg on 13/09/2012.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBLView.h"

@class BTRControl;
@class RBLPopover;
@class RBLPopoverBackgroundView;

// Defines the different types of behavior of a RBLPopover.
//
// RBLPopoverBehaviorApplicationDefined - The application decides when the
//                                        popover should open and close, by
//                                        doing so manually.
// RBLPopoverBehaviorTransient          - If there is a mouse down anywhere
//                                        other than in the popover the popover
//                                        is closed. It is also closed if the
//                                        app or parent window lose focus or
//                                        `esc` is pressed.
// RBLPopoverBehaviorSemiTransient      - Closes the popover only if there is a
//                                        mouse up within the popover's parent
//                                        window or `esc` is pressed.
typedef enum : NSUInteger {
	RBLPopoverBehaviorApplicationDefined = 0,
	RBLPopoverBehaviorTransient = 1,
	RBLPopoverBehaviorSemiTransient = 2
} RBLPopoverBehavior;

typedef void (^RBLPopoverDelegateBlock)(RBLPopover *popover);

// A popover.
// This aims to replicate the API of `NSPopover`, within reason, whilst offering
// more flexibility when it comes to customising of its appearance.
//
// One notable difference in behaviour when compared to `NSPopover` is memory
// management. `RBLPopover` does not retain itself and when it deallocates it
// will be removed from screen. Therefore a reference must be kept to the popover
// (or it should be otherwise retained) for as long as it should appear on
// screen.
//
// A note on layers: by default the clipping method which the popover uses to
// clip its subviews to its outline does _not_ support any layer backed or
// hosting views. This can be worked around by adding mask layers to any layers
// you add to the popover or its subviews.

@class  RBLPopover;
@interface RBLPopoverWindow : NSWindow

@property (nonatomic) BOOL canBeKey;
@property (nonatomic, weak) RBLPopover *popover;

@end

@interface RBLPopover : NSResponder

- (BOOL)isMouseInPopover;

@property (nonatomic, strong, readonly) NSView *positioningView;
@property (nonatomic, strong) BTRControl *hoverView;


// The view controller providing the view displayed within the popover.
@property (nonatomic, strong) NSViewController *contentViewController;

// The class of which an instance is created which sits behind the
// `contentViewController`'s view. This is useful for customising the appearance
// of the popover.
// Note that this must be a subclass of `RBLPopoverBackgroundView`.
@property (nonatomic, strong) Class backgroundViewClass;

// The popover's background view.
// This will be nil before the popover has been opened, after that point it will
// be an instance of the popover's `backgroundViewClass`.
@property (nonatomic, readonly, strong) RBLPopoverBackgroundView *backgroundView;

// The size that, when displayed, the popover's content should be.
// Passing `CGSizeZero` uses the size of the `contentViewController`'s view.
@property (nonatomic) CGSize contentSize;

@property (nonatomic,readonly) CGRectEdge preferredEdge;

// Whether the next open/close of the popover should be animated.
// Note that this property is checked just before the animation is performed.
// Therefore it is possible to animate the showing of the popover but hide the
// closing and vice versa.
@property (nonatomic) BOOL animates;

// How the popover should respond to user events, in regard to automatically
// closing the popover.
// See the definition of `RBLPopoverBehavior` for more
// information.
@property (nonatomic) RBLPopoverBehavior behavior;

// Whether the popover is currently visible.
@property (nonatomic, readonly, getter = isShown) BOOL shown;

@property (nonatomic,assign) BOOL lockHoverClose;

// Called before the popover is closed.
@property (nonatomic, copy) RBLPopoverDelegateBlock willCloseBlock;

// Called after the close has completed.
// Note that if the close is animated this block will be called _after_ the
// animation has successfully completed.
@property (nonatomic, copy) RBLPopoverDelegateBlock didCloseBlock;

// Called before the popover is opened.
@property (nonatomic, copy) RBLPopoverDelegateBlock willShowBlock;

// Called after the block has opened.
// Note that if the open is animated this block will be called _after_ the
// animation has successfully completed.
@property (nonatomic, copy) RBLPopoverDelegateBlock didShowBlock;

// Use for animation when showing and closing the popover.
@property (nonatomic, assign) NSTimeInterval fadeDuration;

// Whether the popover can become the key window.
//
// Defaults to `NO`.
@property (nonatomic, assign) BOOL canBecomeKey;

// Designated initialiser.
//
// Returns a newly initialised `RBLPopover`.
- (instancetype)initWithContentViewController:(NSViewController *)viewController;

// Displays the popover
//
// If the popover is already visible, this will move the popover to be
// re-positioned with the given `positioningRect` and `prederredEdge`.
//
// positioningRect - The area which the popover should "cling" to. Given in
//                   positioningView's coordinate space.
// positioningView - The view which the positioningRect is relative to.
// preferredEdge   - The edge of positioningRect which the popover should
//                   "cling" to. If the entire popover will not fit on the
//                   screen when clinging to the
//                   preferredEdge another edge will be used to ensure the
//                   content is visible. In the event that no edge allows the
//                   popover to fit on the screen, preferredEdge is used.
- (void)showRelativeToRect:(CGRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(CGRectEdge)preferredEdge;

// Closes the popover with the `fadeDuration` (if the popover animates).
- (void)close;

// Convenience method exposed for nib files.
- (IBAction)performClose:(id)sender;



@end



@interface RBLPopoverBackgroundView : NSView

// Given a size of the content this should be overridden by subclasses to
// describe how big the overall popover should be.
//
// contentSize - The size of the content contained within the popover.
// popoverEdge - The edge that is adjacent to the `positioningRect`.
//
// Returns the overall size of the backgroundView as a `CGSize`.
+ (CGSize)sizeForBackgroundViewWithContentSize:(CGSize)contentSize popoverEdge:(CGRectEdge)popoverEdge;

// Given a frame for the background this should be overridden by subclasses to
// describe where the content should fit within the popover.
// By default this sits the content in the frame of the background view whilst
// nudging the content to make room for the arrow and a 1px border.
//
// frame            - The frame of the `backgroundView`.
// popoverEdge      - The edge that is adjacent to the `positioningRect`.
//
// Returns the frame of the content relative to the given background view frame
// as a `CGRect`.
+ (CGRect)contentViewFrameForBackgroundFrame:(CGRect)frame popoverEdge:(CGRectEdge)popoverEdge;

// The designated initialiser.
//
// frame            - The frame of the background view.
// popoverEdge      - The edge that is adjacent to the `positioningRect`.
// originScreenRect - The frame of the screen which the popover has originated
//                    on.
//
// Returns a newly initialised instance of `RBLPopoverBackgroundView`.
- (instancetype)initWithFrame:(CGRect)frame popoverEdge:(CGRectEdge)popoverEdge originScreenRect:(CGRect)originScreenRect;

// The outline shape of a popover.
// This can be overridden by subclasses if they wish to change the shape of the
// popover but still use the default drawing of a simple stroke and fill.
//
// popoverEdge - The edge that is adjacent to the `positioningRect`.
// frame       - The frame of the background view.
//
// Returns a `CGPathRef` of the outline of the background view.
- (CGPathRef)newPopoverPathForEdge:(CGRectEdge)popoverEdge inFrame:(CGRect)frame;

// The edge of the target view which the popover is appearing next to.
@property (nonatomic) CGRectEdge popoverEdge;

// The color used to fill the shape of the background view.
@property (nonatomic, strong) NSColor *fillColor;

@end
