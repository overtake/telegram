//
//  RBLExpandingContainerView.m
//  Rebel
//
//  Created by Alan Rogers on 4/02/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "RBLExpandingContainerView.h"
#import "NSView+RBLAnimationAdditions.h"

static const NSTimeInterval RBLExpandingContainerViewAnimationDuration = 0.2;

@interface RBLExpandingContainerView ()

// A temporary constraint used to change the height of the receiver.
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

// A temporary constraint used to change the width of the receiver.
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;

// Constraints that keep the contentView horizontally contained
// within the receiver.
//
// The leading constraint to the superview is always required.
// The trailing constraint to the superview is not required during animation,
// but required when animation is complete. This has the effect of pinning
// the contentView to the leading edge of the receiver during the bounds change
// animation.
@property (nonatomic, strong) NSArray *horizontalContainerConstraints;

// Constraints that keep the contentView horizontally contained
// within the receiver.
//
// The top constraint to the superview is always required.
// The bottom constraint to the superview is not required during animation,
// but required when animation is complete. This has the effect of pinning
// the contentView to the top edge of the receiver during the bounds change
// animation.
@property (nonatomic, strong) NSArray *verticalContainerConstraints;

@end

@implementation RBLExpandingContainerView

#pragma mark NSView

+ (BOOL)requiresConstraintBasedLayout {
	return YES;
}

#pragma mark contentView

- (void)setContentView:(NSView *)contentView {
	[self setContentView:contentView animated:NO];
}

- (void)setContentView:(NSView *)contentView animated:(BOOL)animated {
	[self setContentView:contentView animated:animated completion:nil];
}

- (void)setContentView:(NSView *)contentView animated:(BOOL)animated completion:(void (^)(void))completionBlock {
	CGSize startingSize = self.contentView.frame.size;

	// Remove the existing contentView
	[self.contentView removeFromSuperview];

	// We want our new containerView fully laid out before we continue (it's
	// usually lazy)
	[contentView layoutSubtreeIfNeeded];

	[self addSubview:contentView];
	_contentView = contentView;

	void (^completeExpansion)() = ^{
		if (animated) self.wantsLayer = NO;

		// Just remove all constraints as we only want the ones below
		[self removeConstraints:self.constraints];

		// Add required fitting constraints so that the contentView fits
		// snugly in the containerView
		self.verticalContainerConstraints = [NSLayoutConstraint
			constraintsWithVisualFormat:@"V:|[contentView]|"
			options:0
			metrics:nil
			views:@{ @"contentView": self.contentView }];
		self.horizontalContainerConstraints = [NSLayoutConstraint
			constraintsWithVisualFormat:@"H:|[contentView]|"
			options:0
			metrics:nil
			views:@{ @"contentView": self.contentView }];

		[self addConstraints:self.verticalContainerConstraints];
		[self addConstraints:self.horizontalContainerConstraints];

		if (completionBlock != nil) completionBlock();
	};
	
	if (!animated) {
		completeExpansion();
		return;
	}

	self.wantsLayer = YES;
	[self addAnimationConstraintsWithStartingSize:startingSize];
	[NSView rbl_animateWithDuration:RBLExpandingContainerViewAnimationDuration animations:^{
		[self.heightConstraint.animator setConstant:self.contentView.frame.size.height];
		[self.widthConstraint.animator setConstant:self.contentView.frame.size.width];
	} completion:completeExpansion];
}

#pragma mark Private

- (void)addAnimationConstraintsWithStartingSize:(CGSize)size {
	[self removeConstraints:self.constraints];
	
	self.heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:0 constant:size.height];

	self.widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:0 constant:size.width];

	[self addConstraints:@[ self.heightConstraint, self.widthConstraint ]];

	// We use NSLayoutPriorityDefaultHigh so that our contentView will sit at
	// the top left while the containerView changes its bounds around it during
	// the animation.
	self.verticalContainerConstraints = [NSLayoutConstraint
		constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[contentView]-(0@%d)-|", NSLayoutPriorityDefaultHigh]
		options:0
		metrics:0
		views:@{ @"contentView": self.contentView }];
	self.horizontalContainerConstraints = [NSLayoutConstraint
		constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|[contentView]-(0@%d)-|", NSLayoutPriorityDefaultHigh]
		options:0
		metrics:0
		views:@{ @"contentView": self.contentView }];

	[self addConstraints:self.verticalContainerConstraints];
	[self addConstraints:self.horizontalContainerConstraints];
}

@end
