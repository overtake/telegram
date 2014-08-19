//
//  NSString+ContainerSize.m
//
//  Created by Michael Robinson on 6/03/12.
//  License: http://pagesofinterest.net/license/
//
//  Based on the Stack Overflow answer: http://stackoverflow.com/a/1993376/187954
//

#import "NSString+Size.h"

@implementation NSString (Size)

- (NSSize) sizeWithWidth:(float)width andFont:(NSFont *)font {
    
    NSSize size = NSMakeSize(width, FLT_MAX);
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:size];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:font
                        range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    
    size.height = [layoutManager usedRectForTextContainer:textContainer].size.height;
    
//    [layoutManager release];
//    [textContainer release];
//    [textStorage release];
    
    return size;
}

@end
