//
//  RBLSlidingContainerView.h
//  Rebel
//
//  Created by Alan Rogers on 4/02/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

// Defines the different types of animation used to transition the contentView
// in a RBLSlidingContainerView.
//
// RBLSlidingContainerViewSlideDirectionNone      - No animation is used to
//                                                  transition the contentView.
// RBLSlidingContainerViewSlideDirectionFromLeft  - The containerView is first
//                                                  animated to match the bounds
//                                                  of the new contentView, then
//                                                  the old contentView slides
//                                                  away to the right as the new
//                                                  contentView slides in from
//                                                  the left.
// RBLSlidingContainerViewSlideDirectionFromRight - The containerView is first
//                                                  animated to match the bounds
//                                                  of the new contentView, then
//                                                  the old contentView slides
//                                                  away to the left as the new
//                                                  contentView slides in from
//                                                  the right.
typedef enum : NSUInteger {
	RBLSlidingContainerViewSlideDirectionNone = 0,
	RBLSlidingContainerViewSlideDirectionFromLeft,
	RBLSlidingContainerViewSlideDirectionFromRight
} RBLSlidingContainerViewSlideDirection;

// A view class that uses Auto Layout to adjust its bounds to fit
// a new contentView. It can conditionally animate this change including a
// CoreAnimation slide transition. During the bounds change,
// the contentView is pinned to the top left.
//
// NOTE: You must use to the provided -setContentView: methods to change the
// subview. Calling any of the normal subview mutating methods on the receiver
// will result in undefined behavior.
// IMPORTANT NOTE: Auto Layout will be enabled for any NSWindow you add this
// view to.
@interface RBLSlidingContainerView : NSView

// The contentView (single subview) of the receiver.
//
// Setting this property is equivalent to calling
// -setContentView:direction:completion: with animations disabled and
// a nil completion block.
@property (nonatomic, strong) NSView *contentView;

// Calls -setContentView:direction:completion: with a nil completionBlock.
- (void)setContentView:(NSView *)contentView direction:(RBLSlidingContainerViewSlideDirection)direction;

// This method will replace the receiver's only subview with contentView.
//
// contentView - The view to be contained in the receiver.
// direction   - If not RBLSlidingContainerViewSlideDirectionNone,
//               the receiver's bounds will first animate to fit
//               the new contentView (pinned to the top left),
//               then contentView will slide transition into place according to
//               the direction;
//               RBLSlidingContainerViewSlideDirectionFromLeft
//               or RBLSlidingContainerViewSlideDirectionFromRight.
// completion  - An optional block to invoke upon completion of the animation.
//               May be nil.
- (void)setContentView:(NSView *)contentView direction:(RBLSlidingContainerViewSlideDirection)direction completion:(void (^)(void))completionBlock;

@end
