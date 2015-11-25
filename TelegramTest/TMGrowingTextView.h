//
//  TMGrowingTextView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/24/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMScrollView.h"
#import "TMView.h"

@protocol TMGrowingTextViewDelegate <NSObject>

- (void) TMGrowingTextViewHeightChanged:(id)textView height:(int)height cleared:(BOOL)isCleared;
- (BOOL) TMGrowingTextViewCommandOrControlPressed:(id)textView isCommandPressed:(BOOL)isCommandPressed;
- (void) TMGrowingTextViewTextDidChange:(id)textView;
- (void) TMGrowingTextViewFirstResponder:(id)textView isFirstResponder:(BOOL)isFirstResponder;


@end

@interface TMGrowingTextView : NSTextView<NSTextViewDelegate>

typedef enum {
    TMGrowingModeSingleLine,
    TMGrowingModeMultiLine
} TMGrowingMode;


@property (nonatomic) NSUInteger lastHeight;

@property (nonatomic,assign) BOOL disableAnimation;

@property (nonatomic,assign) TMGrowingMode mode;
@property (nonatomic) int rightPadding;
@property (nonatomic, strong) TMScrollView *scrollView;
@property (nonatomic, strong) TMView *containerView;
@property (nonatomic,assign) int limit;

@property (nonatomic,assign) int maxHeight;
@property (nonatomic,assign) int minHeight;

@property (nonatomic,assign) BOOL disabledBorder;

//@property (nonatomic) int maxLines;
@property (nonatomic, strong) id<TMGrowingTextViewDelegate> growingDelegate;
@property (nonatomic, strong) NSImage *backgroundImage;
- (void)setPlaceholderString:(NSString *)placeHodlder;
- (NSString *)stringValue;

- (BOOL)isEnterEvent:(NSEvent *)e;
- (BOOL)isControlEnterEvent:(NSEvent *)e;
- (BOOL)isCommandEnterEvent:(NSEvent *)e;


@end


