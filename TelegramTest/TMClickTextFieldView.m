//
//  TMClickTextFieldView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 31.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMClickTextFieldView.h"

@interface TMClickTextFieldView ()
@property (nonatomic,strong) NSTrackingArea *trackingArea;
@end

@implementation TMClickTextFieldView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        _trackingArea = [[NSTrackingArea alloc]initWithRect:[self bounds] options: (NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow) owner:self userInfo:nil];
        [self addTrackingArea:_trackingArea];
    }
    
    return self;
}

- (void)mouseMoved:(NSEvent *)event
{
    [[NSCursor pointingHandCursor] set];
}

-(void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    [[NSCursor arrowCursor] set];
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    if(self.callback != nil) {
        self.callback();
    }
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    [self removeTrackingArea:_trackingArea];
    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options: (NSTrackingMouseMoved | NSTrackingActiveInKeyWindow | NSTrackingMouseEnteredAndExited) owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
  
    // Drawing code here.
}

@end
