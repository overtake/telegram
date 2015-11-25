//
//  TMCircularProgress.m
//  Messenger for Telegram
//
//  Created by keepcoder on 13.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMCircularProgress.h"
#import "CAProgressLayer.h"

#import "TGTimer.h"


@interface TMCircularLayer : CALayer
@property (nonatomic,assign) float progress;
@end

@implementation TMCircularLayer

-(void)setProgress:(float)progress {
    _progress = progress;
    
    [self setNeedsDisplay];
}

@end


@interface TMCircularProgress ()
{
    int rotateAngel;
}

@property (nonatomic,strong) CAProgressLayer *shapeLayer;
@property (nonatomic,strong) TGTimer *timer;
@property (nonatomic,assign) float currentAcceptProgress;
@property (nonatomic, assign) CVDisplayLinkRef displayLink;
@property (nonatomic,strong) BTRButton *cancelView;
@end

@implementation TMCircularProgress
@synthesize displayLink = _displayLink;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self->min = 0;
        self->max = 100;
        self->duration = 0.1;
        self->fps = 60;
        self->reversed = NO;
        self.currentProgress = 0;
        self.style = TMCircularProgressLightStyle;
        self->_backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.3);
        
     //   self.cancelView = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 12, 12)];
        
        self.wantsLayer = YES;
        
        
        
       // [self.cancelView setCenterByView:self];

        weakify();
        [self.cancelView addBlock:^(BTRControlEvents events) {
            if(strongSelf.cancelCallback) {
                strongSelf.cancelCallback();
            }
        } forControlEvents:BTRControlEventMouseDownInside];
        
      //  [self addSubview:self.cancelView];
    }
    return self;
}

- (void)setStyle:(TMCircularProgressStyle)style {
    self->_style = style;
    
    if(self.style == TMCircularProgressDarkStyle) {
        
        self.progressColor = NSColorFromRGB(0xffffff);
    } else {
        
        self.progressColor = NSColorFromRGB(0xa0a0a0);
    }
    
    [self setNeedsDisplay:YES];
}

-(void)setCancelImage:(NSImage *)cancelImage {
    self->_cancelImage = cancelImage;
//    
//    [self.cancelView setBackgroundImage:cancelImage forControlState:BTRControlStateNormal];
//    [self.cancelView setFrameSize:cancelImage.size];
//   
//    
//     [self.cancelView setCenterByView:self];
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [self.cancelView setCenterByView:self];
}

-(void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    [self.cancelView setCenterByView:self];
}

//-(void)dealloc {
//    CVDisplayLinkRelease(_displayLink);
//}


float ease(float t, float b, float c, float d) {
    t /= d;
    t--;
    return c*(t*t*t + 1) + b;
};


