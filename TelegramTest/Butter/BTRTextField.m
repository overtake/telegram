//
//  BTRTextField.m
//  Butter
//
//  Created by Jonathan Willing on 12/21/12.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//

#import "BTRTextField.h"
#import "BTRImageView.h"
#import "BTRControlAction.h"
#import <QuartzCore/QuartzCore.h>

@interface BTRTextField()
@property (nonatomic, readonly, getter = isFirstResponder) BOOL firstResponder;
@property (nonatomic, strong) NSMutableDictionary *backgroundImages;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic) BOOL mouseInside;
@property (nonatomic) BOOL mouseDown;
@property (nonatomic) BOOL mouseHover;
@property (nonatomic, readwrite) NSInteger clickCount;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL needsTrackingArea;

@property (nonatomic, strong) NSMutableDictionary *placeholderAttributes;
@end

@interface BTRTextFieldCell : NSTextFieldCell
@property (nonatomic, assign) BOOL didRedrawAfterTextChange;
@end

static const CGFloat BTRTextFieldCornerRadius = 6.f;
static const CGFloat BTRTextFieldInnerRadius = 5.f;

#define BTRTextFieldBorderColor [NSColor colorWithDeviceWhite:1.f alpha:0.6f]
#define BTRTextFieldActiveGradientStartingColor BLUE_UI_COLOR
#define BTRTextFieldActiveGradientEndingColor [NSColor colorWithCalibratedRed:0.176 green:0.490 blue:0.898 alpha:1]
#define BTRTextFieldInactiveGradientStartingColor [NSColor colorWithDeviceWhite:0.6 alpha:1.0]
#define BTRTextFieldInactiveGradientEndingColor [NSColor colorWithDeviceWhite:0.7 alpha:1.0]
#define BTRTextFieldFillColor [NSColor whiteColor]
#define BTRTextFieldShadowColor [NSColor colorWithDeviceRed:0.19 green:0.51 blue:0.81 alpha:0.0]

@implementation BTRTextField {
	BOOL _btrDrawsBackground;
}

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self == nil) return nil;
	BTRTextFieldCommonInit(self);
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil) return nil;
	BTRTextFieldCommonInit(self);
	return self;
}

static void BTRTextFieldCommonInit(BTRTextField *textField) {
	textField.wantsLayer = YES;
	textField.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    textField.inactiveFieldColor = BTRTextFieldInactiveGradientStartingColor;
    textField.activeFieldColor = BTRTextFieldActiveGradientStartingColor;
	// Copy over *all* the attributes to the new cell
	// There really is no other easy way to do this :(
	NSTextFieldCell *oldCell = textField.cell;
	BTRTextFieldCell *newCell = [[BTRTextFieldCell alloc] initTextCell:textField.stringValue];
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
	[newCell setScrollable:[oldCell isScrollable]];
	[newCell setEditable:[oldCell isEditable]];
	[newCell setSelectable:[oldCell isSelectable]];
	textField.cell = newCell;
	textField.backgroundImages = [NSMutableDictionary dictionary];
	textField.actions = [NSMutableArray array];
	textField.needsTrackingArea = NO;
	textField.placeholderAttributes = [NSMutableDictionary dictionary];
	textField.placeholderTitle = [textField.textFieldCell.placeholderString copy];
	
	textField.focusRingType = NSFocusRingTypeNone;
	textField.drawsFocusRing = YES;
	textField.drawsBackground = YES;
	textField.bezeled = NO;
    
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
	return [BTRTextFieldCell class];
}

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	[self setNeedsDisplay:YES];
}

#pragma mark - Accessors

- (void)setDrawsFocusRing:(BOOL)drawsFocusRing {
	if (_drawsFocusRing != drawsFocusRing) {
		_drawsFocusRing = drawsFocusRing;
		if (_drawsFocusRing) {
			// Set up the layer styles used to draw a focus ring.
			NSShadow *shadow = [[NSShadow alloc] init];
			shadow.shadowBlurRadius = 2.f;
			shadow.shadowColor = BTRTextFieldShadowColor;
			shadow.shadowOffset = CGSizeZero;
			self.shadow = shadow;
		} else {
			NSShadow *shadow = [[NSShadow alloc] init];
			shadow.shadowBlurRadius = 0.f;
			shadow.shadowColor = [NSColor clearColor];
			self.shadow = shadow;
		}
	}
}

- (void)setDrawsBackground:(BOOL)flag {
	_btrDrawsBackground = flag;
	[self setNeedsDisplay:YES];
}

- (BOOL)drawsBackground {
	return _btrDrawsBackground;
}

- (BTRControlState)state {
	BTRControlState state = BTRControlStateNormal;
	if (self.isHighlighted) state |= BTRControlStateHighlighted;
	if (![self isEnabled]) state |= BTRControlStateDisabled;
	if (self.mouseHover && !self.isHighlighted) state |= BTRControlStateHover;
	return state;
}

- (void)setEnabled:(BOOL)enabled {
	[super setEnabled:enabled];
	[self handleStateChange];
}

