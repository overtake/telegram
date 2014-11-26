//
//  BTRPopUpButton.m
//  Butter
//
//  Created by Indragie Karunaratne on 2012-12-30.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//

#import "BTRPopUpButton.h"
#import "BTRLabel.h"

@interface BTRPopUpButtonLabel : BTRLabel
@end
@interface BTRPopUpButtonImageView : BTRImageView
@end

@interface BTRPopUpButton ()
@property (nonatomic, strong) BTRImageView *imageView;
@property (nonatomic, strong) BTRLabel *label;

@property (nonatomic, strong) BTRImageView *backgroundImageView;
@property (nonatomic, strong) BTRImageView *arrowImageView;

@property (nonatomic, strong) id notificationObserver;
@end

@interface BTRPopUpButtonContent : BTRControlContent
@property (nonatomic, strong) NSImage *arrowImage;
@end

@implementation BTRPopUpButton

#pragma mark - Initialization

static void BTRPopupButtonCommonInit(BTRPopUpButton *self) {
	self.label = [[BTRPopUpButtonLabel alloc] initWithFrame:NSZeroRect];
	self.imageView = [[BTRPopUpButtonImageView alloc] initWithFrame:NSZeroRect];
	self.imageView.contentMode = BTRViewContentModeCenter;
	self.arrowImageView = [[BTRPopUpButtonImageView alloc] initWithFrame:NSZeroRect];
	self.arrowImageView.contentMode = BTRViewContentModeCenter;
	self.backgroundImageView = [[BTRPopUpButtonImageView alloc] initWithFrame:NSZeroRect];
	
	self.layer.masksToBounds = YES;
	[self addSubview:self.backgroundImageView];
	[self addSubview:self.imageView];
	[self addSubview:self.label];
	[self addSubview:self.arrowImageView];
	
	// Observe changes to the menu's delegate. When the delegate changes
	// we want to force a menu refresh if the delegate has implemented the
	// menu update methods declared in the NSMenuDelegate protocol.
	[self addObserver:self forKeyPath:@"menu.delegate" options:NSKeyValueObservingOptionNew context:NULL];
	
	[self accessibilitySetOverrideValue:NSAccessibilityPopUpButtonRole forAttribute:NSAccessibilityRoleAttribute];
	[self accessibilitySetOverrideValue:NSAccessibilityRoleDescription(NSAccessibilityPopUpButtonRole, nil) forAttribute:NSAccessibilityRoleDescriptionAttribute];
	
}

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	BTRPopupButtonCommonInit(self);
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil) return nil;
	BTRPopupButtonCommonInit(self);
	return self;
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"menu.delegate"];
	if (self.notificationObserver) {
		[NSNotificationCenter.defaultCenter removeObserver:self.notificationObserver];
	}
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// Force a menu update when the delegate changes
	if ([keyPath isEqualToString:@"menu.delegate"]) {
		[self forceMenuUpdate];
	}
}

#pragma mark - Accessibility

- (NSArray *)accessibilityActionNames {
	return @[NSAccessibilityPressAction, NSAccessibilityShowMenuAction];
}

- (NSString *)accessibilityActionDescription:(NSString *)action {
	return NSAccessibilityActionDescription(action);
}

- (void)accessibilityPerformAction:(NSString *)action {
	if ([action isEqualToString:NSAccessibilityPressAction] || [action isEqualToString:NSAccessibilityShowMenuAction]) {
		[self showMenuWithEvent:nil];
	}
}

#pragma mark - BTRControl

+ (Class)controlContentClass {
	return [BTRPopUpButtonContent class];
}

- (BTRPopUpButtonContent *)popUpButtonContentForState:(BTRControlState)state {
	return (BTRPopUpButtonContent *)[self contentForControlState:state];
}

- (void)handleStateChange {
	NSString *title = self.selectedItem.title;
	if (title) {
		self.label.textColor = self.currentTitleColor;
		self.label.font = self.currentTitleFont;
		self.label.stringValue = title;
		self.label.textShadow = self.currentTitleShadow;
	} else {
		self.label.stringValue = @"";
	}
	self.arrowImageView.image = self.currentArrowImage;
	self.backgroundImageView.image = self.currentBackgroundImage;
	self.imageView.image = self.selectedItem.image;
}

#pragma mark - Public Methods

- (NSImage *)arrowImageForControlState:(BTRControlState)state {
	return [self popUpButtonContentForState:state].arrowImage;
}

- (void)setArrowImage:(NSImage *)image forControlState:(BTRControlState)state {
	[self popUpButtonContentForState:state].arrowImage = image;
}

- (NSImage *)currentArrowImage {
	return [self popUpButtonContentForState:self.state].arrowImage ?: [self popUpButtonContentForState:BTRControlStateNormal].arrowImage;
}

- (void)selectItemAtIndex:(NSUInteger)index {
	self.selectedItem = [self.menu itemAtIndex:index];
}

- (NSUInteger)indexOfSelectedItem {
	return [self.menu indexOfItem:self.selectedItem];
}

