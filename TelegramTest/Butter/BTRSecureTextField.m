//
//  BTRSecureTextField.m
//  Butter
//
//  Created by Indragie Karunaratne on 2012-12-28.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//

#import "BTRSecureTextField.h"
#import "BTRControlAction.h"
#import <QuartzCore/QuartzCore.h>

@interface BTRSecureTextField()
@property (nonatomic, readonly, getter = isFirstResponder) BOOL firstResponder;
@property (nonatomic, strong) BTRImageView *backgroundImageView;
@property (nonatomic, strong) NSMutableDictionary *backgroundImages;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic) BOOL mouseInside;
@property (nonatomic) BOOL mouseDown;
@property (nonatomic) BOOL mouseHover;
@property (nonatomic, readwrite) NSInteger clickCount;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL needsTrackingArea;
@end

@interface BTRSecureTextFieldCell : NSSecureTextFieldCell
@end

static const CGFloat BTRTextFieldCornerRadius = 3.f;
static const CGFloat BTRTextFieldInnerRadius = 2.f;
static CGFloat const BTRTextFieldXInset = 5.f;
#define BTRTextFieldBorderColor [NSColor clearColor]
#define BTRTextFieldActiveGradientStartingColor [NSColor clearColor]
#define BTRTextFieldActiveGradientEndingColor [NSColor clearColor]
#define BTRTextFieldInactiveGradientStartingColor [NSColor clearColor]
#define BTRTextFieldInactiveGradientEndingColor [NSColor clearColor]
#define BTRTextFieldFillColor NSColorFromRGB(0xF1F1F1)
#define BTRTextFieldShadowColor [NSColor clearColor]

@implementation BTRSecureTextField {
	BOOL _btrDrawsBackground;
}

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self == nil) return nil;
	[self commonInit];
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil) return nil;
	[self commonInit];
	return self;
}

- (void)commonInit {
	self.wantsLayer = YES;
	
	// Copy over *all* the attributes to the new cell
	// There really is no other easy way to do this :(
	NSTextFieldCell *oldCell = self.cell;
	BTRSecureTextFieldCell *newCell = [[BTRSecureTextFieldCell alloc] initTextCell:self.stringValue];
	newCell.placeholderString = oldCell.placeholderString;
	newCell.textColor = oldCell.textColor;
	newCell.font = oldCell.font;
	newCell.alignment = oldCell.alignment;
	newCell.lineBreakMode = oldCell.lineBreakMode;
	newCell.truncatesLastVisibleLine = oldCell.truncatesLastVisibleLine;
	newCell.wraps = oldCell.wraps;
	newCell.baseWritingDirection = oldCell.baseWritingDirection;
	newCell.attributedStringValue = oldCell.attributedStringValue;
	newCell.allowsEditingTextAttributes = oldCell.allowsEditingTextAttributes;
	newCell.action = oldCell.action;
	newCell.target = oldCell.target;
	newCell.focusRingType = oldCell.focusRingType;
	[newCell setEditable:[oldCell isEditable]];
	[newCell setSelectable:[oldCell isSelectable]];
	self.cell = newCell;
	self.backgroundImages = [NSMutableDictionary dictionary];
	self.actions = [NSMutableArray array];
	self.needsTrackingArea = NO;
	
	self.focusRingType = NSFocusRingTypeNone;
	super.drawsBackground = NO;
	self.drawsBackground = YES;
	self.bezeled = NO;
	
	// Set up the layer styles used to draw a focus ring.
	self.layer.shadowColor = BTRTextFieldShadowColor.CGColor;
	self.layer.shadowOffset = CGSizeZero;
	self.layer.shadowRadius = 2.f;
}

- (void)layout {
	[super layout];
	self.backgroundImageView.frame = self.bounds;
}

// It appears that on some layer-backed view hierarchies that are
// set up before the window has a chance to be shown, the text fields
// aren't set up properly. This temporarily alleviates this problem.
//
// TODO: Investigate this more.
- (void)viewDidMoveToWindow {
	[self setNeedsDisplay:YES];
}

+ (Class)cellClass {
	return [BTRSecureTextFieldCell class];
}

#pragma mark - Accessors

- (void)setDrawsBackground:(BOOL)flag {
	if (_btrDrawsBackground != flag) {
		_btrDrawsBackground = flag;
		[self setNeedsDisplay:YES];
	}
}

- (BOOL)drawsBackground {
	return _btrDrawsBackground;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
	self.backgroundImageView.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
	return self.backgroundImageView.cornerRadius;
}

- (BTRControlState)state {
	BTRControlState state = BTRControlStateNormal;
	if (self.isHighlighted) state |= BTRControlStateHighlighted;
	if (![self isEnabled]) state |= BTRControlStateDisabled;
	if (self.mouseHover && !self.isHighlighted) state |= BTRControlStateHover;
	return state;
}

