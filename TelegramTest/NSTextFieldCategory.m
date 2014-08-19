
//
//  NSTextFieldCategory.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSTextFieldCategory.h"

@implementation NSTextField (Key)

- (void)setSelectionRange:(NSRange)range {
    [self.textView setSelectedRange:range];
}

- (NSRange)selectedRange {
    return self.textView.selectedRange;
}

- (void)setCursorToEnd {
    [self setSelectionRange:NSMakeRange(self.stringValue.length, 0)];
}

- (void)setCursorToStart {
    [self setSelectionRange:NSMakeRange(0, 0)];
}

- (NSTextView *)textView {
   return (NSTextView *)[self.window fieldEditor:YES forObject:self];
}

-(NSDictionary *)attributes {
    
    __block NSDictionary *tAttr;
    
    [self.attributedStringValue enumerateAttributesInRange:self.attributedStringValue.range options:NSAttributedStringEnumerationReverse usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
         
         tAttr = attributes;
         
     }];
    
    return tAttr;
}



- (void) keyDown:(NSEvent *)theEvent {
    [super keyDown:theEvent];
    
}

@end
