//
//  TMAttributedString.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (TM)

- (void)setSelected:(BOOL)isSelected;
- (BOOL)isSelected;
- (void)setSelectionColor:(NSColor*)selectionColor forColor:(NSColor*)color;
- (void)setSelectionAttachment:(NSTextAttachment *)selectionAttachment forAttachment:(NSTextAttachment *)attachment;
- (void)clear;


- (NSRange)appendString:(NSString *)string;
- (NSRange)appendString:(NSString *)string withColor:(NSColor*)color;
- (void)setFont:(NSFont *)font forRange:(NSRange)range;
- (void)setCTFont:(NSFont *)font forRange:(NSRange)range;
- (void)setLink:(NSString *)link forRange:(NSRange)range;
- (void)setLink:(NSString *)link withColor:(NSColor *)color forRange:(NSRange)range;

+ (NSAttributedString *)attributedStringByImage:(NSImage *)image;
+ (NSTextAttachment *)textAttachmentByImage:(NSImage *)image;
+ (NSRange)selectText:(NSString *)text fromAttributedString:(NSMutableAttributedString*)attributed selectionColor:(NSColor *)color;

@end
