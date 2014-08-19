//
//  TMGifImageView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/15/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMGifImageView.h"
#import "ImageUtils.h"

@interface TMGifImageView()
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) CAKeyframeAnimation *keyFrameAnimation;
@end

@implementation TMGifImageView


- (void)setImage:(NSImage *)image isRounded:(BOOL)isRounded {
    [self standartSet];
    
    if(self.image == image)
        return;
    
    self.image = image;
    
    CGImageSourceRef asource = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], NULL);
    if(asource == NULL) {
        return ELog(@"asource null");
    }
    
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(asource, 0, nil);
    CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(asource, 0, NULL);
    
    CFRelease(asource);
    if(dictRef == NULL || maskRef == NULL) {
        if(dictRef)
            CFRelease(dictRef);
        
        if(maskRef)
            CGImageRelease(maskRef);
        
        return ELog(@"dict or maskRef null");
    }
    
//    if(!isRounded)
    {
        CGImageRelease(maskRef);
        image = [ImageUtils roundCorners:image size:NSMakeSize(self.roundRadius, self.roundRadius)];
        CGImageSourceRef asource = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], NULL);
        if(asource == NULL) {
            CFRelease(dictRef);
            return ELog(@"asource null");
        }
        maskRef =  CGImageSourceCreateImageAtIndex(asource, 0, NULL);
        CFRelease(asource);
    }

    [super setImage:maskRef imageProperties:(__bridge NSDictionary*)dictRef];
    CGImageRelease(maskRef);
    CFRelease(dictRef);
}

- (void)standartSet {
    [self setAutoresizes:YES];
    
//	if ([self overlayForType:IKOverlayTypeImage] == nil)
//		[self setOverlay:[CALayer layer] forType:IKOverlayTypeImage];
    
	[[self overlayForType:IKOverlayTypeImage] removeAllAnimations];
    
    [self setBackgroundColor:[NSColor clearColor]];
}


- (id)init {
    self = [super init];
    if(self) {
        [self standartSet];
    }
    return self;
}

- (void)startAnimation {
//    if(self.keyFrameAnimation) {
//        CALayer *layer = [self overlayForType:IKOverlayTypeImage];
//        [layer removeAllAnimations];
//        [layer addAnimation:self.keyFrameAnimation forKey:@"contents"];
//        return;
//    }
    
    
    [[self overlayForType:IKOverlayTypeImage] removeAllAnimations];
    
    NSImage *image = self.image;
    NSArray * reps = [image representations];
    for (NSImageRep * rep in reps) {
        if ([rep isKindOfClass:[NSBitmapImageRep class]] == NO)
            continue;
        
        NSBitmapImageRep *bitmapRep = (NSBitmapImageRep *)rep;
        
        int numFrame = [[bitmapRep valueForProperty:NSImageFrameCount] intValue];
        if (numFrame == 0)
            break;
        
        CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        NSMutableArray * values = [NSMutableArray array];
        
        float animationDuration = 0.0f;
        for (int i = 0; i < numFrame; ++i) {
            [bitmapRep setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithInt:i]];
            
            if ([[bitmapRep valueForProperty:NSImageCurrentFrameDuration] floatValue] <= 0.000001f)
                [bitmapRep setProperty:NSImageCurrentFrameDuration withValue:[NSNumber numberWithFloat:1.0f / 20.0f]];
            
            [values addObject:(id)[bitmapRep CGImage]];
            animationDuration += [[bitmapRep valueForProperty:NSImageCurrentFrameDuration] floatValue];
        }
        
        [animation setValues:values];
        [animation setCalculationMode:@"discrete"];
        [animation setDuration:animationDuration];
        [animation setRepeatCount:HUGE_VAL];
        [animation setDelegate:self.superview];
        
//        self.keyFrameAnimation = animation;
        
        CALayer * layer = [self overlayForType:IKOverlayTypeImage];
        if(!layer) {
            layer = [CALayer layer];
            [layer setCornerRadius:self.roundRadius * 2];
            [layer setMasksToBounds:YES];
            [self setOverlay:layer forType:IKOverlayTypeImage];
        }
        
        [layer addAnimation:animation forKey:@"contents"];
        
        break;
    }
    
}

- (void)mouseDown:(NSEvent *)theEvent {
    
	[[self overlayForType:IKOverlayTypeImage] removeAllAnimations];
}

@end
