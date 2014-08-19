//
//  GifAnimationLayer.m
//  GifAnimationLayer
//
//  Created by Zhang Yi <zhangyi.cn@gmail.com> on 2012-5-24.
//  Copyright (c) 2012年 iDeer inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "GifAnimationLayer.h"
#import <ImageIO/ImageIO.h>

static NSString * const kGifAnimationKey = @"GifAnimation";

inline static double CGImageSourceGetGifFrameDelay(CGImageSourceRef imageSource, NSUInteger index)
{
    double frameDuration = 0.0f;
    
    CFDictionaryRef theImageProperties;
    if ((theImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL))) {
        CFDictionaryRef gifProperties;
        if (CFDictionaryGetValueIfPresent(theImageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties)) {
            const void *frameDurationValue;
            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &frameDurationValue)) {
                frameDuration = [(__bridge NSNumber *)frameDurationValue floatValue];
                if (frameDuration <= 0) {
                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &frameDurationValue)) {
                        frameDuration = [(__bridge NSNumber *)frameDurationValue floatValue];
                    }
                }
            }
        }
        CFRelease(theImageProperties);
    }
    
    return frameDuration;
}

inline static NSUInteger CGImageSourceGetGifLoopCount(CGImageSourceRef imageSource)
{
    NSUInteger loopCount = 0;
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    if (properties) {
        NSNumber *loopCountValue =  (__bridge NSNumber *)CFDictionaryGetValue(properties, kCGImagePropertyGIFLoopCount);
        loopCount = [loopCountValue unsignedIntegerValue];
        CFRelease(properties);
    }
    return loopCount;
}

inline static BOOL CGImageSourceHasAlpha(CGImageSourceRef imageSource)
{
    const void * result = NULL;
    
    CFDictionaryRef theImageProperties;
    if ((theImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL))) {
        result = CFDictionaryGetValue(theImageProperties, kCGImagePropertyHasAlpha);
        CFRelease(theImageProperties);
    }
    return result == kCFBooleanTrue;
}

@interface GifAnimationLayer () {
    NSTimeInterval *_frameDurationArray;
    NSTimeInterval _totalDuration;
    BOOL _paused;
}

- (CGImageRef)copyImageAtFrameIndex:(NSUInteger)index;

@property (nonatomic,assign) NSUInteger currentGifFrameIndex;
@property (nonatomic,readonly) NSUInteger numberOfFrames;
@property (nonatomic,readonly) NSUInteger loopCount;

@property (nonatomic) NSUInteger currentIndex;

@end

@implementation GifAnimationLayer {
    CGImageSourceRef _imageSource;
}

@synthesize gifFilePath=_gifFilePath;
@synthesize currentGifFrameIndex=_currentGifFrameIndex;
@synthesize numberOfFrames=_numberOfFrames;
@synthesize loopCount=_loopCount;

- (id)init
{
    if ((self = [super init])) {
        _currentGifFrameIndex = NSNotFound;
    }
    return self;
}

+ (id)layerWithGifFilePath:(NSString *)filePath
{
    GifAnimationLayer *layer = [self layer];
    layer.gifFilePath = filePath;
    return layer;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [key isEqualToString:@"currentGifFrameIndex"];
}

- (void)display
{
    NSUInteger index = [(GifAnimationLayer *)[self presentationLayer] currentGifFrameIndex];
    if (index == NSNotFound) {
        return;
    }
    
    if(self.currentIndex == index) {
        return;
    }
    
    
    if(self.speed != 0)
        self.currentIndex = index;
    
    if(self.visibleRect.size.width == 0 &&  self.visibleRect.size.height == 0)
        return;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.contents = (__bridge_transfer id)[self copyImageAtFrameIndex:self.currentIndex];
    [CATransaction commit];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_numberOfFrames > 0) {
        free(_frameDurationArray);
        _numberOfFrames = 0;
        _totalDuration  = 0;
    }
    
    if (_imageSource) {
        CFRelease(_imageSource);
    }
}

