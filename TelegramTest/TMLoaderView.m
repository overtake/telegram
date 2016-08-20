//
//  TMLoaderView.m
//  Telegram
//
//  Created by keepcoder on 16.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMLoaderView.h"
#import "POPLayerExtras.h"
@interface TMLoaderView ()
@property (nonatomic,weak) id target;
@property (nonatomic,assign) SEL selector;
@property (nonatomic,strong) NSMutableDictionary *stateImages;


@property (nonatomic,strong) NSImageView *imageView;
@end

@implementation TMLoaderView

- (void)drawRect:(NSRect)dirtyRect {
    
    if(self.isHidden || !self.window) {
        [self pop_removeAllAnimations];
        return;
    }
    
    
    
    if(self.style == TMCircularProgressDarkStyle) {
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:self.bounds];
        [NSColorFromRGBWithAlpha(0x000000, 0.5) setFill];
        [path fill];
    }
    
    [super drawRect:dirtyRect];
    
    
}



-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.backgroundColor = [NSColor clearColor];
        
        self.wantsLayer = YES;
        self.imageView = [[NSImageView alloc] initWithFrame:self.bounds];
        
        self.stateImages = [[NSMutableDictionary alloc] init];
        [self addSubview:self.imageView];
        
    }
    
    return self;
}

-(void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    
    if(!hidden && [self.layer pop_animationForKey:@"opacity"]) {
        [self.layer pop_removeAllAnimations];
    }
    
    if(animated && hidden && !self.isHidden && ![self.layer pop_animationForKey:@"opacity"]) {
        
        float from = hidden ? 1.0f : 0.0f;
        float to = hidden ? 0.0f : 1.0f;
        
        POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
        
        animation.duration = 0.2;
        animation.fromValue = @(from);
        animation.toValue = @(to);
        animation.removedOnCompletion = YES;
        [self.layer pop_addAnimation:animation forKey:@"opacity"];
        
        [animation setCompletionBlock:^(POPAnimation *animation, BOOL complete) {
            if(complete) {
                [super setHidden:hidden];
                [self setNeedsDisplay:YES];
            }
        }];
        
    } else {
        self.layer.opacity = 1.0f;
        [super setHidden:hidden];
        
        if(!self.isHidden)
            [self setNeedsDisplay:YES];
    }
}

-(void)setHidden:(BOOL)hidden {
    [self setHidden:hidden animated:YES];
    
    
}

-(void)setImage:(NSImage *)image forState:(TMLoaderViewState)state {
    
    if(!image)
    {
        [_stateImages removeObjectForKey:@(state)];
    } else
    {
        _stateImages[@(state)] = image;
    }
    
    
    self.state = state;
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}

-(void)addTarget:(id)target selector:(SEL)selector {
    self.target = target;
    self.selector = selector;
}


-(void)setState:(TMLoaderViewState)state {
    self->_state = state;
    
    NSImage *image = _stateImages[@(state)];
    
    if(image) {
        [self.imageView setFrameSize:image.size];
        
        self.imageView.image = image;
        
        [self.imageView setCenterByView:self];
    }
    
    [self.imageView setHidden:!image];
    
    
    
    
    [self setNeedsDisplay:YES];
}


-(void)mouseUp:(NSEvent *)theEvent {
    if(self.target && self.selector) {
        [self.target performSelector:self.selector];
    } else {
        [super mouseUp:theEvent];
    }
}



@end
