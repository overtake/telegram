//
//  NSAttributedStringGeometrySizes.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSAttributedStringCategory.h"
#import <AppKit/AppKit.h>
@implementation NSAttributedString (Category)

static NSTextField *testTextField() {
    static NSTextField *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSTextField alloc] init];
        [instance setBordered:NO];
        [instance setEditable:NO];
        [instance setBezeled:NO];
        [instance setSelectable:NO];
    });
    return instance;
}

- (NSSize)sizeForTextFieldForWidth:(int)width {
    
    NSTextField *textField = testTextField();
    [textField setAttributedStringValue:self];
    NSSize size = [[textField cell] cellSizeForBounds:NSMakeRect(0, 0, width, FLT_MAX)];
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
    

}

-(NSSize)coreTextSizeForTextFieldForWidth:(int)width {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) self);
    
    
    
    CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,self.length), NULL, CGSizeMake(width, CGFLOAT_MAX), NULL);
    
    textSize.width= ceil(textSize.width);
    textSize.height = ceil(textSize.height);
    
    
    CFRelease(framesetter);
    
    return textSize;
}

- (NSSize)coreTextSizeForTextFieldForWidth:(int)width withPaths:(NSArray *)paths {
    
    CTFrameRef CTFrame;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    [paths enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
            
        CGPathAddRect(path, NULL, [obj rectValue]);
    }];

    
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) self);
    
    
    CTFrame = CTFramesetterCreateFrame(framesetter,
                                       CFRangeMake(0, 0), path, NULL);
    
    
    CFArrayRef lines = CTFrameGetLines(CTFrame);
    
    
    int height = 0;
    
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(CTFrameGetLines(CTFrame), i);
        
        CGFloat ascent, descent, leading;
        
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        height+= floor(ascent + floor(descent) + leading);
    }
    
    CFRelease(framesetter);
    CFRelease(CTFrame);
    CFRelease(path);
    
    
    return NSMakeSize(width, height );
    
}

- (NSRange)range {
    return NSMakeRange(0, self.length);
}


-(NSRange)selectRange:(NSSize)frameSize startPoint:(NSPoint)startPoint currentPoint:(NSPoint)currentPoint {
    
    
    NSRange selectedRange = NSMakeRange(NSNotFound, 0);
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    
    CGPathAddRect(path, NULL, NSMakeRect(0, 0, frameSize.width, frameSize.height));
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) self);
    
    CTFrameRef CTFrame = CTFramesetterCreateFrame(framesetter,
                                       CFRangeMake(0, 0), path, NULL);
    
    CFRelease(path);
    CFRelease(framesetter);
    
    
    if( (currentPoint.x != -1 && currentPoint.y != -1)) {
        
        
        CFArrayRef lines = CTFrameGetLines(CTFrame);
        
        CGPoint origins[CFArrayGetCount(lines)];
        
        CTFrameGetLineOrigins(CTFrame, CFRangeMake(0, 0), origins);
        
        int startSelectLineIndex = [self lineIndex:origins count:(int) CFArrayGetCount(lines) location:startPoint frame:CTFrame frameSize:frameSize];
        
        int currentSelectLineIndex = [self lineIndex:origins count:(int) CFArrayGetCount(lines) location:currentPoint frame:CTFrame frameSize:frameSize];
        
        int dif = abs(startSelectLineIndex - currentSelectLineIndex);
        
        
        BOOL isReversed = currentSelectLineIndex < startSelectLineIndex;
        
        
        for (int i = startSelectLineIndex; isReversed ? i >= currentSelectLineIndex : i <= currentSelectLineIndex ; isReversed ? i-- : i++)
        {
            
            
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            
            CFRange lineRange = CTLineGetStringRange(line);
            
            
            CFIndex startIndex,endIndex;

            startIndex  = CTLineGetStringIndexForPosition(line, startPoint);
                
            endIndex = CTLineGetStringIndexForPosition(line, currentPoint);
            
            
            if( dif > 0 ) {
                if(i != currentSelectLineIndex) {
                    endIndex = ( lineRange.length + lineRange.location );
                }
                
                if(i != startSelectLineIndex) {
                    startIndex = lineRange.location;
                }
                
                if(isReversed) {
                    
                    if(i == startSelectLineIndex) {
                        endIndex = startIndex;
                        startIndex = lineRange.location;
                    }
                    
                    if(i == currentSelectLineIndex) {
                        startIndex = endIndex;
                        endIndex = ( lineRange.length + lineRange.location );
                    }
                    
                }
                
            }
            
            
            if(startIndex > endIndex) {
                startIndex = endIndex+startIndex;
                endIndex = startIndex - endIndex;
                startIndex = startIndex - endIndex;
            }
            
            if( abs((int)startIndex - (int)endIndex) > 0 && ( selectedRange.location == NSNotFound || selectedRange.location > startIndex)) {
                selectedRange.location = startIndex;
            }
                
            selectedRange.length += (endIndex - startIndex);
                        
        }
    }
    
    CFRelease(CTFrame);
    
    return selectedRange;
    
}


-(BOOL)isCurrentLine:(NSPoint)position linePosition:(NSPoint)linePosition idx:(int)idx frame:(CTFrameRef)CTFrame {
    
    CTLineRef line = CFArrayGetValueAtIndex(CTFrameGetLines(CTFrame), idx);
    
    CGFloat ascent, descent, leading;
    
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    int lineHeight = ceil(ascent + ceil(descent) + leading);
    
    return (position.y > linePosition.y) && position.y <= (linePosition.y + lineHeight);
}



-(int)lineIndex:(CGPoint[])origins count:(int)count location:(NSPoint)location frame:(CTFrameRef)CTFrame frameSize:(NSSize)frameSize {
    
    for (int i = 0; i < count; i++) {
        if([self isCurrentLine:location linePosition:origins[i] idx:i frame:CTFrame])
            return i;
    }
    
    return location.y >= frameSize.height ? 0 : (count -1);
}




@end
