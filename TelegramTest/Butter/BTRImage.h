//
//  BTRImage.h
//  Butter
//
//  Created by Jonathan Willing on 7/16/13.
//  Copyright (c) 2013 ButterKit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AnimatedFrameImage : NSImage

@property (nonatomic) double duration;

@end


@interface BTRImage : NSImage

@property (nonatomic, strong) NSArray *cacheFrames;

@property (nonatomic) NSUInteger totalImageFrames;
@property (nonatomic) NSUInteger animationLoopCount;

@property (nonatomic) BOOL isAnimated;


// The edge insets for use in BTRImageView. This property will not affect normal image drawing.
@property (nonatomic, assign) NSEdgeInsets capInsets;

// Returns an image created by calling NSImage +imageNamed:, copying the image, and setting `capInsets`.
+ (instancetype)resizableImageNamed:(NSString *)name withCapInsets:(NSEdgeInsets)insets;

+ (instancetype)animatedImage:(NSString *)imageNamed;

@end
