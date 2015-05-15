//
//  TGModalView.m
//  Telegram
//
//  Created by keepcoder on 08.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGModalView.h"
#import "TGAllStickersTableView.h"
@interface TGModalView ()
@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) TMView *backgroundView;
@end

@implementation TGModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
       [self initializeModalView];
    }
    
    return self;
}


-(void)initializeModalView {
    
    
    self.wantsLayer = YES;
    
    self.layer.backgroundColor = [NSColor clearColor].CGColor;
    
    _backgroundView = [[TMView alloc] initWithFrame:self.bounds];
    
    self.autoresizingMask =  _backgroundView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    _backgroundView.wantsLayer = YES;
    
    _backgroundView.layer.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.6).CGColor;
    
    _containerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
    
    _containerView.wantsLayer = YES;
    _containerView.layer.cornerRadius = 4;
    
    _containerView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    
    
    [_containerView setCenterByView:self];
    
    [super addSubview:_backgroundView];
    [super addSubview:_containerView];
    
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    if(![self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_containerView.frame]) {
        [self close:YES];
    }
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_backgroundView setFrameSize:newSize];
    [_containerView setCenterByView:self];
}

-(void)show:(NSWindow *)window animated:(BOOL)animated {
    
    [self setFrameSize:window.frame.size];
    
    [window.contentView addSubview:self];
    
    [window makeFirstResponder:self];

    if(!animated) {
        
        self.layer.opacity = 0;
        
        [[[Telegram delegate] window] makeFirstResponder:self];
        
        POPBasicAnimation *anim = [TMViewController popAnimationForProgress:self.layer.opacity to:1];
        
        [self.layer pop_addAnimation:anim forKey:@"fade"];
        
    }


}
-(void)close:(BOOL)animated {
    
    if(animated) {
        POPBasicAnimation *anim = [TMViewController popAnimationForProgress:self.layer.opacity to:0];
        
        [anim setCompletionBlock:^(POPAnimation *anim, BOOL success) {
            [self removeFromSuperview];
        }];
        
        [self.layer pop_addAnimation:anim forKey:@"fade"];

    } else {
        [self removeFromSuperview];
    }
    
   
}


-(void)mouseUp:(NSEvent *)theEvent {
    
}

-(void)scrollWheel:(NSEvent *)theEvent {
    
}

-(void)keyDown:(NSEvent *)theEvent {
    
}

-(void)keyUp:(NSEvent *)theEvent {
    
}

-(void)mouseMoved:(NSEvent *)theEvent {
    
}

-(void)mouseEntered:(NSEvent *)theEvent {
    
}


-(void)mouseExited:(NSEvent *)theEvent {
    
}

-(void)addSubview:(NSView *)aView {
    [_containerView addSubview:aView];
}

-(void)setContainerFrameSize:(NSSize)size {
    [_containerView setFrameSize:size];
    
    [_containerView setCenterByView:self];
}

-(NSSize)containerSize {
    return _containerView.frame.size;
}

@end
