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
#import "TGAnimationBlockDelegate.h"
#import "TGTextLabel.h"
@interface TGModalView ()
@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) TMView *backgroundView;

@property (nonatomic,strong) TMView *animationContainerView;
@property (nonatomic,strong) NSTrackingArea *trackingArea;

@property (nonatomic,strong) TGTextLabel *textLabel;
@property (nonatomic,strong) TMView *headerContainer;

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

-(void)setDrawHeaderSeparator:(BOOL)drawHeaderSeparator {
    _drawHeaderSeparator = drawHeaderSeparator;
    [_headerContainer setNeedsDisplay:YES];
}

-(void)enableHeader:(NSString *)header {
    
    _headerContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width, 50)];
    
    weak();
    
    [_headerContainer setDrawBlock:^{
        
        if(weakSelf.isDrawHeaderSeparator) {
            [GRAY_BORDER_COLOR set];
            NSRectFill(NSMakeRect(0, 0, NSWidth(weakSelf.headerContainer.frame), DIALOG_BORDER_WIDTH));
        }
        
    }];
    
    TGTextLabel *textLabel = [[TGTextLabel alloc] init];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    [attr appendString:header withColor:TEXT_COLOR];
    [attr setFont:TGSystemMediumFont(15) forRange:attr.range];
    
    [textLabel setText:attr maxWidth:self.containerSize.width];
    
    _textLabel = textLabel;
    
    [_headerContainer addSubview:_textLabel];
    
    [self addSubview:_headerContainer];
    
}

