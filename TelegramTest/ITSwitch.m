//
//  ITSwitch.m
//  ITSwitch-Demo
//
//  Created by Ilija Tovilo on 01/02/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import "ITSwitch.h"
#import <QuartzCore/QuartzCore.h>


// ----------------------------------------------------
#pragma mark - Preprocessor
// ----------------------------------------------------

#define kAnimationDuration 0.4f

#define kBorderLineWidth 1.f

#define kGoldenRatio 1.61803398875f
#define kDecreasedGoldenRatio 1.38

#define kKnobBackgroundColor [NSColor colorWithCalibratedWhite:1.f alpha:1.f]

#define kDisabledBorderColor NSColorFromRGB(0xD7D7D7) // [NSColor colorWithCalibratedWhite:0.f alpha:0.2f]
#define kDisabledBackgroundColor NSColorFromRGB(0xD7D7D7)// [NSColor clearColor]
#define kDefaultTintColor [NSColor colorWithCalibratedRed:0.27f green:0.86f blue:0.36f alpha:1.f]



// ---------------------------------------------------------------------------------------
#pragma mark - Interface Extension
// ---------------------------------------------------------------------------------------

@interface ITSwitch () {
    __weak id _target;
    SEL _action;
}

@property (setter = setActive:) BOOL isActive;
@property (setter = setDragged:) BOOL hasDragged;
@property (setter = setDraggingTowardsOn:) BOOL isDraggingTowardsOn;

@property (readonly, strong) CALayer *rootLayer;
@property (readonly, strong) CALayer *backgroundLayer;
@property (readonly, strong) CALayer *knobLayer;
@property (readonly, strong) CALayer *knobInsideLayer;

@property (nonatomic,assign) float animationDuration;

@end



// ---------------------------------------------------------------------------------------
#pragma mark - ITSwitch
// ---------------------------------------------------------------------------------------

@implementation ITSwitch
@synthesize tintColor = _tintColor;

// ----------------------------------------------------
#pragma mark - Init
// ----------------------------------------------------

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (!self) return nil;
    
    [self setUp];
    
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self setUp];
    
    return self;
}

- (void)setUp {
    self.wantsLayer = YES;
     _animationDuration = kAnimationDuration;
    [self setUpLayers];
}

- (void)setUpLayers {
    // Root layer
    _rootLayer = [CALayer layer];
    _rootLayer.delegate = self;
    self.layer = _rootLayer;
    
    // Background layer
    _backgroundLayer = [CALayer layer];
    _backgroundLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    _backgroundLayer.bounds = _rootLayer.bounds;
    _backgroundLayer.anchorPoint = (CGPoint){ .x = 0.f, .y = 0.f };
    _backgroundLayer.borderWidth = kBorderLineWidth;
    [_rootLayer addSublayer:_backgroundLayer];
    
    // Knob layer
    _knobLayer = [CALayer layer];
    _knobLayer.frame = [self rectForKnob];
    _knobLayer.autoresizingMask = kCALayerHeightSizable;
    _knobLayer.backgroundColor = kKnobBackgroundColor.CGColor;
//    _knobLayer.shadowColor = [NSColor blackColor].CGColor;
//    _knobLayer.shadowOffset = (CGSize){ .width = 0.f, .height = -2.f };
//    _knobLayer.shadowRadius = 1.f;
//    _knobLayer.shadowOpacity = 0.3f;
    [_rootLayer addSublayer:_knobLayer];
    
    _knobInsideLayer = [CALayer layer];
    _knobInsideLayer.frame = _knobLayer.bounds;
    _knobInsideLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    _knobInsideLayer.shadowColor = [NSColor blackColor].CGColor;
    _knobInsideLayer.shadowOffset = (CGSize){ .width = 0.f, .height = 0.f };
    _knobInsideLayer.backgroundColor = [NSColor whiteColor].CGColor;
    _knobInsideLayer.shadowRadius = 1.f;
    _knobInsideLayer.shadowOpacity = 0.35f;
    [_knobLayer addSublayer:_knobInsideLayer];
    
    // Initial
    [self updateLayer];
}


// ----------------------------------------------------
#pragma mark - NSView
// ----------------------------------------------------

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [CATransaction begin];
    {
        [CATransaction setDisableActions:YES];
        
        [_backgroundLayer setCornerRadius:roundf(_backgroundLayer.bounds.size.height / 2.f)];
        [_knobLayer setCornerRadius:roundf(_knobLayer.bounds.size.height / 2.f)];
        [_knobInsideLayer setCornerRadius:roundf(_knobLayer.bounds.size.height / 2.f)];
    }
    [CATransaction commit];
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.knobLayer.frame = [self rectForKnob];
        self.knobInsideLayer.frame = self.knobLayer.bounds;
    }
    [CATransaction commit];
}



// ----------------------------------------------------
#pragma mark - Update Layer
// ----------------------------------------------------

