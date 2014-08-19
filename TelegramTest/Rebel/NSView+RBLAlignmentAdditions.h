//
//  NSView+RBLAlignmentAdditions.h
//  Rebel
//
//  Created by Indragie Karunaratne on 2013-03-02.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (RBLAlignmentAdditions)

// Uses `-backingAlignedRect:options:` internally and converts between window coordinates
// and view coordinates.
//
// Returns a backing store pixel aligned rectangle in view coordinates
- (NSRect)rbl_viewBackingAlignedRect:(NSRect)rect options:(NSAlignmentOptions)options;

@end
