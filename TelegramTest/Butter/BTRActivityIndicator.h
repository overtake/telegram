//
//  BTRActivityIndicator.h
//  Butter
//
//  Created by Jonathan Willing on 12/25/12.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//
//	Much thanks to David Rönnqvist (@davidronnqvist) for the original idea of using CAReplicatorLayer.

typedef enum {
    BTRActivityIndicatorStyleWhite,
    BTRActivityIndicatorStyleGray
} BTRActivityIndicatorStyle;

#import "BTRView.h"

// An indeterminate activity indicator.
@interface BTRActivityIndicator : BTRView

// Returns an activity indicator sized to the default indicator size.
- (id)initWithActivityIndicatorStyle:(BTRActivityIndicatorStyle)style;

// Initializes the activity indicator with the default indicator style (BTRActivityIndicatorStyleGray).
- (id)initWithFrame:(NSRect)frameRect;

- (id)initWithFrame:(NSRect)frameRect activityIndicatorStyle:(BTRActivityIndicatorStyle)style;

// Starts and ends the animation of the activity indicator.
- (void)startAnimating;
- (void)stopAnimating;

// Whether the activity indicator is currently animating.
@property (nonatomic, assign, readonly) BOOL animating;

// Change the style of the activity indicator.
@property (nonatomic, assign) BTRActivityIndicatorStyle activityIndicatorStyle;

// The fill color for the indicator. If the shape layer is replaced,
// setting a shape color will have no effect.
@property (nonatomic, strong) NSColor *progressShapeColor;

// The number of shapes in the indicator. The spacing will be
// automatically adjusted to evenly distribute all of the shapes.
@property (nonatomic, assign) NSUInteger progressShapeCount;

// The thickness of the shapes in the indicator.
@property (nonatomic, assign) CGFloat progressShapeThickness;

// The length of the shapes in the indicator.
@property (nonatomic, assign) CGFloat progressShapeLength;

// The spread of the shapes in the indicator. Smaller spreads may cause
// unintentional overlap of the shapes due to close proximity.
@property (nonatomic, assign) CGFloat progressShapeSpread;

// The duration of one complete rotation of the activity indicator.
//
// Defaults to 1.0s.
@property (nonatomic, assign) CGFloat progressAnimationDuration;

// The "tooth" of the indicator. If the progress indicator needs to be modified,
// a new layer can be set as the new progress shape layer. The layer will have
// the correct transforms and replications automatically applied.
//
// Behavior for modifying the default layer is undefined. If smaller customizations
// are needed, it is better to use the appearance properties defined above.
@property (nonatomic, strong) CALayer *progressShapeLayer;

@end
