//
//  BTRImage.m
//  Butter
//
//  Created by Jonathan Willing on 7/16/13.
//  Copyright (c) 2013 ButterKit. All rights reserved.
//

#import "BTRImage.h"

@implementation AnimatedFrameImage

@end

@implementation BTRImage

+ (instancetype)resizableImageNamed:(NSString *)name withCapInsets:(NSEdgeInsets)insets {
	NSImage *originalImage = [self imageNamed:name];
	if (originalImage.representations) {
		BTRImage *image = [[BTRImage alloc] initWithSize:originalImage.size];
		[image addRepresentations:originalImage.representations];
		image.capInsets = insets;
		return image;
	} else {
		return nil;
	}
}

+ (instancetype)animatedImage:(NSString *)imageNamed {
    NSImage *originalImage = [self imageNamed:imageNamed];
	if (originalImage.representations) {
        BTRImage *image = [[BTRImage alloc] initWithSize:originalImage.size];
		[image addRepresentations:originalImage.representations];
        [image generateAnimation];
        return image;
    } else {
        return nil;
    }
}

- (void) generateAnimation {
    if(!self.representations.count)
        return;
    
    NSBitmapImageRep *rep = self.representations[0];
    
    if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
        self.isAnimated = YES;
        self.totalImageFrames = [[rep valueForProperty:NSImageFrameCount] unsignedIntegerValue];
        self.animationLoopCount = [[rep valueForProperty:NSImageLoopCount] unsignedIntegerValue];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(int i = 0; i < self.totalImageFrames; i++) {
            [rep setProperty:NSImageCurrentFrame withValue:@(i)];
            
            NSData *data = [rep TIFFRepresentation];
            
            AnimatedFrameImage *currentFrameImage = [[AnimatedFrameImage alloc] initWithData:data];
            currentFrameImage.duration = [[rep valueForProperty:NSImageCurrentFrameDuration] doubleValue];
            [array addObject:currentFrameImage];
        }
        
        self.cacheFrames = [NSArray arrayWithArray:array];
    }
}

@end