- (BTRImageView *)backgroundImageView {
	if (!_backgroundImageView) {
		_backgroundImageView = [[BTRImageView alloc] initWithFrame:self.bounds];
		[self addSubview:_backgroundImageView];
	}
	return _backgroundImageView;
}

- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	[self handleStateChange];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect {
	if (!self.drawsBackground) {
		[super drawRect:dirtyRect];
		return;
	}
	[BTRTextFieldBorderColor set];
	if (![self isFirstResponder])
		[[NSBezierPath bezierPathWithRoundedRect:self.bounds
										 xRadius:BTRTextFieldCornerRadius
										 yRadius:BTRTextFieldCornerRadius] fill];
	
	NSGradient *gradient = nil;
	CGRect borderRect = self.bounds;
	borderRect.size.height -= 1, borderRect.origin.y += 1;
	if([self isFirstResponder]) {
		gradient = [[NSGradient alloc] initWithStartingColor:BTRTextFieldActiveGradientStartingColor
												 endingColor:BTRTextFieldActiveGradientStartingColor];
	} else {
		gradient = [[NSGradient alloc] initWithStartingColor:BTRTextFieldInactiveGradientStartingColor
												 endingColor:BTRTextFieldInactiveGradientEndingColor];
	}
	[gradient drawInBezierPath:[NSBezierPath bezierPathWithRoundedRect:borderRect xRadius:BTRTextFieldCornerRadius yRadius:BTRTextFieldCornerRadius] angle:-90];
	
	[BTRTextFieldFillColor set];
	CGRect innerRect = NSInsetRect(self.bounds, 1, 2);
	innerRect.size.height += 1;
	[[NSBezierPath bezierPathWithRoundedRect:innerRect xRadius:BTRTextFieldInnerRadius yRadius:BTRTextFieldInnerRadius] fill];
	
	[super drawRect:dirtyRect];
}



-(void)textDidChange:(NSNotification *)notification {
    if(self.stringValue.length > 21) {
        [self setStringValue:[self.stringValue substringWithRange:NSMakeRange(0, 21)]];
        NSBeep();
    }
}

- (CATransition *)shadowOpacityAnimation {
	CATransition *fade = [CATransition animation];
	fade.duration = 0.25;
	fade.type = kCATransitionFade;
	return fade;
}

#pragma mark - Public API

- (NSImage *)backgroundImageForControlState:(BTRControlState)state {
	return [_backgroundImages objectForKey:@(state)];
}

- (void)setBackgroundImage:(NSImage *)image forControlState:(BTRControlState)state {
	[_backgroundImages setObject:image forKey:@(state)];
	[self updateState];
}

- (void)updateState {
	NSImage *backgroundImage = [self backgroundImageForControlState:self.state];
	if (backgroundImage == nil) {
		backgroundImage = [self backgroundImageForControlState:BTRControlStateNormal];
	}
	self.drawsBackground = (backgroundImage == nil);
	self.backgroundImageView.image = backgroundImage;
}

#pragma mark - BTRControl

- (void)updateTrackingAreas {
	if (!self.needsTrackingArea)
		return;
	
	if (self.trackingArea) {
		[self removeTrackingArea:self.trackingArea];
		self.trackingArea = nil;
	}
	
	// TODO: Figure out correct tracking to implement mouse drag
	NSUInteger options = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingEnabledDuringMouseDrag);
	self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
													 options:options
													   owner:self userInfo:nil];
	[self addTrackingArea:self.trackingArea];
}

- (void)setMouseHover:(BOOL)mouseHover {
	[self updateStateWithOld:&_mouseHover new:mouseHover];
}

- (void)setBtrHighlighted:(BOOL)highlighted {
	[self updateStateWithOld:&_btrHighlighted new:highlighted];
}

- (void)updateStateWithOld:(BOOL *)old new:(BOOL)new {
	BOOL o = *old;
	*old = new;
	if (o != new) {
		[self handleStateChange];
	}
}

- (void)handleStateChange {
	[self updateState];
}

- (void)addBlock:(void (^)(BTRControlEvents))block forControlEvents:(BTRControlEvents)events {
	NSParameterAssert(block);
	BTRControlAction *action = [BTRControlAction new];
	action.block = block;
	action.events = events;
	[self.actions addObject:action];
	[self handleUpdatedEvents:events];
}

- (void)handleUpdatedEvents:(BTRControlEvents)events {
	// TODO: Verify if we need a tracking area here.
	self.needsTrackingArea = YES;
}

- (void)setNeedsTrackingArea:(BOOL)needsTrackingArea {
	_needsTrackingArea = needsTrackingArea;
	if (!needsTrackingArea && self.trackingArea != nil) {
		[self removeTrackingArea:self.trackingArea];
		self.trackingArea = nil;
	}
}

- (void)mouseDown:(NSEvent *)event {
	[super mouseDown:event];
	[self handleMouseDown:event];
}

