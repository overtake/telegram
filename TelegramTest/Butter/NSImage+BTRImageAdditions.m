//
//  NSImage+BTRImageAdditions.m
//  Butter
//
//  Created by Indragie Karunaratne on 7/16/2013.
//  Copyright (c) 2013 ButterKit. All rights reserved.
//

#import "NSImage+BTRImageAdditions.h"

@implementation NSImage (BTRImageAdditions)

- (BTRImage *)btr_resizableImageWithCapInsets:(NSEdgeInsets)insets {
	BTRImage *image = [[BTRImage alloc] initWithSize:self.size];
	[image addRepresentations:self.representations];
	image.capInsets = insets;
	return image;
}

@end
