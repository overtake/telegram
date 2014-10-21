//
//  RBLSlidingContainerView
//  Rebel
//
//  Created by Alan Rogers on 4/02/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "RBLSlidingContainerView.h"
#import "NSView+RBLAnimationAdditions.h"
#import <QuartzCore/QuartzCore.h>

static const NSTimeInterval RBLTransitioningContainerViewResizeAnimationDuration = 0.2;
static const NSTimeInterval RBLTransitioningContainerViewSlideAnimationDuration = 0.3;

@interface RBLSlidingContainerView ()

// A temporary constraint used to change the height of the receiver.
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

// A temporary constraint used to change the height of the receiver.
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

@implementation RBLSlidingContainerView

#pragma mark NSView

+ (BOOL)requiresConstraintBasedLayout {
	return YES;
}

#pragma mark contentView

- (void)setContentView:(NSView *)contentView {
	[self setContentView:contentView direction:RBLSlidingContainerViewSlideDirectionNone completion:nil];
}

- (void)setContentView:(NSView *)contentView direction:(RBLSlidingContainerViewSlideDirection)direction {
	[self setContentView:contentView direction:direction completion:nil];
}

- (void)setContentView:(NSView *)contentView direction:(RBLSlidingContainerViewSlideDirection)direction completion:(void (^)(void))completionBlock {
	BOOL animated = (direction != RBLSlidingContainerViewSlideDirectionNone);

	// We want our new containerView fully laid out before we continue (it's
	// usually lazy)
	[contentView layoutSubtreeIfNeeded];

	void(^replaceContentView)(void) = ^{
		[self.contentView.rbl_animator removeFromSuperview];
		[self.rbl_animator addSubview:contentView];
		_contentView = contentView;
	};
	void (^completeTransition)(void) = ^{
		if (animated) {
			self.wantsLayer = NO;
		}
		[self removeConstraints:self.constraints];

		// Add required fitting constraints so that the contentView fits
		// snugly in the containerView
		self.verticalContainerConstraints = [NSLayoutConstraint
			constraintsWithVisualFormat:@"V:|[contentView]|"
			options:0
			metrics:0
			views:@{ @"contentView": self.contentView }];
		self.horizontalContainerConstraints = [NSLayoutConstraint
			constraintsWithVisualFormat:@"H:|[contentView]|"
			options:0
			metrics:0
			views:@{ @"contentView": self.contentView }];

		[self addConstraints:self.verticalContainerConstraints];
		[self addConstraints:self.horizontalContainerConstraints];

		self.animations = nil;

		if (completionBlock != nil) completionBlock();
	};
	
	if (!animated) {
		replaceContentView();
		completeTransition();
		return;
	}

	self.wantsLayer = YES;
	[self addAnimationConstraintsWithStartingSize:self.contentView.frame.size];

	[NSView rbl_animateWithDuration:RBLTransitioningContainerViewResizeAnimationDuration animations:^{
		[self.heightConstraint.animator setConstant:contentView.frame.size.height];
		[self.widthConstraint.animator setConstant:contentView.frame.size.width];
	}
	completion:^{
		CATransition *transition = [CATransition animation];
		transition.type = kCATransitionPush;
		transition.subtype = (direction == RBLSlidingContainerViewSlideDirectionFromLeft ? kCATransitionFromLeft : kCATransitionFromRight);
		transition.duration = RBLTransitioningContainerViewSlideAnimationDuration;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

		self.animations = @{ @"subviews" : transition };
		[NSView rbl_animateWithDuration:RBLTransitioningContainerViewSlideAnimationDuration animations:replaceContentView completion:completeTransition];
	}];
}

#pragma mark Private

- (void)addAnimationConstraintsWithStartingSize:(CGSize)size {
	[self removeConstraints:self.constraints];
	self.heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:0 constant:size.height];

	self.widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:0 constant:size.width];

	[self addConstraints:@[ self.heightConstraint, self.widthConstraint ]];

	// We use NSLayoutPriorityDefaultHigh because so that our contentView
	// will sit at the top left while the containerView changes its bounds
	// around it during the animation.
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
