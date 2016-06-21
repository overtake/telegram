//
//  TGModalView.m
//  Telegram
//
//  Created by keepcoder on 08.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGModalView.h"
#import "TGAllStickersTableView.h"
#import "CAMediaTimingFunction+AdditionalEquations.h"
@interface TGModalView ()
@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) TMView *backgroundView;

@property (nonatomic,strong) TMView *animationContainerView;
@property (nonatomic,strong) NSTrackingArea *trackingArea;

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

-(void)enableCancelAndOkButton {
    weak();
    
    _ok = [[BTRButton alloc] initWithFrame:NSMakeRect(self.containerSize.width/2, 0, self.containerSize.width/2, 49)];
    _ok.autoresizingMask = NSViewWidthSizable;
    _ok.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    [_ok setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
    [_ok setTitleFont:TGSystemFont(15) forControlState:BTRControlStateNormal];
    [_ok setTitle:NSLocalizedString(@"OK", nil) forControlState:BTRControlStateNormal];
    
    [_ok addBlock:^(BTRControlEvents events) {
        
        [weakSelf okAction];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    
    [self addSubview:_ok];
    
    
    
    _cancel = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width/2, 50)];
    _cancel.autoresizingMask = NSViewWidthSizable;
    _cancel.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    [_cancel setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
    [_cancel setTitleFont:TGSystemFont(15) forControlState:BTRControlStateNormal];
    [_cancel setTitle:NSLocalizedString(@"Cancel", nil) forControlState:BTRControlStateNormal];
    
    [_cancel addBlock:^(BTRControlEvents events) {
        
        [weakSelf cancelAction];
        
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    [self addSubview:_cancel];
    
    
    TMView *separator = [[TMView alloc] initWithFrame:NSMakeRect(0, 49, self.containerSize.width, 1)];
    [separator setBackgroundColor:DIALOG_BORDER_COLOR];
    
    separator.autoresizingMask = NSViewWidthSizable;
    [self addSubview:separator];

}


-(void)okAction {
    
}

-(void)cancelAction {
    [self close:YES];
}

-(void)initializeModalView {
    
    self.wantsLayer = YES;
    
    self.layer.backgroundColor = [NSColor clearColor].CGColor;
    
    _backgroundView = [[TMView alloc] initWithFrame:self.bounds];
    
    self.autoresizingMask = _backgroundView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    _backgroundView.wantsLayer = YES;
    
    _backgroundView.layer.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.6).CGColor;
    
    _containerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
    
    _containerView.wantsLayer = YES;
//    _containerView.layer.cornerRadius = 4;
    
    _containerView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    
    [super addSubview:_backgroundView];
    
    
    
    _animationContainerView = [[TMView alloc] initWithFrame:_containerView.bounds];
    
    _animationContainerView.wantsLayer = YES;
    _animationContainerView.layer.cornerRadius = 4;
    _animationContainerView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    [_animationContainerView addSubview:_containerView];
    
    [super addSubview:_animationContainerView];

}

-(void)mouseDown:(NSEvent *)theEvent {
    
    
    if(![self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_animationContainerView.frame]) {
        [self close:YES];
    }
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_backgroundView setFrameSize:newSize];
    
    [self setContainerFrameSize:self.containerSize];
    
}

-(void)updateTrackingAreas
{
    if(_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }
    

    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInActiveApp | NSTrackingInVisibleRect);
    _trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                  options:opts
                                                    owner:self
                                                 userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

-(void)show:(NSWindow *)window animated:(BOOL)animated {
    

    [self setFrameSize:window.contentView.frame.size];
    
    [self setContainerFrameSize:self.containerSize];
    
    [window.contentView.subviews[0] addSubview:self];
    
    [window makeFirstResponder:self];
    
    [window update];
    
    self.layer.opacity = 1;
    
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:NSWindowDidBecomeKeyNotification object:window];

    if(animated) {
        
        self.containerView.layer.opacity = 0;

        
        POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
        anim.timingFunction = [CAMediaTimingFunction easeOutQuint];
        anim.fromValue = @(self.containerView.layer.opacity);
        anim.toValue = @(1.0);
        anim.duration = 0.2;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [self.containerView.layer pop_addAnimation:anim forKey:@"fade"];
        
        weak();
        
        [anim setCompletionBlock:^(POPAnimation *pop, BOOL anim) {
            [weakSelf modalViewDidShow];
        }];
        
        
        POPBasicAnimation *slide = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        slide.duration = 0.2;
        slide.fromValue = @(-NSHeight(self.animationContainerView.frame));
        slide.toValue = @(roundf((NSHeight(self.frame) - NSHeight(self.animationContainerView.frame))/2));
        slide.timingFunction = [CAMediaTimingFunction easeOutQuint];
        slide.removedOnCompletion = YES;
        [self.animationContainerView.layer pop_addAnimation: slide forKey:@"slide"];
        

        [slide setCompletionBlock:^(POPAnimation *pop, BOOL anim) {
          
        }];

        
        
    } else {
         [self modalViewDidShow];
    }


    
}



-(void)close:(BOOL)animated {
    
    if(self.window) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSWindowDidBecomeKeyNotification object:self.window];
        
        if(animated) {
            POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
            anim.timingFunction = [CAMediaTimingFunction easeInQuint];
            anim.fromValue = @(self.layer.opacity);
            anim.toValue = @(0.0f);
            anim.duration = 0.2;
            [self.containerView.layer pop_addAnimation:anim forKey:@"fade"];
            
            weak();
            
            [anim setCompletionBlock:^(POPAnimation *anim, BOOL success) {
                [weakSelf removeFromSuperview];
                [weakSelf modalViewDidHide];
            }];
            
            [self.layer pop_addAnimation:anim forKey:@"fade"];
            
            
        } else {
            [self removeFromSuperview];
        }
        [self resignFirstResponder];
        
        [self modalViewDidHide];
    }
    
    
    
    
    
    
}

