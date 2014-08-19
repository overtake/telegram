//
//  NSImage+BTRImageAdditions.h
//  Butter
//
//  Created by Indragie Karunaratne on 7/16/2013.
//  Copyright (c) 2013 ButterKit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BTRImage.h"

@interface NSImage (BTRImageAdditions)

// Returns an instance of `BTRImage` by copying the receiver and setting the cap insets
// to the given value.
- (BTRImage *)btr_resizableImageWithCapInsets:(NSEdgeInsets)insets;

@end
