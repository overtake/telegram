//
//  ConnectionStatusViewControllerView.m
//  Telegram
//
//  Created by keepcoder on 03.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ConnectionStatusViewControllerView.h"
#import "TGTimer.h"
#import "MessagesViewController.h"
@interface ConnectionStatusViewControllerView ()
@property (nonatomic,strong) TMTextField *field;
@property (nonatomic,strong) TGTimer *animationTimer;
@property (nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,assign) NSRect origin;
@property (nonatomic,assign) BOOL isShown;
@end


@implementation ConnectionStatusViewControllerView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.wantsLayer = YES;
        self.origin = frame;
       // self.backgroundColor = NSColorFromRGB(0xcccccc);
      //  self.layer.cornerRadius = 4;
        
        self.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin | NSViewMaxXMargin | NSViewMinXMargin;
        
        self.field = [TMTextField defaultTextField];
        
        
        [self.field setTextColor:NSColorFromRGB(0xffffff)];
        
        self.field.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
        
        [self.field setFont:[NSFont fontWithName:@"HelveticaNeue" size:13]];
        
        [self addSubview:self.field];
        
        _state = INT16_MAX;
        
        self.state = ConnectingStatusTypeConnecting;
        
        
    }
    return self;
}

-(BOOL)isFlipped {
    return YES;
}


static NSString *stateString[5];
static NSColor *stateColor[5];

-(void)setState:(ConnectingStatusType)state {
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stateColor[ConnectingStatusTypeConnecting] = NSColorFromRGB(0xe8bc5d);
        stateColor[ConnectingStatusTypeConnected] = NSColorFromRGB(0x81d36e);
        stateColor[ConnectingStatusTypeWaitingNetwork] = NSColorFromRGB(0xff7d70);
        stateColor[ConnectingStatusTypeUpdating] = NSColorFromRGB(0xe8bc5d);
        stateColor[ConnectingStatusTypeNormal] = NSColorFromRGB(0x81d36e);
        
        stateString[ConnectingStatusTypeConnecting] = NSLocalizedString(@"Connecting.Connecting",nil);
        stateString[ConnectingStatusTypeConnected] = NSLocalizedString(@"Connecting.Connected",nil);
        stateString[ConnectingStatusTypeWaitingNetwork] = NSLocalizedString(@"Connecting.WaitingNetwork",nil);
        stateString[ConnectingStatusTypeUpdating] = NSLocalizedString(@"Connecting.Updating",nil);
        stateString[ConnectingStatusTypeNormal] = NSLocalizedString(@"Connecting.Updated",nil);
    });
    
   

    
    [LoopingUtils runOnMainQueueAsync:^{
        
        ConnectingStatusType oldState = _state;
        if(state == _state)
            return;
        
        self->_state = state;
        
        self.backgroundColor = stateColor[state];
        
        [self setString:stateString[state]];
        
        [self setNeedsDisplay:YES];
        
        if(_state == ConnectingStatusTypeNormal || (oldState == ConnectingStatusTypeNormal && (_state == ConnectingStatusTypeConnected))) {
            [self hideAfter:1.0 withState:ConnectingStatusTypeNormal];
            return;
        } else {
            if(!self.isShown) {
                [self show:YES];
            }
        }
        
       
        
        if(self.state != ConnectingStatusTypeConnected) {
            [self startAnimation];
        } else {
            
            [self hideAfter:1.0 withState:ConnectingStatusTypeConnected];
        }
    
        
    }];
}

- (void)hideAfter:(float)time withState:(ConnectingStatusType)state {
    [self stopAnimation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_state == state) {
            [self hide:YES];
        }
    });
}

- (void)hide:(BOOL)animated {
    if(self.isShown) {
        self.isShown = NO;
        [self.controller hideConnectionController:animated];
    }
    
//    self.alphaValue = 1.0f;
//    
//    if(animated) {
//        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//            [context setDuration:.3];
//            [[self animator] setAlphaValue:0.0f];
//            [[self animator] setFrame:NSOffsetRect(self.frame, 0, self.frame.size.height)];
//            
//        } completionHandler:^{
//            [self setHidden:YES];
//        }];
//    } else {
//        self.alphaValue = 0.0f;
//        [self setFrame:NSOffsetRect(self.frame, 0, self.frame.size.height)];
//    }
//  
    //[self.layer pop_addAnimation:anim forKey:@"posY"];
}

- (void)show:(BOOL)animated {
    if(!self.isShown) {
        self.isShown = YES;
        [self.controller showConnectionController:animated];
    }
    
    
//    [self setHidden:NO];
//    self.alphaValue = 0.0f;
//    if(animated) {
//        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//            [context setDuration:.3];
//            [self.animator setAlphaValue:1.0];
//            [[self animator] setFrame:NSOffsetRect(self.frame, 0, -self.frame.size.height)];
//            
//        } completionHandler:^{
//            
//        }];
//    } else {
//        self.alphaValue = 1.0f;
//        [self setFrame:NSOffsetRect(self.frame, 0, -self.frame.size.height)];
//    }
}

- (void)setString:(NSString *)string update:(BOOL)update {
    [self.field setStringValue:string];
    
    [self.field sizeToFit];
    
    if(update)
    {
        [self.field setCenterByView:self];
        
        self.field.frame = NSOffsetRect(self.field.frame, 0, -2);
    }
    
}

-(void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    [self setString:self.field.stringValue update:YES];
}

- (void)setFrameOrigin:(NSPoint)newOrigin {
    [super setFrameOrigin:newOrigin];
    [self setString:self.field.stringValue update:YES];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [self setString:self.field.stringValue update:YES];
}


- (void)setString:(NSString *)string {
    [self setString:string update:YES];
}

- (void)startAnimation {
    if(!self.animationTimer) {
        self.animationTimer = [[TGTimer alloc] initWithTimeout:0.35 repeat:YES completion:^{
            
            
            NSMutableString *string = [self.field.stringValue mutableCopy];
            
            if([[string substringFromIndex:string.length - 3] isEqualToString:@"..."]) {
                string = [[string substringToIndex:string.length-3] mutableCopy];
            }
            
            [string appendString:@"."];
            
            [self setString:string update:NO];
            
            
        } queue:dispatch_get_main_queue()];
        
        [self.animationTimer start];
    }

}

- (void)stopAnimation {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
//    CGFloat cornerRadius = 8;
//    
//    NSBezierPath *path = [NSBezierPath bezierPath];
//    
//    // Start drawing from upper left corner
//    [path moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))];
//    
//    // Draw top border and a top-right rounded corner
//    NSPoint topRightCorner = NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds));
//    [path lineToPoint:NSMakePoint(NSMaxX(self.bounds) - cornerRadius, NSMinY(self.bounds))];
//    [path curveToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds) + cornerRadius)
//         controlPoint1:topRightCorner
//         controlPoint2:topRightCorner];
//    
//    // Draw right border, bottom border and left border
//    [path lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
//    [path lineToPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds))];
//    [path lineToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))];
    
    // Fill path
    [self.backgroundColor setFill];
    //[path fill];
    
}

@end