-(void)setOpaqueContent:(BOOL)opaqueContent {
    _opaqueContent = opaqueContent;
    _animationContainerView.layer.backgroundColor = self.containerView.layer.backgroundColor = _opaqueContent ? [NSColor clearColor].CGColor : [NSColor whiteColor].CGColor;
    _animationContainerView.layer.cornerRadius = self.containerView.layer.cornerRadius = _opaqueContent ? 0 : 4;
}

-(void)modalViewDidShow {
    [self setContainerFrameSize:self.containerSize];
}
-(void)modalViewDidHide {
    
}

-(BOOL)isShown {
    return self.window != nil;
}

-(NSRect)contentRect {
    return self.animationContainerView.frame;
}

-(void)mouseUp:(NSEvent *)theEvent {
    
}

-(void)scrollWheel:(NSEvent *)theEvent {
    
}

-(void)keyDown:(NSEvent *)theEvent {
    
}


-(void)keyUp:(NSEvent *)theEvent {
    if(theEvent.keyCode == 53) {
        [self close:YES];
    } else if(theEvent.keyCode == 36) {
        [self okAction];
        
    }
}

-(void)mouseMoved:(NSEvent *)theEvent {
    
}

-(void)mouseEntered:(NSEvent *)theEvent {
    
}
-(void)mouseDragged:(NSEvent *)theEvent {
    
}


-(void)mouseExited:(NSEvent *)theEvent {
    
}

-(void)addSubview:(NSView *)aView {
    [_containerView addSubview:aView];
}

-(void)setContainerFrameSize:(NSSize)size {
    
    [_containerView setFrameSize:size];
    [_animationContainerView setFrameSize:size];
    
    float x = roundf((NSWidth(self.frame) - NSWidth(_animationContainerView.frame)) / 2);
    float y = roundf((NSHeight(self.frame) - NSHeight(_animationContainerView.frame) ) / 2);
    
    [_animationContainerView setFrameOrigin:NSMakePoint(x,y)];
    
    
    [_ok setFrame:NSMakeRect(self.containerSize.width/2, 0, self.containerSize.width/2, 49)];
    [_cancel setFrame:NSMakeRect(0, 0, self.containerSize.width/2, 50)];
}

-(NSSize)containerSize {
    return _containerView.frame.size;
}

@end