- (NSTextFieldCell *)textFieldCell {
	return self.cell;
}

- (void)setTextFieldCell:(NSTextFieldCell *)textFieldCell {
	self.cell = textFieldCell;
}

- (void)setPlaceholderTitle:(NSString *)placeholderTitle {
	if (_placeholderTitle != placeholderTitle) {
		_placeholderTitle = placeholderTitle;
		[self resetPlaceholder];
	}
}

- (void)setPlaceholderTextColor:(NSColor *)placeholderColor {
	if (_placeholderTextColor != placeholderColor) {
		_placeholderTextColor = placeholderColor;
		self.placeholderAttributes[NSForegroundColorAttributeName] = placeholderColor;
		[self resetPlaceholder];
	}
}

- (void)setPlaceholderFont:(NSFont *)placeholderFont {
	if (_placeholderFont != placeholderFont) {
		_placeholderFont = placeholderFont;
		self.placeholderAttributes[NSFontAttributeName] = placeholderFont;
		[self resetPlaceholder];
	}
}

- (void)setPlaceholderAligment:(NSTextAlignment)placeholderAligment {
	if (_placeholderAligment != placeholderAligment) {
		_placeholderAligment = placeholderAligment;
		[self resetPlaceholder];
	}
}

- (void)setPlaceholderShadow:(NSShadow *)placeholderShadow{
	if (_placeholderShadow != placeholderShadow) {
		_placeholderShadow = placeholderShadow;
		self.placeholderAttributes[NSShadowAttributeName] = placeholderShadow;
		[self resetPlaceholder];
	}
}

- (void)resetPlaceholder {
	if ([self.placeholderTitle length]) {
        NSMutableAttributedString *holder = [[NSMutableAttributedString alloc] initWithString:self.placeholderTitle attributes:self.placeholderAttributes];
        [holder setAlignment:self.placeholderAligment range:holder.range];
		self.textFieldCell.placeholderAttributedString = holder;
	}
}

- (void)setFont:(NSFont *)fontObj {
	[super setFont:fontObj];
	if (!self.placeholderFont)
		self.placeholderFont = fontObj;
}

- (void)setTextColor:(NSColor *)color {
	[super setTextColor:color];
	if (!self.placeholderTextColor)
		self.placeholderTextColor = color;
}

- (void)setTextShadow:(NSShadow *)textShadow {
	if (_textShadow != textShadow) {
		_textShadow = textShadow;
		[self updateAttributedString];
		
		if (!self.placeholderShadow)
			self.placeholderShadow = textShadow;
	}
}

- (void)setStringValue:(NSString *)aString {
	[super setStringValue:aString];
	[self updateAttributedString];
}

- (void)updateAttributedString {
	NSMutableAttributedString *attrString = self.attributedStringValue.mutableCopy;
	NSRange wholeRange = NSMakeRange(0, attrString.length);
	void (^removeOrAddAttribute)(NSString *, id) = ^(NSString *key, id value) {
		if (value) {
			[attrString addAttribute:key value:value range:wholeRange];
		} else {
			[attrString removeAttribute:key range:wholeRange];
		}
	};
	
	[attrString beginEditing];
	removeOrAddAttribute(NSShadowAttributeName, self.textShadow);
	removeOrAddAttribute(NSForegroundColorAttributeName, self.textColor);
	removeOrAddAttribute(NSFontAttributeName, self.font);
	[attrString endEditing];

	self.attributedStringValue = attrString;
}

#pragma mark Drawing

