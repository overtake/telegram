//
//  TGTextLabel.m
//  Telegram
//
//  Created by keepcoder on 22/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGTextLabel.h"


@interface TGTextLabel ()
{
    @public NSString *_text;
    @public CTLineRef _line;
    @public CTFontRef _font;
    @public CGFloat _maxWidth;
    @public bool _truncateInTheMiddle;
    @public CGSize _lastSize;
}

@end

@implementation TGTextLabel

- (instancetype)initWithText:(NSString *)text textColor:(NSColor *)textColor font:(CTFontRef)font maxWidth:(CGFloat)maxWidth
{
    return [self initWithText:text textColor:textColor font:font maxWidth:maxWidth truncateInTheMiddle:false];
}

- (instancetype)initWithText:(NSString *)text textColor:(NSColor *)textColor font:(CTFontRef)font maxWidth:(CGFloat)maxWidth truncateInTheMiddle:(bool)truncateInTheMiddle
{
    self = [super init];
    if (self != nil)
    {
        
        _textColor = textColor;
        
        if (font != NULL)
            _font = CFRetain(font);
        
        _truncateInTheMiddle = truncateInTheMiddle;
        
        [self setText:text maxWidth:maxWidth];
    }
    return self;
}

- (void)dealloc
{
    if (_line != NULL)
    {
        CFRelease(_line);
        _line = NULL;
    }
    
    if (_font != NULL)
    {
        CFRelease(_font);
        _font = nil;
    }
}

- (void)setText:(NSString *)text maxWidth:(CGFloat)maxWidth
{
    [self setText:text maxWidth:maxWidth needsContentUpdate:NULL];
}

- (void)setText:(NSString *)text maxWidth:(CGFloat)maxWidth needsContentUpdate:(bool *)needsContentUpdate
{
    text = text ? : @"";
    
    _text = text;
    _maxWidth = maxWidth;
    
    if (_line != NULL)
    {
        CFRelease(_line);
        _line = nil;
    }
    
    if (_font != NULL)
    {
        _line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)[[NSAttributedString alloc] initWithString:text attributes:[[NSDictionary alloc] initWithObjectsAndKeys:(__bridge id)_font, (__bridge id)kCTFontAttributeName, kCFBooleanTrue, (__bridge id)kCTForegroundColorFromContextAttributeName, nil]]);
        if (_line != NULL)
        {
            if (maxWidth < FLT_MAX - FLT_EPSILON)
            {
                if (CTLineGetTypographicBounds(_line, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(_line) > maxWidth)
                {
                    static NSString *tokenString = nil;
                    if (tokenString == nil)
                    {
                        unichar tokenChar = 0x2026;
                        tokenString = [[NSString alloc] initWithCharacters:&tokenChar length:1];
                    }
                    
                    NSMutableDictionary *truncationTokenAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(__bridge id)_font, (NSString *)kCTFontAttributeName, (__bridge id)_textColor.CGColor, (NSString *)kCTForegroundColorAttributeName, nil];
                    
                    NSAttributedString *truncationTokenString = [[NSAttributedString alloc] initWithString:tokenString attributes:truncationTokenAttributes];
                    CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationTokenString);
                    
                    CTLineRef truncatedLine = CTLineCreateTruncatedLine(_line, maxWidth, _truncateInTheMiddle ? kCTLineTruncationMiddle : kCTLineTruncationEnd, truncationToken);
                    CFRelease(truncationToken);
                    
                    CFRelease(_line);
                    _line = truncatedLine;
                }
            }
            
            if (_line != NULL)
            {
                CGRect bounds = CTLineGetBoundsWithOptions(_line, 0);
                bounds.origin = CGPointZero;
                bounds.size.width = floor(bounds.size.width);
                bounds.size.height = floor(bounds.size.height);
                if (!CGRectIsNull(bounds))
                {
                    CGRect frame = self.frame;
                    frame.size = bounds.size;
                    self.frame = frame;
                }
                
                if (needsContentUpdate)
                    *needsContentUpdate = CGSizeEqualToSize(bounds.size, _lastSize);
                _lastSize = bounds.size;
            }
        }
    }
    
    //[self setNeedsDisplay:YES];
}

- (NSString *)text
{
    return _text;
}

- (void)setMaxWidth:(CGFloat)maxWidth
{
    if (ABS(_maxWidth - maxWidth) > FLT_EPSILON)
    {
        _maxWidth = maxWidth;
        [self setText:_text maxWidth:_maxWidth];
    }
}

-(void)drawRect:(NSRect)dirtyRect
{

    [self.backgroundColor setFill];
    
    if(self.backgroundColor == nil) {
        self.backgroundColor = [NSColor whiteColor];
    }
    
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]
                                          graphicsPort];
    
    CGContextSetAllowsAntialiasing(context,true);
    CGContextSetShouldSmoothFonts(context, !IS_RETINA);
    CGContextSetAllowsFontSmoothing(context,!IS_RETINA);
    
    
    CGContextSetTextPosition(context, 0.0f, 2);
    
    NSRectFill(self.bounds);

    
    if (_textColor == nil)
        CGContextSetFillColorWithColor(context, [NSColor blackColor].CGColor);
    else
        CGContextSetFillColorWithColor(context, _textColor.CGColor);
    
    if (_line != NULL)
        CTLineDraw(_line, context);
    

}

@end


//@implementation TGTextLabel
//{
//    _TGTextLLayer *_textLayer;
//}
//
//- (instancetype)initWithText:(NSString *)text textColor:(NSColor *)textColor font:(CTFontRef)font maxWidth:(CGFloat)maxWidth {
//    return [self initWithText:text textColor:textColor font:font maxWidth:maxWidth truncateInTheMiddle:false];
//}
//- (instancetype)initWithText:(NSString *)text textColor:(NSColor *)textColor font:(CTFontRef)font maxWidth:(CGFloat)maxWidth truncateInTheMiddle:(bool)truncateInTheMiddle {
//    if(self = [super init]) {
//        _textLayer = [[_TGTextLLayer alloc] initWithText:text textColor:textColor font:font maxWidth:maxWidth truncateInTheMiddle:truncateInTheMiddle];
//        
//        self.wantsLayer = YES;
//        [self setLayer:_textLayer];
//    }
//    
//    return self;
//}
//
//
//
//- (void)setText:(NSString *)text maxWidth:(CGFloat)maxWidth {
//    
//    bool update = YES;
//    
//    [self setText:text maxWidth:maxWidth needsContentUpdate:&update];
//}
//- (void)setText:(NSString *)text maxWidth:(CGFloat)maxWidth needsContentUpdate:(bool *)needsContentUpdate {
//
//
//    [_textLayer setText:text maxWidth:maxWidth needsContentUpdate:needsContentUpdate];
//    
//    if(needsContentUpdate)
//    {
//         [self setFrameSize:_textLayer.frame.size];
//    }
//   
//}
//- (NSString *)text {
//    return _textLayer->_text;
//}
//
//-(void)setTextColor:(NSColor *)textColor {
//    _textLayer->_textColor = textColor;
//}
//
//-(NSColor *)textColor {
//    return _textLayer->_textColor;
//}
//
//- (void)setMaxWidth:(CGFloat)maxWidth {
//    [_textLayer setMaxWidth:maxWidth];
//}

//@end