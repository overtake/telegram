//
//  TGTextLabel.h
//  Telegram
//
//  Created by keepcoder on 22/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGFont.h"
@interface TGTextLabel : TMView

@property (nonatomic, strong) NSColor *textColor;

- (instancetype)initWithText:(NSString *)text textColor:(NSColor *)textColor font:(CTFontRef)font maxWidth:(CGFloat)maxWidth;
- (instancetype)initWithText:(NSString *)text textColor:(NSColor *)textColor font:(CTFontRef)font maxWidth:(CGFloat)maxWidth truncateInTheMiddle:(bool)truncateInTheMiddle;

- (void)setText:(NSString *)text maxWidth:(CGFloat)maxWidth;
- (void)setText:(NSString *)text maxWidth:(CGFloat)maxWidth needsContentUpdate:(bool *)needsContentUpdate;
- (NSString *)text;
- (void)setMaxWidth:(CGFloat)maxWidth;
@end
