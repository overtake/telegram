//
//  BTRControl.h
//  Butter
//
//  Created by Jonathan Willing on 12/14/12.
//  Copyright (c) 2012 ButterKit. All rights reserved.

// This class is heavily inspired by UIKit and TwUI.
#import "BTRView.h"

@class BTRControl;

@interface BTRControlHiglighted : NSObject

+ (BTRControlHiglighted *)instance;

@property (nonatomic, strong) BTRControl *control;

@end

typedef enum {
   	BTRControlEventMouseDragEnter		= 1 << 1,
	BTRControlEventMouseDragExit		= 1 << 2,
	// ***************
	
	BTRControlEventMouseUpInside		= 1 << 3,
	BTRControlEventMouseDownInside		= 1 << 4,
	BTRControlEventMouseUpOutside		= 1 << 5,
	BTRControlEventMouseEntered			= 1 << 6,
	BTRControlEventMouseExited			= 1 << 7,
	
	BTRControlEventClick				= 1 << 12, //after mouse down & up inside
	BTRControlEventClickRepeat			= 1 << 13,
	BTRControlEventLeftClick			= 1 << 14,
	BTRControlEventRightClick			= 1 << 15,
	
	BTRControlEventValueChanged			= 1 << 16, // sliders, etc.
    BTRControlEventLongLeftClick		= 1 << 17
} BTRControlEvents;


typedef enum {
	BTRControlStateNormal		= 0,
	BTRControlStateHighlighted	= 1 << 0,
	BTRControlStateDisabled		= 1 << 1,
	BTRControlStateSelected		= 1 << 2,
	BTRControlStateHover		= 1 << 3
} BTRControlState;

// State key constants for use with `-currentValueForControlStateKey:`
extern NSString * const BTRControlStateTitleKey;
extern NSString * const BTRControlStateTitleColorKey;
extern NSString * const BTRControlStateTitleShadowKey;
extern NSString * const BTRControlStateTitleFontKey;
extern NSString * const BTRControlStateAttributedTitleKey;
extern NSString * const BTRControlStateImageKey;
extern NSString * const BTRControlStateBackgroundImageKey;
extern NSString * const BTRControlStateCursorKey;


@class BTRControlContent;
@interface BTRControl : BTRView

- (void)addBlock:(void (^)(BTRControlEvents events))block forControlEvents:(BTRControlEvents)events;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(BTRControlEvents)events;

@property (nonatomic, readonly) NSInteger clickCount;

@property (nonatomic) BOOL needsTrackingArea;

@property (nonatomic, readonly) BTRControlState state;
@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, getter = isHover) BOOL hovered;

@property (nonatomic, getter = isUserInteractionEnabled) BOOL userInteractionEnabled;

// Implemented by subclasses. Useful for reacting to state changes caused either by
// mouse events, or by changing the state properties above.
- (void)handleStateChange;

// This method should be called by subclasses
- (void)sendActionsForControlEvents:(BTRControlEvents)events;

// Sends actions for the `BTRControlClick` event, provided that `enabled` and
// `userInteractionEnabled` are equal to `YES`.
- (IBAction)performClick:(id)sender;

// This is the dynamic version of the `current*` property getters.
//
// Unless explicitly defined in your own subclasses, state keys passed into this method
// should be limited to those defined in the `BTRControlState*Key` constants.
//
// Returns the current value for the given control state key.
- (id)currentValueForControlStateKey:(NSString *)key;

// Implemented by subclasses. Use it to return a subclass of BTRControlContent that
// contains additional content properties pertaining to the specific control.
+ (Class)controlContentClass;

// Returns the content (BTRControlContent or a subclass, if one was
// returned from +controlContentClass) for the given control state.
// A new content object will be created if one does not exist
- (BTRControlContent *)contentForControlState:(BTRControlState)state;

// General properties for controls
// Your control subclass can add more methods and properties similar to this
@property (nonatomic, strong, readonly) NSString *currentTitle;
@property (nonatomic, strong, readonly) NSAttributedString *currentAttributedTitle;
@property (nonatomic, strong, readonly) NSImage *currentImage;
@property (nonatomic, strong, readonly) NSImage *currentBackgroundImage;
@property (nonatomic, strong, readonly) NSColor *currentTitleColor;
@property (nonatomic, strong, readonly) NSShadow *currentTitleShadow;
@property (nonatomic, strong, readonly) NSFont *currentTitleFont;
@property (nonatomic, strong, readonly) NSCursor *currentCursor;

- (NSImage *)backgroundImageForControlState:(BTRControlState)state;
- (void)setBackgroundImage:(NSImage *)image forControlState:(BTRControlState)state;

- (NSImage *)imageForControlState:(BTRControlState)state;
- (void)setImage:(NSImage *)image forControlState:(BTRControlState)state;

- (NSString *)titleForControlState:(BTRControlState)state;
- (void)setTitle:(NSString *)title forControlState:(BTRControlState)state;

- (NSAttributedString *)attributedTitleForControlState:(BTRControlState)state;
- (void)setAttributedTitle:(NSAttributedString *)title forControlState:(BTRControlState)state;

- (NSColor *)titleColorForControlState:(BTRControlState)state;
- (void)setTitleColor:(NSColor *)color forControlState:(BTRControlState)state;

- (NSShadow *)titleShadowForControlState:(BTRControlState)state;
- (void)setTitleShadow:(NSShadow *)shadow forControlState:(BTRControlState)state;

- (NSFont *)titleFontForControlState:(BTRControlState)state;
- (void)setTitleFont:(NSFont *)font forControlState:(BTRControlState)state;

- (NSCursor *)cursorForControlState:(BTRControlState)state;
- (void)setCursor:(NSCursor *)cursor forControlState:(BTRControlState)state;


@end

@interface BTRControlContent : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSAttributedString *attributedTitle;
@property (nonatomic, strong) NSColor *titleColor;
@property (nonatomic, strong) NSShadow *titleShadow;
@property (nonatomic, strong) NSFont *titleFont;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *backgroundImage;
@property (nonatomic, strong) NSCursor *cursor;

// Any setter on a BTRControlContent subclass should always call the
// -controlContentChanged method in order to notify the control of the
// change. TODO: See if there is a way to monitor all properties for
// change so that each setter individually doesn't need to call the method
- (void)controlContentChanged;

// Subclasses can use this to return text attributes that the
// attributedTitle should use by default
+ (NSDictionary *)defaultTitleAttributes;

@end
