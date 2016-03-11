//
//  TGWaveformView.m
//  Telegram
//
//  Created by keepcoder on 07/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGWaveformView.h"

@interface TGWaveformView ()
@property (nonatomic,strong) NSMutableArray *currentWaveform;
@end

@implementation TGWaveformView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
    }
    
    return self;
}

-(void)setWaveform:(NSArray *)waveform {
    
    NSMutableArray *arr = [waveform mutableCopy];
    
    __block int k = 0;
    
    [waveform enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx % 2 == 0) {
            [arr removeObjectAtIndex:idx-k];
            k++;
        }
    }];
    
    _waveform = arr;
    [_currentWaveform removeAllObjects];
    [self setNeedsDisplay:YES];
}

-(void)setProgress:(int)progress {
    _progress = progress;
    
    [self setNeedsDisplay:YES];
}





- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(_waveform.count == 0)
        return;
    
    if(_currentWaveform.count == 0) {
        _currentWaveform = [_waveform mutableCopy];
    }
    
    if(NSWidth(dirtyRect) < 200) {
        
        int maxCount = ceil(NSWidth(dirtyRect)/3);
        
        if(_currentWaveform.count != maxCount-1) {
             _currentWaveform = [_waveform mutableCopy];
            
            while (_currentWaveform.count >= maxCount) {
                int rand = rand_limit((int)_currentWaveform.count -1);
                
                [_currentWaveform removeObjectAtIndex:rand];
            }
        }

    } else {
        _currentWaveform = [_waveform mutableCopy];
    }
    
    int itemWidth = 2;
    
    float max = NSHeight(dirtyRect);
    
    __block int x = 0;
    
    NSColor *defColor = _defaultColor ? _defaultColor : GRAY_BORDER_COLOR;
    NSColor *progressColor = _progressColor ? _progressColor : BLUE_UI_COLOR;
    
    int progressWidth = (self.progress * NSWidth(dirtyRect))/100.0f;
    
    
    [_currentWaveform enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        int waveHeight = floor(([obj intValue] * max)/31.0f);
        
        waveHeight = [obj intValue] <= 2 ? [obj intValue] + 2 : MAX(waveHeight,2);
        
         NSBezierPath *itemPath = [NSBezierPath bezierPath];
        
        [itemPath appendBezierPathWithRoundedRect:NSMakeRect(x, 0, itemWidth, waveHeight) xRadius:0 yRadius:0];
        
        if(x >= progressWidth)
            [defColor setFill];
        else
            [progressColor setFill];
        [itemPath fill];
        
        x+=itemWidth+1;
    }];
    
}


@end
