//
//  NSImage+RBLResizableImageAdditions.h
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-10-08.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RBLResizableImage;

@interface NSImage (RBLResizableImageAdditions)

// Returns a new image with the specified cap insets. See RBLResizableImage for
// more information.
- (RBLResizableImage *)rbl_resizableImageWithCapInsets:(NSEdgeInsets)capInsets;

@end
