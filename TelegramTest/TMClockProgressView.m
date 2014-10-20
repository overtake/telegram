#import "TMClockProgressView.h"

#import <QuartzCore/QuartzCore.h>

@implementation TMClockProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        
        self.wantsLayer = YES;
        
        
        _frameView = imageViewWithImage(image_ClockFrame());
        [self addSubview:_frameView];
        
        
        
        _hourView = imageViewWithImage(image_ClockHour());
        [self addSubview:_hourView];
        
        
        _minView = imageViewWithImage(image_ClockMin());
        [self addSubview:_minView];
        
        
        _hourView.wantsLayer = YES;
        _minView.wantsLayer = YES;
        
        
        
        CGPoint point = _hourView.layer.position;
        
        point.x += roundf(NSWidth(_hourView.frame)/2);
        point.y += roundf( NSHeight(_hourView.frame)/2);
        
        _hourView.layer.position = point;
        _hourView.layer.anchorPoint = NSMakePoint(0.5f, 0.5f);
        
        _minView.layer.position = point;
        _minView.layer.anchorPoint = NSMakePoint(0.5f, 0.5f);
        
        
    }
    return self;
}



- (void)startAnimating
{
    if (_isAnimating)
        return;
    
    [_hourView.layer removeAllAnimations];
    [_minView.layer removeAllAnimations];
    
    _isAnimating = true;
    
    [self animateHourView];
    [self animateMinView];
}

#define MINUTE_DURATION 1.2f

- (void)animateHourView
{
    
    
    CABasicAnimation *animation  = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = MINUTE_DURATION*6;
    animation.repeatCount = HUGE_VAL;
    animation.toValue = @(- (M_PI * 2));
    [_hourView.layer addAnimation:animation forKey:@"rotate"];

}


- (void)animateMinView
{
    
    CABasicAnimation *animation  = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = MINUTE_DURATION;
    animation.repeatCount = HUGE_VAL;
    animation.toValue = @(- (M_PI * 2));
    [_minView.layer addAnimation:animation forKey:@"rotate"];

}

- (void)stopAnimating
{
    if (!_isAnimating)
        return;
    
    _isAnimating = false;
    
    [_hourView.layer removeAllAnimations];
    [_minView.layer removeAllAnimations];
}

@end