- (void)mouseUp:(NSEvent *)event {
	[super mouseUp:event];
	[self handleMouseUp:event];
}

- (void)rightMouseUp:(NSEvent *)event {
	[super rightMouseUp:event];
	[self handleMouseUp:event];
}

- (void)rightMouseDown:(NSEvent *)event {
	[super rightMouseDown:event];
	[self handleMouseDown:event];
}

- (void)mouseEntered:(NSEvent *)event {
	[super mouseEntered:event];
	self.mouseInside = YES;
	self.mouseHover = YES;
	[self sendActionsForControlEvents:BTRControlEventMouseEntered];
	if (self.mouseDown)
		self.btrHighlighted = YES;
}

- (void)mouseExited:(NSEvent *)event {
	[super mouseExited:event];
	self.mouseInside = NO;
	self.mouseHover = NO;
	[self sendActionsForControlEvents:BTRControlEventMouseExited];
	self.btrHighlighted = NO;
}

- (void)handleMouseDown:(NSEvent *)event {
	self.clickCount = event.clickCount;
	self.mouseDown = YES;
	
	BTRControlEvents events = 1;
	events |= BTRControlEventMouseDownInside;
	
	[self sendActionsForControlEvents:events];
	
	self.btrHighlighted = YES;
}

- (void)handleMouseUp:(NSEvent *)event {
	self.mouseDown = NO;
	
	BTRControlEvents events = 1;
	if (self.clickCount > 1) {
		events |= BTRControlEventClickRepeat;
	}
	if (event.type == NSLeftMouseUp && self.mouseInside) {
		events |= BTRControlEventLeftClick;
	} else if (event.type == NSRightMouseUp && self.mouseInside) {
		events |= BTRControlEventRightClick;
	}
	if (self.mouseInside) {
		events |= BTRControlEventMouseUpInside;
		events |= BTRControlEventClick;
	} else {
		events |= BTRControlEventMouseUpOutside;
	}
	
	[self sendActionsForControlEvents:events];
	
	self.btrHighlighted = NO;
}

- (void)sendActionsForControlEvents:(BTRControlEvents)events {
	for (BTRControlAction *action in self.actions) {
		if (action.events & events) {
			if (action.block != nil) {
				action.block(events);
			} else if (action.action != nil) { // the target can be nil
				[NSApp sendAction:action.action to:action.target];
			}
		}
	}
}

#pragma mark Responders

- (BOOL)isFirstResponder {
	id firstResponder = self.window.firstResponder;
	return ([firstResponder isKindOfClass:[NSText class]] && [firstResponder delegate] == self);
}

- (BOOL)becomeFirstResponder {
	[self.layer addAnimation:[self shadowOpacityAnimation] forKey:nil];
	self.layer.shadowOpacity = 1.f;
	self.backgroundImageView.animatesContents = NO;
	self.btrHighlighted = YES;
	return [super becomeFirstResponder];
}

- (void)textDidEndEditing:(NSNotification *)notification {
	[self.layer addAnimation:[self shadowOpacityAnimation] forKey:nil];
	self.layer.shadowOpacity = 0.f;
	self.backgroundImageView.animatesContents = self.animatesContents;
	[super textDidEndEditing:notification];
	self.btrHighlighted = NO;
}

@end

// Originally written by Daniel Jalkut as RSVerticallyCenteredTextFieldCell
// Licensed under MIT
// <http://www.red-sweater.com/blog/148/what-a-difference-a-cell-makes>
@implementation BTRSecureTextFieldCell {
	BOOL _isEditingOrSelecting;
}

- (NSRect)drawingRectForBounds:(NSRect)theRect {
	// Get the parent's idea of where we should draw
	NSRect newRect = [super drawingRectForBounds:theRect];
	
	// When the text field is being
	// edited or selected, we have to turn off the magic because it screws up
	// the configuration of the field editor.  We sneak around this by
	// intercepting selectWithFrame and editWithFrame and sneaking a
	// reduced, centered rect in at the last minute.
	if (_isEditingOrSelecting == NO) {
		// Get our ideal size for current text
		NSSize textSize = [self cellSizeForBounds:theRect];
		
		// Center that in the proposed rect
		CGFloat heightDelta = newRect.size.height - textSize.height;
		if (heightDelta > 0)
		{
			//newRect.size.height -= heightDelta;
			newRect.origin.y += ceil(heightDelta / 2);
		}
	}
	return NSInsetRect(newRect, BTRTextFieldXInset, -1.f);
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
	aRect = [self drawingRectForBounds:aRect];
	_isEditingOrSelecting = YES;
	[super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	_isEditingOrSelecting = NO;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
	aRect = [self drawingRectForBounds:aRect];
	_isEditingOrSelecting = YES;
	[super editWithFrame:aRect inView:controlView editor:textObj delegate:anObject event:theEvent];
	_isEditingOrSelecting = NO;
}

@end

