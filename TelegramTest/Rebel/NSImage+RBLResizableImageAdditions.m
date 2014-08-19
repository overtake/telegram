//
//  NSImage+RBLResizableImageAdditions.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-10-08.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSImage+RBLResizableImageAdditions.h"
#import "RBLResizableImage.h"

@implementation NSImage (RBLResizableImageAdditions)

- (RBLResizableImage *)rbl_resizableImageWithCapInsets:(NSEdgeInsets)capInsets {
	RBLResizableImage *image = [[RBLResizableImage alloc] initWithSize:self.size];
	[image addRepresentations:self.representations];

	image.capInsets = capInsets;
	return image;
}

@end