- (void)updateLayer {
    
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:_animationDuration];
    {
        // ------------------------------- Animate Border
        // The green part also animates, which looks kinda weird
        // We'll use the background-color for now
        //        _backgroundLayer.borderWidth = (YES || self.isActive || self.isOn) ? NSHeight(_backgroundLayer.bounds) / 2 : kBorderLineWidth;
        
        // ------------------------------- Animate Colors
        if ((self.hasDragged && self.isDraggingTowardsOn && self.isEnabled) || (!self.hasDragged && self.isOn && self.isEnabled)) {
            _backgroundLayer.borderColor = self.tintColor.CGColor;
            _backgroundLayer.backgroundColor = self.tintColor.CGColor;
        } else {
            _backgroundLayer.borderColor = kDisabledBorderColor.CGColor;
            _backgroundLayer.backgroundColor = kDisabledBackgroundColor.CGColor;
        }
        
        // ------------------------------- Animate Frame
        [CATransaction begin];
        [CATransaction setAnimationDuration:_animationDuration];
        {
            if (!self.hasDragged) {
                CAMediaTimingFunction *function = [CAMediaTimingFunction functionWithControlPoints:0.25f :1.5f :0.5f :1.f];
                [CATransaction setAnimationTimingFunction:function];
            }
            
            self.knobLayer.frame = [self rectForKnob];
            self.knobInsideLayer.frame = self.knobLayer.bounds;
        }
        [CATransaction commit];
    }
    [CATransaction commit];
}

- (CGFloat)knobHeightForSize:(NSSize)size
{
    return size.height - (kBorderLineWidth * 2.f);
}

- (CGRect)rectForKnob {
    CGFloat height = [self knobHeightForSize:_backgroundLayer.bounds.size];
    CGFloat width = height; //!self.isActive ? height :  (NSWidth(_backgroundLayer.bounds) - 2.f * kBorderLineWidth) * 1.f / kDecreasedGoldenRatio;
    CGFloat x = ((!self.hasDragged && !self.isOn) || (self.hasDragged && !self.isDraggingTowardsOn)) ?
    kBorderLineWidth :
    NSWidth(_backgroundLayer.bounds) - width - kBorderLineWidth;
    
   
    
    return (CGRect) {
        .size.width = width,
        .size.height = height,
        .origin.x = x,
        .origin.y = kBorderLineWidth,
    };
}


// ----------------------------------------------------
#pragma mark - NSResponder
// ----------------------------------------------------

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
    
    self.isActive = YES;
    
    [self updateLayer];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    self.hasDragged = YES;
    
    NSPoint draggingPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    self.isDraggingTowardsOn = draggingPoint.x >= NSWidth(self.bounds) / 2.f;
    
    [self updateLayer];
}

- (void)mouseUp:(NSEvent *)theEvent {
    
    [super mouseUp:theEvent];
    
    if(!self.isEnabled)
        return;
    
    self.isActive = NO;
    
    BOOL isOn = (!self.hasDragged) ? !self.isOn : self.isDraggingTowardsOn;
    BOOL invokeTargetAction = (isOn != _isOn);
    
    self.isOn = isOn;
    if (invokeTargetAction) [self _invokeTargetAction];
    
    // Reset
    self.hasDragged = NO;
    self.isDraggingTowardsOn = NO;
    
    [self updateLayer];
}


// ----------------------------------------------------
#pragma mark - NSControl
// ----------------------------------------------------

- (id)target {
    return _target;
}

- (void)setTarget:(id)anObject {
    _target = anObject;
}

- (SEL)action {
    return _action;
}

- (void)setAction:(SEL)aSelector {
    _action = aSelector;
}

-(void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    
}



// ----------------------------------------------------
#pragma mark - Accessors
// ----------------------------------------------------

- (void)setOn:(BOOL)isOn {
    if (_isOn != isOn) {
        [self willChangeValueForKey:@"isOn"];
        {
            _isOn = isOn;
        }
        [self didChangeValueForKey:@"isOn"];
    }
    
    [self updateLayer];
    
    _animationDuration = kAnimationDuration;
}

- (NSColor *)tintColor {
    if (!_tintColor) return kDefaultTintColor;
    
    return _tintColor;
}

- (void)setTintColor:(NSColor *)tintColor {
    _tintColor = tintColor;
    [self setNeedsDisplay:YES];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    
    
    _animationDuration = animated ? kAnimationDuration : 0;
   
    [self setOn:on];
}



// -----------------------------------
#pragma mark - Helpers
// -----------------------------------

- (void)_invokeTargetAction {
    if(self.didChangeHandler) {
        self.didChangeHandler(_isOn);
    }
    
    if (self.target && self.action) {
        
        NSMethodSignature *signature = [[self.target class] instanceMethodSignatureForSelector:self.action];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self.target];
        [invocation setSelector:self.action];
        [invocation setArgument:(void *)&self atIndex:2];
        
        [invocation invoke];
    }
}


@end
