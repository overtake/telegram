//
//  RBLExpandingContainerView.h
//  Rebel
//
//  Created by Alan Rogers on 4/02/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// A view class that uses Auto Layout to adjust its bounds to fit a contentView,
// and optionally animate this change. During the bounds change, the contentView
// is pinned to the top left.
//
// NOTE: You must use to the provided -setContentView: methods to change the
// subview. Calling any of the normal subview mutating methods on the receiver
// will result in undefined behavior.
// IMPORTANT NOTE: Auto Layout will be enabled for any NSWindow you add this
// view to.
@interface RBLExpandingContainerView : NSView

// The contentView (single subview) of the receiver.
//
// Setting this property is equivalent to calling
// -setContentView:animated:completion: with animations disabled and
// a nil completion block.
@property (nonatomic, strong) NSView *contentView;

// This method will replace the receiver's only subview with contentView.
//
// contentView - The view to be contained in the receiver.
// animated    - If YES, the receiver's bounds will animate to fit the new
//               contentView (pinned to the top left).
// completion  - An optional block to invoke upon completion of the animation.
//               May be nil.
- (void)setContentView:(NSView *)contentView animated:(BOOL)animated completion:(void (^)(void))completionBlock;

// Calls -setContentView:animated:completion: with a nil completionBlock.
- (void)setContentView:(NSView *)contentView animated:(BOOL)animated;

@end