-(void)enableCancelAndOkButton {
    weak();
    
    _ok = [[BTRButton alloc] initWithFrame:NSZeroRect];
    _ok.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    [_ok setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
    [_ok setTitleFont:TGSystemMediumFont(15) forControlState:BTRControlStateNormal];
    [_ok setTitle:NSLocalizedString(@"Modal.Done", nil) forControlState:BTRControlStateNormal];
    [_ok.titleLabel sizeToFit];
    [_ok setFrameSize:NSMakeSize(NSWidth(_ok.titleLabel.frame), 50)];
    
    [_ok addBlock:^(BTRControlEvents events) {
        
        [weakSelf okAction];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    
    [self addSubview:_ok];
    
     _cancel = [[BTRButton alloc] initWithFrame:NSZeroRect];
    _cancel.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    [_cancel setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
    [_cancel setTitleFont:TGSystemMediumFont(15) forControlState:BTRControlStateNormal];
    [_cancel setTitle:NSLocalizedString(@"Cancel", nil) forControlState:BTRControlStateNormal];
    
    [_cancel.titleLabel sizeToFit];
    [_cancel setFrameSize:NSMakeSize(NSWidth(_cancel.titleLabel.frame), 50)];
    
    [_cancel addBlock:^(BTRControlEvents events) {
        
        [weakSelf cancelAction];
        
    } forControlEvents:BTRControlEventMouseDownInside];
    
    [self addSubview:_cancel];
    
    
    
    
//    TMView *separator = [[TMView alloc] initWithFrame:NSMakeRect(0, 49, self.containerSize.width, 1)];
//    [separator setBackgroundColor:DIALOG_BORDER_COLOR];
//    
//    separator.autoresizingMask = NSViewWidthSizable;
//    [self addSubview:separator];

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

-(int)topOffset {
    return NSHeight(_headerContainer.frame);
}
-(int)bottomOffset {
    return _ok ? 50 : 0;
}


-(void)addScrollEvent:(TMTableView *)table {
    id clipView = [[table enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didScrolledTableView:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)_didScrolledTableView:(NSNotification *)notification {
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
    
    if(![self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_animationContainerView.frame]) {
        [self close:YES];
    }
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    
    NSArray *modals = [TMViewController modalsView];
    
    [modals enumerateObjectsUsingBlock:^(TGModalView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:[TGModalView class]]) {
            // TO DO
            //NSLog(@"%@",obj);
        }
        
    }];

    
    
    [_backgroundView setFrameSize:newSize];
    
    [_backgroundView setCenterByView:self];
    
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
    
    [window.contentView.subviews[0] addSubview:self];

    [self setFrameSize:window.contentView.frame.size];
    
    [self setContainerFrameSize:self.containerSize];
    
    
    [window makeFirstResponder:self];
    
    [window update];
    
    self.layer.opacity = 1;
    
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:NSWindowDidBecomeKeyNotification object:window];

    if(animated) {
        

        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:kPOPLayerOpacity];
        anim.timingFunction = [CAMediaTimingFunction easeOutQuint];
        anim.fromValue = @(0.0f);
        anim.toValue = @(1.0f);
        anim.duration = 0.2;
        
        
        weak();
        
        TGAnimationBlockDelegate *delegate = [[TGAnimationBlockDelegate alloc] initWithLayer:self.layer];
        
        [delegate setCompletion:^(BOOL completed) {
            [weakSelf modalViewDidShow];
        }];
        
        anim.delegate = delegate;
        
        [self.containerView.layer addAnimation:anim forKey:@"fade"];
        
        self.containerView.layer.opacity = 1.0f;
        

        
        
        CABasicAnimation *slide = [CABasicAnimation animationWithKeyPath:kPOPLayerPosition];
        slide.duration = 0.2;
        slide.fromValue = [NSValue valueWithPoint:NSMakePoint(NSMinX(_animationContainerView.frame), -NSHeight(self.animationContainerView.frame))];
        slide.toValue = [NSValue valueWithPoint:NSMakePoint(NSMinX(_animationContainerView.frame), roundf((NSHeight(self.frame) - NSHeight(self.animationContainerView.frame))/2))];;
        slide.timingFunction = [CAMediaTimingFunction easeOutQuint];
        slide.removedOnCompletion = YES;
        
        
        [self.animationContainerView.layer addAnimation: slide forKey:@"slide"];
        
        [self.animationContainerView.layer setPosition:NSMakePoint(NSMinX(_animationContainerView.frame), roundf((NSHeight(self.frame) - NSHeight(self.animationContainerView.frame))/2))];
        [self.animationContainerView setFrameOrigin:NSMakePoint(NSMinX(_animationContainerView.frame), roundf((NSHeight(self.frame) - NSHeight(self.animationContainerView.frame))/2))];



        
        
    } else {
         [self modalViewDidShow];
    }


    
}



-(void)close:(BOOL)animated {
    
    if(self.window && self.animationContainerView.layer.opacity > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSWindowDidBecomeKeyNotification object:self.window];
        
        if(animated) {
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:kPOPLayerOpacity];
            anim.timingFunction = [CAMediaTimingFunction easeOutQuint];
            anim.fromValue = @(1.0f);
            anim.toValue = @(0.0f);
            anim.duration = 0.2;
            
            
            
            weak();
            
            TGAnimationBlockDelegate *delegate = [[TGAnimationBlockDelegate alloc] initWithLayer:self.layer];
            
            [delegate setCompletion:^(BOOL completed) {
                [weakSelf removeFromSuperview];
                [weakSelf modalViewDidHide];
            }];
            
            anim.delegate = delegate;

            [self.animationContainerView.layer addAnimation:anim forKey:@"fade"];
            [self.backgroundView.layer addAnimation:anim forKey:@"fade"];
            
            self.animationContainerView.layer.opacity = self.backgroundView.layer.opacity = 0.0f;
            
            
//
//            [self.layer pop_addAnimation:anim forKey:@"fade"];
            
            
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

-(void)rightMouseDown:(NSEvent *)theEvent {
    
}

-(void)rightMouseUp:(NSEvent *)theEvent {
    
}


-(void)keyUp:(NSEvent *)theEvent {
    if(theEvent.keyCode == 53) {
        [self close:YES];
    } else if(isEnterAccess(theEvent)) {
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
    
    
//    [_ok setFrame:NSMakeRect(self.containerSize.width/2, 0, self.containerSize.width/2, 49)];
//    [_cancel setFrame:NSMakeRect(0, 0, self.containerSize.width/2, 50)];
//
    [_headerContainer setFrameSize:NSMakeSize(size.width, NSHeight(_headerContainer.frame))];
    
    [_textLabel setText:_textLabel.text maxWidth:size.width - 100];
    [_textLabel setCenterByView:_textLabel.superview];
    
    [_headerContainer setFrameOrigin:NSMakePoint(0, size.height - NSHeight(_headerContainer.frame))];

    
    [_ok setFrameOrigin:NSMakePoint(size.width - NSWidth(_ok.frame) - 30, 0)];
    [_cancel setFrameOrigin:NSMakePoint(NSMinX(_ok.frame) - NSWidth(_cancel.frame) -30 , 0)];

}

-(NSSize)containerSize {
    return _containerView.frame.size;
}

-(void)dealloc {
    [self removeScrollEvent];
}

@end