#pragma mark - Accessors

- (void)setBtrMenu:(NSMenu *)menu {
	if (_btrMenu != menu) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		if (self.notificationObserver) {
			[nc removeObserver:self.notificationObserver];
			self.notificationObserver = nil;
		}
		self.selectedItem = nil;
		_btrMenu = menu;
		if (_btrMenu) {
			_btrMenu.autoenablesItems = self.autoenablesItems;
			// Register for notifications for when the menu closes. This is important
			// because mouseUp: and mouseExited: are not normally called if the menu is closed
			// when the cursor is outside the pop up button. This ensures that the proper
			// state is restored once the menu is closed.
			__weak BTRPopUpButton *weakSelf = self;
			
			self.notificationObserver = [nc addObserverForName:NSMenuDidEndTrackingNotification object:_btrMenu queue:nil usingBlock:^(NSNotification *note) {
				BTRPopUpButton *strongSelf = weakSelf;
				
				[strongSelf mouseUp:nil];
				[strongSelf mouseExited:nil];
				[strongSelf accessibilitySetOverrideValue:nil forAttribute:NSAccessibilityShownMenuAttribute];
			}];
			
			// Force a menu update from the delegate once the menu is initially set
			[self forceMenuUpdate];
		}
	}
}

- (void)setSelectedItem:(NSMenuItem *)selectedItem {
	if (_selectedItem != selectedItem) {
		_selectedItem.state = NSOffState;
		_selectedItem = selectedItem;
		_selectedItem.state = NSOnState;
		[self handleStateChange];
		[self setNeedsLayout:YES];
		[self accessibilitySetOverrideValue:_selectedItem.title forAttribute:NSAccessibilityTitleAttribute];
	}
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
	if (_textAlignment != textAlignment) {
		_textAlignment = textAlignment;
		[self setNeedsLayout:YES];
	}
}

#pragma mark - NSMenu

- (void)reconfigureMenuItems {
	// Reset the target and action of each item so that the pop up button receives
	// the events when the items are clicked.
	[self.menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
		item.target = self;
		item.action = @selector(popUpMenuSelectedItem:);
	}];
	// Default to setting the first item in the menu as the selected item
	if ([self.menu numberOfItems] && !self.selectedItem) {
		self.selectedItem = [self.menu itemAtIndex:0];
		self.selectedItem.state = NSOnState;
	}
}

- (void)forceMenuUpdate {
	id delegate = self.menu.delegate;
	if (!delegate) {
		[self reconfigureMenuItems];
		return;
	}
	// This runs a delegate based update to the menu as documented by the NSMenuDelegate protocol.
	// First a check to see if -menuNeedsUpdate: is implemented. If so, this means that the delegate
	// takes complete control of handling the update in this one method, and no further
	// method calls are necessary
	if ([delegate respondsToSelector:@selector(menuNeedsUpdate:)]) {
		[delegate menuNeedsUpdate:self.menu];
	// The other update mechanism that the delegate provides are two "data source" type methods that
	// are called repetitively to update each item
	} else if ([delegate respondsToSelector:@selector(numberOfItemsInMenu:)] && [delegate respondsToSelector:@selector(menu:updateItem:atIndex:shouldCancel:)]) {
		NSInteger numberOfItems = [delegate numberOfItemsInMenu:self.menu];
		BOOL shouldCancel = NO;
		for (NSInteger i = 0; i < numberOfItems; i++) {
			shouldCancel = [delegate menu:self.menu updateItem:[self.menu itemAtIndex:i] atIndex:i shouldCancel:shouldCancel];
		}
	}
	[self reconfigureMenuItems];
}

#pragma mark - Layout

- (void)layout {
	self.imageView.frame = [self imageFrame];
	self.label.frame = [self labelFrame];
	self.arrowImageView.frame = [self arrowFrame];
	self.backgroundImageView.frame = self.bounds;
	[super layout];
}

- (NSRect)imageFrame {
	const NSSize imageSize = self.selectedItem.image.size;
	// Size the image rect to the exact height and width of the selected image
	return NSMakeRect([self edgeInset], roundf(NSMidY(self.bounds) - (imageSize.height / 2.f)), imageSize.width, imageSize.height);
}

- (NSRect)labelFrame {
	const NSRect imageFrame = [self imageFrame];
	const NSRect arrowFrame = [self arrowFrame];
	const CGFloat spacing = [self interElementSpacing];
	
	CGFloat maximumWidth = NSWidth(self.bounds) - NSMaxX(imageFrame) - NSWidth(arrowFrame) - [self edgeInset];
	if (NSWidth(imageFrame)) {
		maximumWidth -= spacing;
	}
	if (NSWidth(arrowFrame)) {
		maximumWidth -= spacing;
	}
	
	// Calling -sizeToFit modifies the frame of the label. This is necessary
	// to get accurate metrics for the intrinsic content size.
	[self.label sizeToFit];
	const CGFloat textWidth = fminf(NSWidth(self.label.frame), maximumWidth);
	CGFloat xOrigin;
	switch (self.textAlignment) {
		case NSRightTextAlignment:
			xOrigin = NSMinX(arrowFrame) - spacing - textWidth;
			break;
		case NSCenterTextAlignment:
			xOrigin = floorf(NSMidX(self.bounds) - (textWidth / 2.f));
			break;
		case NSLeftTextAlignment:
		default:
			xOrigin = NSMaxX(imageFrame) + spacing;
			break;
	}
	return NSMakeRect(xOrigin, 0.f, textWidth, NSHeight(self.bounds));
}

