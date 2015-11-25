//
//  TGAudioProgressView.m
//  Telegram
//
//  Created by keepcoder on 02.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGAudioProgressView.h"

@interface TGAudioProgressView ()
@property (nonatomic,assign) BOOL isUserUpdate;
@end

@implementation TGAudioProgressView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xDCDCDC) setFill];
    
    NSRectFill(NSMakeRect(0, 0, NSWidth(dirtyRect), 4));
    
    
    if(_downloadProgress != 0) {
        int width = roundf(NSWidth(self.frame) * ((float)_downloadProgress/100.0f));
        
        [NSColorFromRGB(0x7F7F7F) set];
        NSRectFill(NSMakeRect(0, 0, width, 4));
    }
    
    
    int width = roundf(NSWidth(self.frame) * ((float)_currentProgress/100.0f));
    
    [BLUE_UI_COLOR set];
    NSRectFill(NSMakeRect(0, 0, width, 4));
    
    
    
    
    if(_showDivider) {
        [NSColorFromRGB(0x000000) set];
        NSRectFill(NSMakeRect(width, 0, 3, 10));
    }
    
}



-(void)mouseDown:(NSEvent *)theEvent {
    
    if(_disableChanges)
        return;
    
    _isUserUpdate = YES;
    
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    [self updateByPoint:point];
    
}


-(void)updateByPoint:(NSPoint)point {
    point.x = MAX(0,MIN(point.x,NSWidth(self.frame)));
    
    _currentProgress = (point.x/NSWidth(self.frame)) * 100;
    
    [self setNeedsDisplay:YES];
}

-(void)mouseUp:(NSEvent *)theEvent {
    
    if(_disableChanges)
        return;
    
    _isUserUpdate = NO;
    
    if(_progressCallback)
    {
        _progressCallback(_currentProgress);
    }
    
}


-(void)mouseDragged:(NSEvent *)theEvent {
    
    if(_disableChanges)
        return;
    
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    [self updateByPoint:point];
}


-(void)setCurrentProgress:(int)currentProgress {
    
    if(!_isUserUpdate)
    {
        _currentProgress = MAX(0,MIN(100,currentProgress));
        
        [self setNeedsDisplay:YES];
    }
    
    
}

-(void)setDownloadProgress:(int)downloadProgress {
    
    _downloadProgress = MAX(0,MIN(100,downloadProgress));
    
     [self setNeedsDisplay:YES];
    
}

-(void)setShowDivider:(BOOL)showDivider {
    _showDivider = showDivider;
    
    [self setNeedsDisplay:YES];
}


@end