- (void)drawBackgroundInRect:(NSRect)rect {
    
	if (!self.drawsBackground) return;
	NSImage *image = [self backgroundImageForControlState:self.state] ?: [self backgroundImageForControlState:BTRControlStateNormal];
	if (image) {
		[image drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.f];
	} else {
		[BTRTextFieldBorderColor set];
		if (![self isFirstResponder])
			[[NSBezierPath bezierPathWithRoundedRect:rect
											 xRadius:BTRTextFieldCornerRadius
											 yRadius:BTRTextFieldCornerRadius] fill];
		
		NSGradient *gradient = nil;
		CGRect borderRect = rect;
		borderRect.size.height -= 1, borderRect.origin.y += 1;
		if([self isFirstResponder]) {
			gradient = [[NSGradient alloc] initWithStartingColor:self.activeFieldColor
													 endingColor:self.activeFieldColor];
		} else {
			gradient = [[NSGradient alloc] initWithStartingColor:self.inactiveFieldColor
													 endingColor:self.inactiveFieldColor];
		}
		[gradient drawInBezierPath:[NSBezierPath bezierPathWithRoundedRect:borderRect xRadius:BTRTextFieldCornerRadius yRadius:BTRTextFieldCornerRadius] angle:-90];
		
		[BTRTextFieldFillColor set];
		CGRect innerRect = NSInsetRect(rect, 1, 2);
		innerRect.size.height += 1;
		[[NSBezierPath bezierPathWithRoundedRect:innerRect xRadius:BTRTextFieldInnerRadius yRadius:BTRTextFieldInnerRadius] fill];
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
	return _backgroundImages[@(state)];
}

-(void)setInactiveFieldColor:(NSColor *)inactiveFieldColor {
    self->_inactiveFieldColor = inactiveFieldColor;
    [self setNeedsDisplay:YES];
}

-(void)setActiveFieldColor:(NSColor *)activeFieldColor {
    self->_activeFieldColor = activeFieldColor;
    [self setNeedsDisplay:YES];
}



- (void)setBackgroundImage:(NSImage *)image forControlState:(BTRControlState)state {
	_backgroundImages[@(state)] = image;
	[self updateState];
}

- (void)updateState {
	NSImage *backgroundImage = [self backgroundImageForControlState:self.state];
	if (backgroundImage == nil) {
		backgroundImage = [self backgroundImageForControlState:BTRControlStateNormal];
	}
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
	//[self.layer addAnimation:[self shadowOpacityAnimation] forKey:nil];
//	self.layer.shadowOpacity = 1.f;
	self.btrHighlighted = YES;
	return [super becomeFirstResponder];
}


- (void)textDidEndEditing:(NSNotification *)notification {
	//[self.layer addAnimation:[self shadowOpacityAnimation] forKey:nil];
	//self.layer.shadowOpacity = 0.f;
	[super textDidEndEditing:notification];
	self.btrHighlighted = NO;
}

- (void)textDidChange:(NSNotification *)notification {
	[super textDidChange:notification];
	
	NSTextView *fieldEditor = (NSTextView *)[[self window] fieldEditor:YES forObject:self];
	if (self.textShadow && fieldEditor) {
		[fieldEditor.textStorage addAttribute:NSShadowAttributeName value:self.textShadow range:NSMakeRange(0, fieldEditor.textStorage.length)];
	}
	
	// This hack is needed because in certain cases (e.g. when inside a popover), a layer backed text view will not redraw by itself
	[self setNeedsDisplay:YES];
}

#pragma mark - Subclassing Hooks

- (NSRect)drawingRectForProposedDrawingRect:(NSRect)rect {
	return NSInsetRect(rect, self.fieldXInset, 0.f);
}

- (NSRect)editingRectForProposedEditingRect:(NSRect)rect {
	return rect;
}

- (void)setFieldEditorAttributes:(NSTextView *)fieldEditor {

}

@end

// Originally written by Daniel Jalkut as RSVerticallyCenteredTextFieldCell
// Licensed under MIT
// <http://www.red-sweater.com/blog/148/what-a-difference-a-cell-makes>
@implementation BTRTextFieldCell {
	BOOL _isEditingOrSelecting;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSRect integralFrame = NSIntegralRect(cellFrame);
	BTRTextField *textField = (BTRTextField *)controlView;
	[textField drawBackgroundInRect:integralFrame];
	if (textField.btrHighlighted && ![textField.stringValue length]) {
		NSRect placeholderRect = [self drawingRectForBounds:cellFrame];
		placeholderRect.origin.x += 2.f;
		//[self.placeholderAttributedString drawInRect:placeholderRect];
	}
	[super drawInteriorWithFrame:integralFrame inView:controlView];
	self.didRedrawAfterTextChange = YES;
}

- (NSRect)drawingRectForBounds:(NSRect)theRect {
	// Get the parent's idea of where we should draw
	NSRect newRect = [super drawingRectForBounds:theRect];
	
	// When the text field is being
	// edited or selected, we have to turn off the magic because it screws up
	// the configuration of the field editor.  We sneak around this by
	// intercepting selectWithFrame and editWithFrame and sneaking a
	// reduced, centered rect in at the last minute.
	if (!_isEditingOrSelecting) {
		// Get our ideal size for current text
		NSSize textSize = [self cellSizeForBounds:theRect];
		
		// Center that in the proposed rect
		CGFloat heightDelta = newRect.size.height - textSize.height;
		if (heightDelta > 0)
		{
			newRect.size.height -= heightDelta;
			newRect.origin.y += ceil(heightDelta / 2);
		}
	}
	return [(BTRTextField *)[self controlView] drawingRectForProposedDrawingRect:newRect];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
	aRect = [(BTRTextField *)[self controlView] editingRectForProposedEditingRect:[self drawingRectForBounds:aRect]];
	_isEditingOrSelecting = YES;
	[super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	_isEditingOrSelecting = NO;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
	aRect = [(BTRTextField *)[self controlView] editingRectForProposedEditingRect:[self drawingRectForBounds:aRect]];
	_isEditingOrSelecting = YES;
	[super editWithFrame:aRect inView:controlView editor:textObj delegate:anObject event:theEvent];
	_isEditingOrSelecting = NO;
}

- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj {
	NSTextView *editor = (NSTextView *)[super setUpFieldEditorAttributes:textObj];
	[(BTRTextField *)[self controlView] setFieldEditorAttributes:editor];
	return editor;
}

@end