- (NSRect)arrowFrame {
	const NSSize arrowSize = self.currentArrowImage.size;
	// Size the arrow image to the exact height and width of the image
	return NSMakeRect(NSMaxX(self.bounds) - arrowSize.width - [self edgeInset], roundf(NSMidY(self.bounds) - (arrowSize.height / 2.f)), arrowSize.width, arrowSize.height);
}

- (CGFloat)interElementSpacing {
	return 3.f;
}

- (CGFloat)edgeInset {
	return 6.f;
}

- (CGFloat)widthToFit {
	// Need to tack on padding here because NSTextFieldCell does some weird padding stuff
	// that causes the actual drawing bounds of the text to be less than the width of the text field.
	// I've already tried a bunch of stuff like NSTextFieldCell's -cellSizeForBounds:, -drawingRectForBounds:,
	// and none of them return a properly sized rect.
	return NSWidth([self imageFrame]) + ceilf(self.label.attributedStringValue.size.width) + NSWidth([self arrowFrame]) + (2.f * [self edgeInset]) + (2.f * [self interElementSpacing]) + 4.f;
}

- (void)sizeToFit {
	NSRect newFrame = self.frame;
	newFrame.size.width = [self widthToFit];
	self.frame = newFrame;
	[self setNeedsLayout:YES];
}

#pragma mark - Mouse Events

- (void)mouseDown:(NSEvent *)theEvent {
	[super mouseDown:theEvent];
	[self showMenuWithEvent:theEvent];
}

- (void)showMenuWithEvent:(NSEvent *)event {
	if (!self.menu || !self.enabled || !self.userInteractionEnabled) return;
	
	NSPoint origin;
	NSRect imageFrame = [self imageFrame];
	if (NSWidth(imageFrame)) {
		origin = imageFrame.origin;
		// Offset to line up the menu item image
		// TODO: Figure out a better way to calculate this offset at runtime.
		// There are no geometry methods on NSMenu or NSMenuItem that would
		// allow the retrieval of layout information for menu items
		origin.x -= 22.f;
	} else {
		origin = [self labelFrame].origin;
	}
	origin.y = 0.f;
	// Synthesize an event just so we can change the location of the menu
	NSEvent *synthesizedEvent = [self synthesizedEventWithLocalMouseLocation:origin realEvent:event];
	[NSMenu popUpContextMenu:self.menu withEvent:synthesizedEvent forView:self];
	[self accessibilitySetOverrideValue:self.menu forAttribute:NSAccessibilityShownMenuAttribute];
}

- (NSEvent *)synthesizedEventWithLocalMouseLocation:(NSPoint)location realEvent:(NSEvent *)event {
	NSPoint windowPoint = [self convertPoint:location toView:nil];
	return [NSEvent mouseEventWithType:NSLeftMouseDown
							  location:windowPoint
						 modifierFlags:event.modifierFlags
							 timestamp:event.timestamp
						  windowNumber:self.window.windowNumber
							   context:event.context
						   eventNumber:event.eventNumber
							clickCount:event.clickCount ?: 1
							  pressure:event.pressure];
}

#pragma mark - Menu Events

- (IBAction)popUpMenuSelectedItem:(id)sender {
	self.selectedItem = sender;
	[self sendActionsForControlEvents:BTRControlEventValueChanged];
	[self handleStateChange];
}

@end

@implementation BTRPopUpButtonContent
- (void)setArrowImage:(NSImage *)arrowImage {
	if (_arrowImage != arrowImage) {
		_arrowImage = arrowImage;
		[self controlContentChanged];
	}
}

+ (NSDictionary *)defaultTitleAttributes {
	NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
	style.lineBreakMode = NSLineBreakByTruncatingTail;
	style.alignment = NSLeftTextAlignment;
	return @{NSParagraphStyleAttributeName: style};
}
@end

// Prevent the subviews from receiving mouse events
@implementation BTRPopUpButtonLabel {
	BOOL _isEditing;
}
- (NSView *)hitTest:(NSPoint)aPoint {
	return _isEditing ? [super hitTest:aPoint] : nil;
}

- (BOOL)becomeFirstResponder {
	_isEditing = YES;
	return [super becomeFirstResponder];
}

- (NSRect)drawingRectForProposedDrawingRect:(NSRect)rect {
	return rect;
}

@end

@implementation BTRPopUpButtonImageView

- (NSView *)hitTest:(NSPoint)aPoint { return nil; }

@end