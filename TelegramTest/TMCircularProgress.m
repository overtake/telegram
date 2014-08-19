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


@interface TMCircularProgress ()
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
        self->fps = 30.0f;
        self->reversed = NO;
        self.currentProgress = 0;
        self->_progressColor = [NSColor whiteColor];
        self->_backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.3);
        
        self.cancelView = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 12, 12)];
        
        [self.cancelView setCursor:[NSCursor pointingHandCursor] forControlState:BTRControlStateNormal];
        
        
        
        [self.cancelView setCenterByView:self];

        weakify();
        [self.cancelView addBlock:^(BTRControlEvents events) {
            if(strongSelf.cancelCallback) {
                strongSelf.cancelCallback();
            }
        } forControlEvents:BTRControlEventMouseDownInside];
        
        

        
        [self addSubview:self.cancelView];
    }
    return self;
}

- (void)setStyle:(TMCircularProgressStyle)style {
    self->_style = style;
    
//    if(style == TMCircularProgressLightStyle) {
//        [self.cancelView removeFromSuperview];
//    } else {
//        [self addSubview:self.cancelView];
//    }
    
    self.cancelImage = self.style == TMCircularProgressLightStyle ? image_iconCancelDownload() : image_CancelDownload();
    
    [self setNeedsDisplay:YES];
}

-(void)setCancelImage:(NSImage *)cancelImage {
    self->_cancelImage = cancelImage;
    
    [self.cancelView setBackgroundImage:cancelImage forControlState:BTRControlStateNormal];
    [self.cancelView setFrameSize:cancelImage.size];
   
    
     [self.cancelView setCenterByView:self];
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [self.cancelView setFrameSize:newSize];
    [self.cancelView setCenterByView:self];
}

-(void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    [self.cancelView setCenterByView:self];
}

/*-(void)dealloc {
    CVDisplayLinkRelease(_displayLink);
}

- (CVDisplayLinkRef)displayLink {
	if (_displayLink == NULL) {
		CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
        
		CVDisplayLinkSetOutputCallback(_displayLink, &progressCallback, (__bridge void *)self);
        
	}
	
	return _displayLink;
}




static CVReturn progressCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now, const CVTimeStamp *outputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext) {
    
    
    @autoreleasepool {
		TMCircularProgress *progress = (__bridge id)displayLinkContext;
        
        float summ =  (progress.currentProgress - progress.currentAcceptProgress)/(progress->fps*progress->duration);
        if(summ < 0.1)
            summ = 0.1;
        progress.currentAcceptProgress+= summ;
        
        if(progress.currentAcceptProgress >= progress.currentProgress) {
            CVDisplayLinkStop(displayLink);
        }
        
		dispatch_async(dispatch_get_main_queue(), ^{
			[progress setNeedsDisplay:YES];
		});
	}
	
	return kCVReturnSuccess;
} */

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    int topPadding;
    if(self.style == TMCircularProgressDarkStyle) {
        topPadding = 5;
    } else {
        topPadding = 3;
    }
    
    NSPoint topCenter = { roundf(self.frame.size.width/2), self.frame.size.height-topPadding};
    NSPoint topWithoutPadding = { roundf(self.frame.size.width/2), self.frame.size.height};
    NSPoint center = { roundf(self.frame.size.width/2),roundf(self.frame.size.height/2) };
    
    NSBezierPath *path;
  //  NSPoint drawCancelPoint = self.style == TMCircularProgressLightStyle ? center
    
   //
    if(self.style == TMCircularProgressDarkStyle) {
        
       
        
      //  [NSColorFromRGBWithAlpha(0x000000, 1) setStroke];
        
//        path = [NSBezierPath bezierPath];
//        [path moveToPoint: topWithoutPadding];
//        [path appendBezierPathWithArcWithCenter: center
//                                         radius: roundf(self.frame.size.width/2)
//                                     startAngle: 100
//                                       endAngle: 90];
//        
//        
//        
//        [path stroke];
    } else {
        //  [self.cancelImage drawAtPoint:NSMakePoint(0, 0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
    
    path = [NSBezierPath bezierPath];
    [path moveToPoint: topCenter];
    float endAngel = (_currentAcceptProgress/(max-min))*360;
    endAngel = reversed ? endAngel : -endAngel;
    float startAngel = 90.f;
    [path appendBezierPathWithArcWithCenter: center
                                     radius: roundf(self.frame.size.width/ 2 - topPadding)
                                 startAngle: startAngel
                                   endAngle: endAngel+startAngel clockwise:YES];
    
    if(self.style == TMCircularProgressDarkStyle) {
    
        [NSColorFromRGBWithAlpha(0x000000, 0.50) setStroke];
    } else {
        
        [NSColorFromRGB(0xa0a0a0) setStroke];
    }
    
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
    [self setProgress:currentProgress animated:YES];
}

-(void)setProgress:(float)currentProgress animated:(BOOL)animated {
    
    if(currentProgress < self->min)
        self->_currentProgress = self->min;
    if(currentProgress > self->max)
        self->_currentProgress = self->max;
    else
        self->_currentProgress = currentProgress;
   
    if(currentProgress == min) {
        _currentAcceptProgress = min;
        [self setNeedsDisplay:YES];
    }
    
    if(currentProgress < _currentAcceptProgress) {
        _currentAcceptProgress = currentProgress;
        animated = NO;
    }
    
    
    if(!animated) {
        self->_currentAcceptProgress = self->_currentProgress;
        [self setNeedsDisplay:YES];
        return;
    }
    
    if(!self.timer && _currentAcceptProgress < _currentProgress) {
        self.timer = [[TGTimer alloc] initWithTimeout:1.f/fps repeat:YES completion:^{
            
            
            if(_currentAcceptProgress < _currentProgress) {
                float summ =  (_currentProgress - _currentAcceptProgress)/(fps*duration);
                if(summ < 0.1)
                    summ = 0.1;
                _currentAcceptProgress+= summ;
                
                [LoopingUtils runOnMainQueueAsync:^{
                    [self setNeedsDisplay:YES];
                }];
            } else {
                [self.timer invalidate];
                self.timer = nil;
            }
            
            if(_currentAcceptProgress == max) {
                _currentAcceptProgress = min;
            }
            
        } queue:[[ASQueue globalQueue] nativeQueue]];
        
        [self.timer start];
    }
    
    
}

-(void)setHidden:(BOOL)flag {
    [super setHidden:flag];
    if(flag) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)removeFromSuperview {
    [super removeFromSuperview];
    [self.timer invalidate];
    self.timer = nil;
}

@end
