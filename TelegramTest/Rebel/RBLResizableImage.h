//
//  RBLResizableImage.h
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-07-24.
//  Copyright (c) 2012 GitHub. All rights reserved.
//
//  Portions copyright (c) 2011 Twitter. All rights reserved.
//  See the LICENSE file for more information.
//

#import <Cocoa/Cocoa.h>

// An image that supports resizing based on end caps.
@interface RBLResizableImage : NSImage <NSCoding, NSCopying>

// The end cap insets for the image.
//
// Any portion of the image not covered by end caps will be tiled when the image
// is drawn.
@property (nonatomic, assign) NSEdgeInsets capInsets;

@end
