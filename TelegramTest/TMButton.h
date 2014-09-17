//
//  TMButton.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/24/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMView.h"

typedef enum {
    TMButtonNormalState,
    TMButtonNormalHoverState,
    TMButtonPressedState,
    TMButtonPressedHoverState,
    TMButtonDisabledState
} TMButtonState;

@interface TMButton : TMView

@property (nonatomic) BOOL disabled;

@property (nonatomic,assign) NSSize textOffset;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSFont *textFont;
@property (nonatomic,assign) BOOL acceptCursor;
- (void)setImage:(NSImage *)image forState:(TMButtonState)state;
- (void)setTextColor:(NSColor *)color forState:(TMButtonState)state;
- (void)setTarget:(id)target selector:(SEL)selector;
- (void)setPressed:(BOOL)isPressed;
- (NSDictionary *)getAttributes;
- (NSSize)sizeOfText;

@end
