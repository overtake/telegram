//
//  TGStickerImageView.m
//  Telegram
//
//  Created by keepcoder on 19.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGStickerImageView.h"


@interface TGStickerImageView ()
@property (nonatomic,assign,getter=isSelected) BOOL selected;
@property (nonatomic,strong) NSTrackingArea *trackingArea;

@end

@implementation TGStickerImageView

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [super drawLayer:layer inContext:ctx];
}



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    [NSColorFromRGB(0x000000) setFill];
    
    NSRectFill(dirtyRect);
    
    [GRAY_BORDER_COLOR setStroke];
    
    NSRectFill(dirtyRect);
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.selected = NO;
    }
    
    return self;
}

-(void)mouseEntered:(NSEvent *)theEvent {
    self.selected = YES;
}

-(void)mouseExited:(NSEvent *)theEvent {
    self.selected = NO;
}


-(void)setSelected:(BOOL)selected {
    _selected = selected;
    [self setNeedsDisplay:YES];
}

-(void)updateTrackingAreas
{
    if(_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }
    
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways | NSTrackingInVisibleRect);
    _trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                  options:opts
                                                    owner:self
                                                 userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

@end
