//
//  BTRButton.m
//  Butter
//
//  Created by Jonathan Willing on 12/21/12.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//

#import "BTRButton.h"
#import "BTRLabel.h"

// Subclasses to override -hitTest: and prevent them from receiving mouse events
@interface BTRButtonLabel : BTRLabel
@end

@interface BTRButtonImageView : BTRImageView
@end

@implementation BTRButton {
	BTRButtonImageView *_imageView;
}

#pragma mark - Initialization

static void BTRButtonCommonInit(BTRButton *self) {
	self->_backgroundImageView = [[BTRButtonImageView alloc] initWithFrame:self.bounds];
	[self addSubview:self->_backgroundImageView];
	self->_titleLabel = [[BTRButtonLabel alloc] initWithFrame:self.bounds];
	[self addSubview:self->_titleLabel];
    
    self->_imageView = [[BTRButtonImageView alloc] initWithFrame:self.bounds];
    self->_imageView.contentMode = BTRViewContentModeScaleAspectFit;
    [self addSubview:self->_imageView];
    
	[self accessibilitySetOverrideValue:NSAccessibilityButtonRole forAttribute:NSAccessibilityRoleAttribute];
	[self accessibilitySetOverrideValue:NSAccessibilityRoleDescription(NSAccessibilityButtonRole, nil) forAttribute:NSAccessibilityRoleDescriptionAttribute];
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self layout];
    self->_backgroundImageView.frame = [self backgroundImageFrame];
	self->_titleLabel.frame = [self labelFrame];
}

-(void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
}

-(void)setFrameOrigin:(NSPoint)newOrigin {
    [super setFrameOrigin:newOrigin];
}

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;
	BTRButtonCommonInit(self);
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil) return nil;
	BTRButtonCommonInit(self);
	return self;
}

#pragma mark - Accessibility

- (NSArray *)accessibilityActionNames {
	return @[NSAccessibilityPressAction];
}

- (NSString *)accessibilityActionDescription:(NSString *)action {
	return NSAccessibilityActionDescription(action);
}

- (void)accessibilityPerformAction:(NSString *)action {
	if ([action isEqualToString:NSAccessibilityPressAction]) {
		[self performClick:nil];
	}
}

#pragma mark - Accessors


#pragma mark - State

- (void)handleStateChange {
	self.backgroundImageView.image = self.currentBackgroundImage;
    
    NSImage *currentImage = self.currentImage;
    self.imageView.image = currentImage;
    self.imageView.frame = [self imageFrame];
  
   
    self.titleLabel.attributedStringValue = self.currentAttributedTitle;
    
    if(self.opacityHover) {
        if(self.state & BTRControlStateHover) {
            [self setAlphaValue:1.0];
        } else {
            [self setAlphaValue:0.8];
        }
    }
}

#pragma mark - Drawing

- (void)layout {
	self->_backgroundImageView.frame = [self backgroundImageFrame];
	self->_titleLabel.frame = [self labelFrame];
//	if (_imageView) {
		self.imageView.frame = [self imageFrame];
//	}
	[super layout];
}

- (void)setBackgroundContentMode:(BTRViewContentMode)backgroundContentMode {
	self.backgroundImageView.contentMode = backgroundContentMode;
}

- (BTRViewContentMode)contentMode {
	return self.backgroundImageView.contentMode;
}

- (void)setImageContentMode:(BTRViewContentMode)imageContentMode {
	self.imageView.contentMode = imageContentMode;
}

- (BTRViewContentMode)imageContentMode {
	return self.imageView.contentMode;
}

// When a button is clicked, the initial state change shouldn't animate
// or it will appear to be laggy. However, if the user has opted to animate
// the contents, we animate the transition back out.
- (void)setHighlighted:(BOOL)highlighted {
	BOOL animatesFlag = self.animatesContents;
	BOOL shouldAnimate = (!highlighted && animatesFlag);
	self.imageView.animatesContents = shouldAnimate;
	self.backgroundImageView.animatesContents = shouldAnimate;
	[super setHighlighted:highlighted];
	self.imageView.animatesContents = animatesFlag;
	self.backgroundImageView.animatesContents = animatesFlag;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
	[super setCornerRadius:cornerRadius];
	self.backgroundImageView.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
	return self.backgroundImageView.cornerRadius;
}

#pragma mark - Mouse Events

//commented by keepcoder -- wtf man??

//- (void)mouseDragged:(NSEvent *)theEvent {
//	// Override to prevent superviews from receiving mouse dragged events
//	// when the button is dragged.
//}

#pragma mark - Subclassing Hooks

- (CGRect)imageFrame {
    NSSize size = self.imageView.image.size;
    NSSize boundsSize = self.bounds.size;
    
    NSPoint newPoint = NSMakePoint(roundf((boundsSize.width - size.width) / 2.f), roundf((boundsSize.height - size.height) / 2.f));
    
    return CGRectMake(newPoint.x, newPoint.y, size.width, size.height);
}

- (CGRect)backgroundImageFrame {
	return self.bounds;
}

- (CGRect)labelFrame {
    CGRect labelFra = self.bounds;
    labelFra.size.height += self.heightBugFix;
	return labelFra;
}

@end

@implementation BTRButtonLabel
- (NSView *)hitTest:(NSPoint)aPoint { return nil; }
@end

@implementation BTRButtonImageView
- (NSView *)hitTest:(NSPoint)aPoint { return nil; }
@end
