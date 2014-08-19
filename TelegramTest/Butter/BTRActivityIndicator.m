//
//  BTRActivityIndicator.m
//  Butter
//
//  Created by Jonathan Willing on 12/25/12.
//  Copyright (c) 2012 ButterKit. All rights reserved.
//
//	Much thanks to David Rönnqvist (@davidronnqvist) for the original idea of using CAReplicatorLayer.

#import "BTRActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

@interface BTRActivityIndicator()
@property (nonatomic, strong) CAReplicatorLayer *replicatorLayer;
@property (nonatomic, readonly) CABasicAnimation *progressShapeLayerFadeOutAnimation;
@property (nonatomic, assign, readwrite) BOOL animating;
@end

static const CGFloat BTRActivityIndicatorDefaultFrameLength = 24.f;
static const CGFloat BTRActivityIndicatorFadeInOutDuration = 0.2f;
static NSString * const BTRActivityIndicatorAnimationKey = @"BTRActivityIndicatorFadeOut";

@implementation BTRActivityIndicator
@synthesize progressShapeLayer = _progressShapeLayer;

- (id)initWithFrame:(NSRect)frame {
	return [self initWithFrame:frame activityIndicatorStyle:BTRActivityIndicatorStyleGray];
}

- (id)initWithActivityIndicatorStyle:(BTRActivityIndicatorStyle)style {
	CGFloat length = BTRActivityIndicatorDefaultFrameLength;
	return [self initWithFrame:CGRectMake(0, 0, length, length) activityIndicatorStyle:style];
}

- (id)initWithFrame:(NSRect)frame activityIndicatorStyle:(BTRActivityIndicatorStyle)style {
	self = [super initWithFrame:frame layerHosted:YES];
	if (self == nil) return nil;
	
	_activityIndicatorStyle = style;
	_progressShapeColor = (style == BTRActivityIndicatorStyleGray ? [NSColor grayColor] : [NSColor whiteColor]);
	_progressShapeCount = 12;
	
	CGFloat minLength = fminf(CGRectGetWidth(frame), CGRectGetHeight(frame));
	_progressShapeLength = ceilf(minLength / 4);
	_progressShapeThickness = ceilf(minLength / _progressShapeCount);
	_progressShapeSpread = _progressShapeLength;
	_progressAnimationDuration = 1.f;
	
	[self.layer addSublayer:self.replicatorLayer];
	self.progressShapeLayer.opacity = 0.f;
	
	[self accessibilitySetOverrideValue:NSAccessibilityProgressIndicatorRole forAttribute:NSAccessibilityRoleAttribute];
	[self accessibilitySetOverrideValue:NSAccessibilityRoleDescription(NSAccessibilityProgressIndicatorRole, nil) forAttribute:NSAccessibilityRoleDescriptionAttribute];
	
	return self;
}

- (void)setActivityIndicatorStyle:(BTRActivityIndicatorStyle)style {
	self.progressShapeColor = (style == BTRActivityIndicatorStyleGray ? [NSColor grayColor] : [NSColor whiteColor]);
}

- (void)startAnimating {
	self.layer.opacity = 1.f;
	self.progressShapeLayer.opacity = 0.f;
	[self.progressShapeLayer addAnimation:self.progressShapeLayerFadeOutAnimation forKey:BTRActivityIndicatorAnimationKey];
	self.animating = YES;
}

- (void)stopAnimating {
	[CATransaction begin];
	[CATransaction setCompletionBlock:^{
		[self.progressShapeLayer removeAnimationForKey:BTRActivityIndicatorAnimationKey];
	}];
	CABasicAnimation *fadeOut = [self animationFromOpacity:1 toOpacity:0 withDuration:BTRActivityIndicatorFadeInOutDuration];
	self.layer.opacity = 0.f;
	[self.layer addAnimation:fadeOut forKey:nil];
	self.animating = NO;
	[CATransaction commit];
}


#pragma mark Animation

- (CABasicAnimation *)animationFromOpacity:(CGFloat)fromVal toOpacity:(CGFloat)toVal withDuration:(CGFloat)duration {
	CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeOut.fromValue = @(fromVal);
	fadeOut.toValue = @(toVal);
	fadeOut.duration = duration;
	return fadeOut;
}

