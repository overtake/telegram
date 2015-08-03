//
//  TMTextLayer.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/3/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTextLayer.h"
#import "CALayerCategory.h"

@implementation TMTextLayer

- (id)init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

- (void)setTextColor:(NSColor *)color {
    self->_textColor = color;
    self.foregroundColor = color.CGColor;
}

- (void)setTextFont:(NSFont *)font {
    self->_textFont = font;
    
    [self setFont:(__bridge CFTypeRef)(CFBridgingRelease((__bridge CFTypeRef)(font.fontName)))];
    [self setFontSize:font.pointSize];
}

- (NSSize)size {
    if(!self->_textFont) {
        ELog(@"set text font");
        return NSZeroSize;
    }
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.string attributes:@{NSFontAttributeName: self->_textFont}];
    
    
    
    NSSize size = [attributedString size];
    
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
}

- (void)sizeToFit {
    NSSize size = [self size];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

@end
