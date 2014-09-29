//
//  CAAnimation+RBLBlockAdditions.h
//  Rebel
//
//  Created by Danny Greg on 13/09/2012.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (RBLBlockAdditions)

// A block called on successful completion of the animation.
// This takes over the delegate property of the animation. If you subsequently
// set a delegate, this will break. It will also replace any existing delegate
// set on the animation.
//
// finished - Whether the animation had finished when it stopped.
@property (nonatomic, copy) void (^rbl_completionBlock)(BOOL finished);

@end