- (void)drawRect:(NSRect)dirtyRect
{
    if(self.isHidden || self.window == nil) {
        [self pop_removeAllAnimations];
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    
	[super drawRect:dirtyRect];
    
    
    const int topPadding = 1;
    
    int radius = roundf(self.frame.size.width / 2 - topPadding);
    
    NSPoint topCenter = { roundf(self.frame.size.width/2), self.frame.size.height-topPadding};
    NSPoint center = { roundf(self.frame.size.width/2),roundf(self.frame.size.height/2) };
    
    NSBezierPath *path;
    
   
    
    
    path = [NSBezierPath bezierPath];
    
    float endAngel = (_currentAcceptProgress/(max-min))*360;
    endAngel = reversed ? endAngel : -endAngel;
    
    if(isnan(_currentAcceptProgress) || isnan(endAngel))
        return;
    
    float startAngel = 90;
    
    [path moveToPoint: topCenter];
    
    [path appendBezierPathWithArcWithCenter: center
                                     radius: radius
                                 startAngle: startAngel
                                   endAngle: endAngel+startAngel clockwise:YES];
    
    [self.progressColor setStroke];
    
    [path setLineWidth:2];
    
    
    NSAffineTransform * transform = [NSAffineTransform transform];
    [transform translateXBy: center.x yBy: center.y];
    [transform rotateByDegrees:-rotateAngel];
    [transform translateXBy: -center.x yBy: -center.y];

    [path transformUsingAffineTransform:transform];
    
    [path stroke];
    
}




-(void)setBackgroundColor:(NSColor *)backgroundColor {
    self->_backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}

-(void)setProgressColor:(NSColor *)progressColor {
    self->_progressColor = progressColor;
    [self setNeedsDisplay:YES];
}

-(void)setCurrentProgress:(float)currentProgress {
    [self setProgress:currentProgress animated:NO];
}



-(void)setProgress:(float)currentProgress animated:(BOOL)animated {
    
    const float step = 0.1;
    
    if(currentProgress < self->min)
        self->_currentProgress = self->min;
    else if(currentProgress > self->max)
        self->_currentProgress = self->max;
    else
        self->_currentProgress = currentProgress;
   
    if(currentProgress == min) {
        _currentAcceptProgress = min;
    }
    
    if(currentProgress < _currentAcceptProgress) {
        _currentAcceptProgress = currentProgress;
    }
    
    
    
    
    if(!animated) {
        self->_currentAcceptProgress = self->_currentProgress;
        self->rotateAngel = 0;
        [self pop_removeAllAnimations];
        [self setNeedsDisplay:YES];
        return;
    }
    
    if(self.isHidden || currentProgress == min)
    {
        [self.timer invalidate];
        self.timer = nil;
        [self pop_removeAllAnimations];
        return;
    }
    
    POPBasicAnimation *animation = [self pop_animationForKey:@"progress"];
    
    if(!animation) {
        animation = [POPBasicAnimation animation];
    }
    
    animation.property = [POPAnimatableProperty propertyWithName:@"progress" initializer:^(POPMutableAnimatableProperty *prop) {
        
        [prop setReadBlock:^(TMCircularProgress *layer, CGFloat values[]) {
            values[0] = layer.currentAcceptProgress;
        }];
        
        [prop setWriteBlock:^(TMCircularProgress *layer, const CGFloat values[]) {
            layer.currentAcceptProgress = values[0];
            
            [layer setNeedsDisplay:YES];
        }];
        
        
        
        prop.threshold = 0.01f;
    }];
    
    
    animation.repeatForever = NO;
    
    animation.fromValue = @(_currentAcceptProgress);
    
    animation.toValue = @(_currentProgress);
    
    animation.duration = 0.2;
    
    animation.removedOnCompletion = YES;
    
    
    [self pop_addAnimation:animation forKey:@"progress"];
    
    
    
    if(![self pop_animationForKey:@"rotate"]) {

        
        
        POPBasicAnimation *rotate = [POPBasicAnimation animation];
        
        
        rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];;
        
        rotate.property = [POPAnimatableProperty propertyWithName:@"rotate" initializer:^(POPMutableAnimatableProperty *prop) {
            
            [prop setReadBlock:^(TMCircularProgress *layer, CGFloat values[]) {
                values[0] = layer->rotateAngel;
            }];
            
            [prop setWriteBlock:^(TMCircularProgress *layer, const CGFloat values[]) {
                
                layer->rotateAngel = values[0];
                [layer setNeedsDisplay:YES];
                
            }];
            
            prop.threshold = 0.01f;
            
        }];
        
        
        rotate.fromValue = @(0);
        
        rotate.toValue = @(360);
        
        rotate.duration = 2;
        
        
        rotate.removedOnCompletion = YES;
        rotate.repeatForever = YES;
        [self pop_addAnimation:rotate forKey:@"rotate"];
    }
    
    

    
}


-(void)setHidden:(BOOL)flag {
    [super setHidden:flag];
    if(flag) {
        [self.timer invalidate];
        self.timer = nil;
        [self pop_removeAllAnimations];
    }
    
    rotateAngel = 0;
}


-(void)removeFromSuperview {
    [super removeFromSuperview];
    [self.timer invalidate];
    self.timer = nil;
    [self pop_removeAllAnimations];
    rotateAngel = 0;
}

@end