- (CABasicAnimation *)progressShapeLayerFadeOutAnimation {
	CABasicAnimation *fadeOut = [self animationFromOpacity:1 toOpacity:0 withDuration:self.progressAnimationDuration];
	fadeOut.repeatCount = HUGE_VALF;
	return fadeOut;
}


#pragma mark Layers

- (CALayer *)progressShapeLayer {
	if (_progressShapeLayer == nil) {
		_progressShapeLayer = [CALayer layer];
		_progressShapeLayer.bounds = CGRectMake(0, 0, self.progressShapeThickness, self.progressShapeLength);
		_progressShapeLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
		_progressShapeLayer.position = self.progressShapeLayerPosition;
		_progressShapeLayer.backgroundColor = self.progressShapeColor.CGColor;
		_progressShapeLayer.cornerRadius = self.progressShapeThickness * 0.5f;
	}
	return _progressShapeLayer;
}

- (CAReplicatorLayer *)replicatorLayer {
	if (_replicatorLayer == nil) {
		_replicatorLayer = [CAReplicatorLayer layer];
		_replicatorLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
		_replicatorLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
		
		[_replicatorLayer addSublayer:self.progressShapeLayer];
		
		[self updateReplicatorSettings];
	}
	return _replicatorLayer;
}

- (void)updateReplicatorSettings {
	self.replicatorLayer.instanceDelay = self.progressAnimationDuration / self.progressShapeCount;
	CGFloat angle = (2.f * M_PI) / self.progressShapeCount;
	CATransform3D rotation = CATransform3DMakeRotation(angle, 0.f, 0.f, -1.f);
	_replicatorLayer.instanceTransform = rotation;
	_replicatorLayer.instanceCount = self.progressShapeCount;
}

- (CGPoint)progressShapeLayerPosition {
	return CGPointMake(0, self.progressShapeSpread);
}


#pragma mark Customization

- (void)setProgressShapeColor:(NSColor *)progressShapeColor {
	_progressShapeColor = progressShapeColor;
	self.progressShapeLayer.backgroundColor = progressShapeColor.CGColor;
}

- (void)setProgressShapeCount:(NSUInteger)progressShapeCount {
	_progressShapeCount = progressShapeCount;
	[self updateReplicatorSettings];
}

- (void)setProgressShapeThickness:(CGFloat)progressShapeThickness {
	_progressShapeThickness = progressShapeThickness;
	[self.progressShapeLayer setValue:@(progressShapeThickness) forKeyPath:@"bounds.size.width"];
}

- (void)setProgressShapeLength:(CGFloat)progressShapeLength {
	_progressShapeLength = progressShapeLength;
	[self.progressShapeLayer setValue:@(progressShapeLength) forKeyPath:@"bounds.size.height"];
}

- (void)setProgressShapeSpread:(CGFloat)progressShapeSpread {
	_progressShapeSpread = progressShapeSpread;
	self.progressShapeLayer.position = self.progressShapeLayerPosition;
}

- (void)setProgressAnimationDuration:(CGFloat)progressAnimationDuration {
	_progressAnimationDuration = progressAnimationDuration;
	[self updateReplicatorSettings];
	
	if ([self.progressShapeLayer animationForKey:BTRActivityIndicatorAnimationKey]) {
		[self.progressShapeLayer removeAnimationForKey:BTRActivityIndicatorAnimationKey];
		[self.progressShapeLayer addAnimation:self.progressShapeLayerFadeOutAnimation forKey:BTRActivityIndicatorAnimationKey];
	}
}

- (void)setProgressShapeLayer:(CALayer *)progressShapeLayer {
	BOOL needsAnimation = ([self.progressShapeLayer animationForKey:BTRActivityIndicatorAnimationKey] != nil);
	[self.progressShapeLayer removeFromSuperlayer];
	_progressShapeLayer = progressShapeLayer;
	self.progressShapeLayer.position = self.progressShapeLayerPosition;
	[self.replicatorLayer addSublayer:self.progressShapeLayer];
	if (needsAnimation) {
		[self.progressShapeLayer addAnimation:self.progressShapeLayerFadeOutAnimation forKey:BTRActivityIndicatorAnimationKey];
	}
}


#pragma mark Accessibility

- (BOOL)accessibilityIsIgnored {
	return NO;
}

@end
