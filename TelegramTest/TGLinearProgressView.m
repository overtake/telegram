//
//  TGLinearProgressView.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//


#import "TGLinearProgressView.h"

#import "TGTimer.h"

@interface TGLinearProgressView ()
@property (nonatomic,strong) TGTimer *timer;
@property (nonatomic,assign) float currentAcceptProgress;
@end

@implementation TGLinearProgressView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self->min = 0;
        self->max = 100;
        self->duration = 0.2;
        self->fps = 60;
        self.currentProgress = 0;
        self->_backgroundColor = LINK_COLOR;
        
        
        self.wantsLayer = YES;

        
    }
    return self;
}




- (void)drawRect:(NSRect)dirtyRect
{
    if(self.isHidden)
        return;
    
    [super drawRect:dirtyRect];
    
    float currentProgress = (_currentAcceptProgress/(max-min));
    
    [_backgroundColor setFill];
    
    int cw = NSWidth(dirtyRect) * currentProgress;
    
    NSRectFill(NSMakeRect(0, 0, cw, NSHeight(dirtyRect)));
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
        [self setNeedsDisplay:YES];
        return;
    }
    
    if(self.isHidden || currentProgress == min)
    {
        [self.timer invalidate];
        self.timer = nil;
        [self setNeedsDisplay:YES];
        return;
    }
    
  
    if(!self.timer) {
        self.timer = [[TGTimer alloc] initWithTimeout:1.f/fps repeat:YES completion:^{
            
            if(_currentAcceptProgress < _currentProgress) {
                float summ =  (_currentProgress - _currentAcceptProgress)/(fps*duration);
                if(summ < step)
                    summ = step;
                _currentAcceptProgress+= summ;
                
            }
            
            if(_currentAcceptProgress == max) {
                _currentAcceptProgress = min;
            }
            
            
            [ASQueue dispatchOnMainQueue:^{
                [self setNeedsDisplay:YES];
            }];
            
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
