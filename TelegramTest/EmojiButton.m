//
//  EmojiButton.m
//  Telegram
//
//  Created by keepcoder on 17.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "EmojiButton.h"
#import "TGCTextView.h"

@interface EmojiButton ()
@property (nonatomic,strong) NSTrackingArea *trackingArea;
@property (nonatomic,assign) BOOL mouseInView;
@property (nonatomic,assign) BOOL mouseIsDown;

@end

@implementation EmojiButton

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        
        
        
        
    }
    return self;
}
//
-(void)updateTrackingAreas
{
    if(_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }
    

    
    int opts = (NSTrackingCursorUpdate | NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInActiveApp | NSTrackingInVisibleRect);
    _trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                  options:opts
                                                    owner:self
                                                 userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSPoint mouse = [self convertPoint:[self.window convertScreenToBase:[NSEvent mouseLocation]] fromView:nil];
    
    
    [_list enumerateObjectsUsingBlock:^(NSAttributedString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(self.mouseInView && _mouseIsDown) {
            NSRect hrect = NSMakeRect(5 + idx * 34, 0, 34, 34);
            
            if(NSMinX(hrect) < mouse.x && NSMaxX(hrect) > mouse.x) {
                [_mouseIsDown ? NSColorFromRGB(0xdedede) : NSColorFromRGB(0xf4f4f4) setFill];

                NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:hrect xRadius:4 yRadius:4];
                
                [path fill];
            }
        }
        

        [obj drawInRect:NSMakeRect(6 + 5 + idx * 34, -7, 34, 34)];
        
    }];

}

-(BOOL)mouseInView {
    return NSPointInRect([self.superview.superview.superview convertPoint:[self.window convertScreenToBase:[NSEvent mouseLocation]] fromView:nil], self.superview.superview.frame);
}

-(void)scrollWheel:(NSEvent *)theEvent {
    
    [super scrollWheel:theEvent];
   
    BOOL mouseInView = _mouseInView;
    _mouseInView = NSPointInRect([self.superview convertPoint:[self.window convertScreenToBase:[NSEvent mouseLocation]] fromView:nil], self.frame);
    if(mouseInView != _mouseInView) {
        [self setNeedsDisplay:YES];
    }
}

-(void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    _mouseInView = YES;
    [self setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    _mouseInView = NO;
    [self setNeedsDisplay:YES];
    
}

-(void)mouseMoved:(NSEvent *)theEvent {
    [super mouseMoved:theEvent];
    [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)theEvent {
    //[super mouseDown:theEvent];
    _mouseIsDown = YES;
    [self setNeedsDisplay:YES];
}

-(void)mouseUp:(NSEvent *)theEvent {
    _mouseIsDown = NO;
    if(self.mouseInView && _emojiCallback) {
        NSPoint mouse = [self convertPoint:[self.window convertScreenToBase:[NSEvent mouseLocation]] fromView:nil];
        
        [_list enumerateObjectsUsingBlock:^(NSAttributedString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSRect hrect = NSMakeRect(0 + idx * 34, 0, 34, 34);
            
            if(NSMinX(hrect) < mouse.x && NSMaxX(hrect) > mouse.x) {
                *stop = YES;
                
                _emojiCallback(_list[idx].string);
                
            }
        }];
    }
    [self setNeedsDisplay:YES];
}



-(void)setList:(NSArray *)list {
    _list = list;
    _mouseInView = NO;
    _mouseIsDown = NO;
    [self setNeedsDisplay:YES];
}

@end
