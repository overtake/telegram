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


@property (nonatomic,strong) NSImage *standartImage;
@property (nonatomic,strong) NSImage *disabledImage;


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
    [button setFont:TGSystemLightFont(14)];
    [button setTextColor:BLUE_UI_COLOR];
    [button setWantsLayer:YES];
    [button sizeToFit];
    return button;
}

+ (instancetype)standartUserProfileNavigationButtonWithTitle:(NSString *)title {
    TMTextButton *button = [[TMTextButton alloc] init];
    [button setStringValue:title];
    [button setFont:TGSystemFont(14)];
    [button setTextColor:BLUE_UI_COLOR];
    [button setWantsLayer:YES];
    [button sizeToFit];
    [button setFrameOrigin:NSMakePoint(0, 0)];
    return button;
}

+ (instancetype)standartMessageNavigationButtonWithTitle:(NSString *)title {
    TMTextButton *button = [[TMTextButton alloc] init];
    [button setStringValue:title];
    [button setFont:TGSystemFont(14)];
    [button setTextColor:BLUE_UI_COLOR];
    [button setWantsLayer:YES];
    [button sizeToFit];
    [button setFrameOrigin:NSMakePoint(0,0)];
    
    return button;
}


+ (instancetype)standartButtonWithTitle:(NSString *)title standartImage:(NSImage *)standartImage disabledImage:(NSImage *)disabledImage {
    TMTextButton *button = [[TMTextButton alloc] init];
    [button setStringValue:title];
    [button setFont:TGSystemFont(14)];
    [button setTextColor:BLUE_UI_COLOR];
    [button setWantsLayer:YES];
    [button sizeToFit];
    [button setFrameOrigin:NSMakePoint(0,0)];
    [button setAlignment:NSRightTextAlignment];

    
    button.standartImage = standartImage;
    button.disabledImage = disabledImage;
    
    NSImageView *imageView = imageViewWithImage(standartImage);

    [button setFrameSize:NSMakeSize(NSWidth(button.frame) + imageView.frame.size.width + 5, 24)];
    
    
    
    [button addSubview:imageView];
    
  
    
    
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
    
    if( self.subviews.count > 0 ){
        
        NSImageView *imageView = self.subviews[0];
        
        imageView.image = self.disable ? self.disabledImage : self.standartImage;
        
        [imageView setFrameSize:NSMakeSize(20, 20)];
        
        [imageView setFrameOrigin:NSMakePoint(0, 1)];
    
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
