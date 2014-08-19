//
//  NSTextFieldCategory.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTextField (Key)

- (void)setSelectionRange:(NSRange)range;
- (void)setCursorToEnd;
- (NSRange)selectedRange;
- (void)setCursorToStart;
- (NSTextView *)textView;

@end