- (void)startAnimating
{
    [self stopAnimating];
    
    self.isAnimationRunning = YES;
    
    if (!_imageSource || self.numberOfFrames <= 0) {
        return;
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"currentGifFrameIndex"];
    animation.calculationMode = kCAAnimationDiscrete;
    animation.autoreverses    = NO;
    if (self.loopCount > 0) {
        animation.repeatCount = self.loopCount;
    } else {
        animation.repeatCount = HUGE_VALF;
    }
    
    /**
     * keyTimes
     *
     * http://developer.apple.com/library/mac/#documentation/GraphicsImaging/Reference/CAKeyframeAnimation_class/Introduction/Introduction.html#//apple_ref/occ/cl/CAKeyframeAnimation
     *
     * Each value in the array is a floating point number between 0.0 and 1.0 and corresponds to one element in the values array.
     * Each element in the keyTimes array defines the duration of the corresponding keyframe value as a fraction of the total duration of the animation.
     * Each element value must be greater than, or equal to, the previous value.
     */
    NSMutableArray *values   = [NSMutableArray arrayWithCapacity:self.numberOfFrames];
    NSMutableArray *keyTimes = [NSMutableArray arrayWithCapacity:self.numberOfFrames];
    NSTimeInterval lastDurationFraction = 0;
    for (NSUInteger i=0; i<self.numberOfFrames; ++i) {
        [values addObject:[NSNumber numberWithUnsignedInteger:i]];
        
        NSTimeInterval currentDurationFraction;
        if (i == 0) {
            currentDurationFraction = 0;
        } else {
            currentDurationFraction = lastDurationFraction + _frameDurationArray[i]/_totalDuration;
        }
        lastDurationFraction = currentDurationFraction;
        [keyTimes addObject:[NSNumber numberWithDouble:currentDurationFraction]];
    }
    
    //add final destination value
    [values addObject:[NSNumber numberWithUnsignedInteger:self.numberOfFrames]];
    [keyTimes addObject:[NSNumber numberWithDouble:1.0]];
    
    animation.values   = values;
    animation.keyTimes = keyTimes;
    animation.duration = _totalDuration;
    
    [self addAnimation:animation forKey:kGifAnimationKey];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)stopAnimating
{
    self.isAnimationRunning = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeAnimationForKey:kGifAnimationKey];
}

- (void)applicationDidEnterBackground
{
    self.speed = 0.0;
}

- (void)applicationWillEnterForeground
{
    self.speed = 1.0;
    if (!_paused) {
        [self startAnimating];
    }
}

- (void)pauseAnimating
{
    self.speed = 0.0;
    _paused    = YES;
}

- (void)resumeAnimating
{
    self.speed = 1.0;
    _paused    = NO;
//    if (![self animationForKey:kGifAnimationKey]) {
//        [self startAnimating];
//    }
}

- (void)setGifFilePath:(NSString *)gifFilePath {
    
    self.currentIndex = -1;
    
    for(int i = 0; i < _numberOfFrames; i++) {
        CGImageRelease([self copyImageAtFrameIndex:0]);
    }
    
    if (_numberOfFrames > 0) {
        free(_frameDurationArray);
        _numberOfFrames = 0;
    }
    
    if (_imageSource) {
        CFRelease(_imageSource);
    }
    
    _totalDuration  = 0;
    _gifFilePath = gifFilePath;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.opaque = YES;
    [CATransaction commit];
    
    // update numberOfFrames and frameDurationArray
    const CFStringRef optionKeys[1]   = {kCGImageSourceShouldCache};
    const CFStringRef optionValues[1] = {(CFTypeRef)kCFBooleanFalse};
    CFDictionaryRef options = CFDictionaryCreate(NULL, (const void **)optionKeys, (const void **)optionValues, 1, &kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);
    _imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:self.gifFilePath], options);
    CFRelease(options);
   
    
    if (_imageSource) {
        _numberOfFrames = CGImageSourceGetCount(_imageSource);
        _loopCount = CGImageSourceGetGifLoopCount(_imageSource);
        
        _frameDurationArray = (NSTimeInterval *) malloc(_numberOfFrames * sizeof(NSTimeInterval));
        for (NSUInteger i=0; i<_numberOfFrames; ++i) {
            _frameDurationArray[i] = CGImageSourceGetGifFrameDelay(_imageSource, i);
            _totalDuration += _frameDurationArray[i];
        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.opaque = !CGImageSourceHasAlpha(_imageSource);
        [CATransaction commit];
        
        CGFloat width = 0.0f, height = 0.0f;
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(_imageSource, 0, NULL);
        if (imageProperties != NULL) {
            CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
            if (widthNum != NULL) {
                CFNumberGetValue(widthNum, kCFNumberCGFloatType, &width);
            }
            
            CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            if (heightNum != NULL) {
                CFNumberGetValue(heightNum, kCFNumberCGFloatType, &height);
            }
            
            CFRelease(imageProperties);
        }
//        [self setFrame:CGRectMake(0, 0, width / 2, height / 2)];

    }
    
    [self setCurrentGifFrameIndex:0];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.contents = (__bridge_transfer id)[self copyImageAtFrameIndex:0];
    [CATransaction commit];
}

- (CGImageRef)copyImageAtFrameIndex:(NSUInteger)index
{
    if (!_imageSource || index > _numberOfFrames) {
        return nil;
    }
    
    CGImageRef theImage = CGImageSourceCreateImageAtIndex(_imageSource, index, NULL);
    
    return theImage;
}

@end