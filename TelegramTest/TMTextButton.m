//
//  TMTextButton.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/21/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTextButton.h"

@interface TMTextButton()
@property (nonatomic) NSTrackingArea *trackingArea;
@property (nonatomic, strong) NSColor *normalColor;
@end

@implementation TMTextButton

- (id)init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) updateTrackingAreas {
    [self removeTrackingArea:self.trackingArea];
    
    
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                     options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingInVisibleRect)
                                                       owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void)initialize {
    [self updateTrackingAreas];
    [self setBordered:NO];
    [self setBezeled:NO];
    [self setDrawsBackground:NO];
    [self setEditable:NO];
    [self setSelectable:NO];
}

+ (instancetype)standartUserProfileButtonWithTitle:(NSString *)title {
    TMTextButton *button = [[TMTextButton alloc] init];
    [button setStringValue:title];
    [button setFont:[NSFont fontWithName:@"Helvetica-Light" size:15]];
    [button setTextColor:BLUE_UI_COLOR];
    [button sizeToFit];
    return button;
}

+ (instancetype)standartUserProfileNavigationButtonWithTitle:(NSString *)title {
    TMTextButton *button = [[TMTextButton alloc] init];
    [button setStringValue:title];
    [button setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
    [button setTextColor:BLUE_UI_COLOR];
  //  [button setWantsLayer:YES];
    [button sizeToFit];
    [button setFrameOrigin:NSMakePoint(0, 1)];
    return button;
}

+ (instancetype)standartMessageNavigationButtonWithTitle:(NSString *)title {
    TMTextButton *button = [[TMTextButton alloc] init];
    [button setStringValue:title];
    [button setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
    [button setTextColor:BLUE_UI_COLOR];
    [button sizeToFit];
    //[button setWantsLayer:YES];
    
    return button;
}

- (void) cursorUpdate:(NSEvent *)event {
//    if([self.window.contentView hitTest:event.locationInWindow] == self && !self.disable) { //cursoroff
//        NSCursor *cursor = [NSCursor pointingHandCursor];
//        [cursor setOnMouseEntered:YES];
//        [cursor set];
//    }
}

- (void)setDisable:(BOOL)disable {
    if(self->_disable == disable) {
        return;
    }
    
    self->_disable = disable;
    
    if(self.disable) {
        self.normalColor = self.textColor;
        if(self.disableColor)
            [super setTextColor:self.disableColor];
        
    } else {
        [super setTextColor:self.normalColor];
    }
}

- (void)setTextColor:(NSColor *)color {
    if(!self.disable) {
        self.normalColor = color;
    }
    [super setTextColor:color];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if(self.disable)
        return;
    
    if(self.tapBlock)
        self.tapBlock();
    else
        [super mouseDown:theEvent];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    [self.window invalidateCursorRectsForView:self];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    [self.window invalidateCursorRectsForView:self];
}

@end
