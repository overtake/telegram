//
//  EmojiButton.m
//  Telegram
//
//  Created by keepcoder on 17.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "EmojiButton.h"
#import "TGCTextView.h"
#import "SpacemanBlocks.h"
#import "TGRaceEmoji.h"


@interface EmojiButton () {
    SMDelayedBlockHandle _longHandle;
}
@property (nonatomic,strong) NSTrackingArea *trackingArea;
@property (nonatomic,assign) BOOL mouseInView;
@property (nonatomic,assign) BOOL mouseIsDown;
@property (nonatomic,assign) BOOL cancelInsertNext;

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

static TGRaceEmoji *e_race_controller;
static RBLPopover *race_popover;

-(void)mouseDown:(NSEvent *)theEvent {
    //[super mouseDown:theEvent];
    _mouseIsDown = YES;
    [self setNeedsDisplay:YES];
    
    _longHandle = perform_block_after_delay(0.3, ^{
        
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            e_race_controller = [[TGRaceEmoji alloc] initWithFrame:NSMakeRect(0, 0, 208, 38) emoji:nil];
            
            race_popover = [[RBLPopover alloc] initWithContentViewController:(NSViewController *) e_race_controller];
            
            [race_popover setDidCloseBlock:^(RBLPopover *popover){
                [self.controller.esgViewController.epopover setLockHoverClose:NO];
            }];
            
            [e_race_controller loadView];
            
            
        });
        
        e_race_controller.popover = race_popover;
        e_race_controller.controller = self.controller;
        
//        [race_popover setHoverView:self];
        [race_popover close];
        
        NSString *e = [self emojiBelowEvent:theEvent];
        
        if([e_race_controller makeWithEmoji:[e realEmoji:e]]) {
            
            [self.controller.esgViewController.epopover setLockHoverClose:YES];
            
            NSUInteger idx = [_list indexOfObjectPassingTest:^BOOL(NSAttributedString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if([obj.string isEqualToString:e])
                {
                    *stop = YES;
                    return YES;
                }
                
                return NO;
            }];
            
            NSRect frame = NSMakeRect(idx * 34 + 5, 3, 34, 34);
            
            if(!race_popover.isShown) {
                [race_popover showRelativeToRect:frame ofView:self preferredEdge:CGRectMaxYEdge];
            }
            
            _cancelInsertNext = YES;
            
        } else {
            [race_popover setHoverView:nil];
        }
    });

}

-(NSString *)emojiBelowEvent:(NSEvent *)theEvent {
    
    __block NSString *e = nil;
    if(self.mouseInView) {
        NSPoint mouse = [self convertPoint:[self.window convertScreenToBase:[NSEvent mouseLocation]] fromView:nil];
        
        [_list enumerateObjectsUsingBlock:^(NSAttributedString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSRect hrect = NSMakeRect(0 + idx * 34, 0, 34, 34);
            
            if(NSMinX(hrect) < mouse.x && NSMaxX(hrect) > mouse.x) {
                *stop = YES;
                
                e = _list[idx].string;
                
            }
        }];
    }
    
    return e;
   
}

-(void)mouseUp:(NSEvent *)theEvent {
    _mouseIsDown = NO;
    
    cancel_delayed_block(_longHandle);
    
    if(!_cancelInsertNext) {
        
        if(_emojiCallback) {
            NSString *e = [self emojiBelowEvent:theEvent];
            _emojiCallback(e);
        }
        
        if(race_popover.isShown) {
            [race_popover close];
        }
        [self.controller.esgViewController.epopover setLockHoverClose:NO];
    }
    
    
    
    _cancelInsertNext = NO;
    
    
    [self setNeedsDisplay:YES];
}



-(void)setList:(NSArray *)list {
    _list = list;
    _mouseInView = NO;
    _mouseIsDown = NO;
    [self setNeedsDisplay:YES];
}

@end
