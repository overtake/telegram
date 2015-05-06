//
//  TMButton.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/24/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMButton.h"

@interface TMButton()

@property (nonatomic) BOOL isHover;
@property (nonatomic) BOOL isPressed;

@property (nonatomic, strong) NSImage *bgImage;
@property (nonatomic, strong) NSColor *bgColor;

@property (nonatomic) NSTrackingArea *trackingArea;

@property (nonatomic, strong) id target;
@property (nonatomic) SEL selector;

@property (nonatomic, strong) NSImage *normalBackground;
@property (nonatomic, strong) NSImage *hoverBackground;
@property (nonatomic, strong) NSImage *pressedBackground;
@property (nonatomic, strong) NSImage *pressedHoverBackground;

@property (nonatomic, strong) NSColor *normalTextColor;
@property (nonatomic, strong) NSColor *hoverTextColor;
@property (nonatomic, strong) NSColor *pressedTextColor;
@property (nonatomic, strong) NSColor *pressedHoverTextColor;

@property (nonatomic,strong) NSColor *disabledTextColor;

@end

@implementation TMButton

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        self.isHover = NO;
        self.isPressed = NO;
        self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                         options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
                                                           owner:self
                                                        userInfo:nil];
        [self addTrackingArea:self.trackingArea];
        
        self.acceptCursor = YES;
//        [self.window invalidateCursorRectsForView:self.superview];
//        [self.window cursorUpdate:nil];
        
//        [self cursorUpdate:nil];
        [self cursorUpdate:nil];

    }
    return self;
}

- (void) setImage:(NSImage *)image forState:(TMButtonState)state {
    switch (state) {
        case TMButtonNormalHoverState:
            self.hoverBackground = image;
            break;
            
        case TMButtonNormalState:
            self.normalBackground = image;
            break;
            
        case TMButtonPressedHoverState:
            self.pressedHoverBackground = image;
            break;
        
        case TMButtonPressedState:
            self.pressedBackground = image;
            break;
    }
    
    
    
    [self setNeedsDisplay:YES];
}

- (void) setTextColor:(NSColor *)color forState:(TMButtonState)state {
    switch (state) {
        case TMButtonNormalHoverState:
            self.hoverTextColor = color;
            break;
        
        case TMButtonNormalState:
            self.normalTextColor = color;
            break;
            
        case TMButtonPressedHoverState:
            self.pressedHoverTextColor = color;
            break;
            
        case TMButtonPressedState:
            self.pressedTextColor = color;
            break;
        case TMButtonDisabledState:
            self.disabledTextColor = color;
            break;
            
        default:
            break;
    }
}

- (void) updateTrackingAreas {
    [self removeTrackingArea:self.trackingArea];
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow)
                                                  owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void) mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    
    self.isHover = NO;
    [self setNeedsDisplay:YES];
    [self.window invalidateCursorRectsForView:self];
}

- (void) mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    
    self.isHover = YES;
    [self.window invalidateCursorRectsForView:self];
    [self setNeedsDisplay:YES];
}

- (void) mouseDown:(NSEvent *)theEvent {
   // [super mouseDown:theEvent];
    
    if(!self.disabled) {
        if(self.target) {
            ((void (*)(id, SEL))[self.target methodForSelector:self.selector])(self.target, self.selector);
        }
    }
   
    
    self.isPressed = YES;
    [self setNeedsDisplay:YES];
}

- (void) mouseUp:(NSEvent *)theEvent {
  //  [super mouseUp:theEvent];
    
//    if(self.isHover) {
//        if(self.target) {
//            ((void (*)(id, SEL))[self.target methodForSelector:self.selector])(self.target, self.selector);
//        }
//    }
    
    self.isPressed = NO;
    [self setNeedsDisplay:YES];
}

//- (void)mouseDown:(NSEvent *)theEvent {
//    [super mouseDown:theEvent];
////    if(self.isHover) {
//    
////    }
//}

- (void) setPressed:(BOOL)isPressed {
    self.isPressed = YES;
    [self setNeedsDisplay:YES];
}

- (void) setDisabled:(BOOL)disabled {
    self->_disabled = disabled;
    [self.window invalidateCursorRectsForView:self];
    [[NSCursor arrowCursor] set];
    [self setNeedsDisplay:YES];
}

- (void) cursorUpdate:(NSEvent *)event {
    if(self.disabled || !self.selector || !self.target || !self.acceptCursor)
        return;
    
    NSCursor *cursor = [NSCursor pointingHandCursor];
    [cursor setOnMouseEntered:YES];
    [cursor set];
}

- (void) setNeedsDisplay:(BOOL)flag {
    
    if(self.disabled) {
        self.bgImage = self.normalBackground;
        self.bgColor = self.disabledTextColor ? self.disabledTextColor : self.normalTextColor;
    } else {
        if(self.isPressed) {
            self.bgImage = self.isHover && self.pressedHoverBackground ? self.pressedHoverBackground : self.pressedBackground;
            self.bgColor = self.isHover && self.pressedHoverTextColor ? self.pressedHoverTextColor : self.pressedHoverTextColor;
        } else {
            self.bgImage = self.isHover && self.hoverBackground ? self.hoverBackground : self.normalBackground;
            self.bgColor = self.isHover && self.hoverTextColor ? self.hoverTextColor : self.normalTextColor;
        }
    }
    
    if(!self.bgColor)
        self.bgColor = self.normalTextColor ? self.normalTextColor : [NSColor blackColor];
    
    [super setNeedsDisplay:flag];
}

- (NSDictionary *)getAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:self.textFont ? self.textFont : [NSFont systemFontOfSize:12], NSFontAttributeName, self.bgColor, NSForegroundColorAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
    return attributes;
}

- (void)setTextOffset:(NSSize) size {
    self->_textOffset = size;
    
    [self setNeedsDisplay:YES];
}

- (NSSize)sizeOfText {
    NSSize size = [self.text sizeWithAttributes:[self getAttributes]];
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    
  //  [self setWantsBestResolutionOpenGLSurface:YES];
    
    [self.bgImage drawInRect:self.bounds fromRect:self.bounds operation:NSCompositeSourceOver fraction:1];
    
    
    if(self.text) {
        NSDictionary *attributes = [self getAttributes];
        NSSize size = [self sizeOfText];
        
        
//        CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]
//                                              graphicsPort];
//        
//        CGContextSetAllowsFontSubpixelQuantization(context, true);
//        CGContextSetShouldSubpixelQuantizeFonts(context, true);
//        CGContextSetAllowsFontSubpixelPositioning(context, true);
//        CGContextSetShouldSubpixelPositionFonts(context, false);
//        CGContextSetAllowsAntialiasing(context,true);
       // CGContextSetShouldSmoothFonts(context, true);
       // CGContextSetAllowsFontSmoothing(context,true);
        
//        NSAttributedString *nsAttributedString = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
//        [nsAttributedString size]
        
//        MTLog(@"bounds %@", NSStringFromRect(self.bounds));
          NSRect rect = NSMakeRect(roundf((self.bounds.size.width - size.width) / 2) + self.textOffset.width, roundf((self.bounds.size.height - size.height) / 2)+ self.textOffset.height, size.width, size.height);
        
//        [[NSColor redColor] set] ;
//        NSRectFill( rect ) ;
        
        [self.text drawWithRect:rect options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes];
      
    
    }
}

- (void) setTarget:(id)target selector:(SEL)selector {
    self.selector = selector;
    self.target = target;
}

@end
