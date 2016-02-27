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
    @public NSAttributedString *_text;
    @public CTLineRef _line;
    @public CGFloat _maxWidth;
    @public bool _truncateInTheMiddle;
    @public CGSize _lastSize;
    int _height;
}

@end

@implementation TGTextLabel

- (instancetype)initWithText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth
{
    return [self initWithText:text maxWidth:maxWidth truncateInTheMiddle:false];
}

- (instancetype)initWithText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth truncateInTheMiddle:(bool)truncateInTheMiddle
{
    self = [super init];
    if (self != nil)
    {
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
    
}

- (void)setText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth
{
    _height = 0;
    [self setText:text maxWidth:maxWidth needsContentUpdate:NULL];
}

- (void)setText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth height:(int)height {
    _height = height;
    [self setText:text maxWidth:maxWidth needsContentUpdate:NULL];
}

- (void)setText:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth needsContentUpdate:(bool *)needsContentUpdate
{
    text = text;
    
    _text = text;
    _maxWidth = maxWidth;
    
    if (_line != NULL)
    {
        CFRelease(_line);
        _line = nil;
    }
    
    if (_text != NULL)
    {
        _line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)_text);
        if (_line != NULL)
        {
            if (maxWidth < FLT_MAX - FLT_EPSILON)
            {
                
                float w = CTLineGetTypographicBounds(_line, NULL, NULL, NULL) - (float)CTLineGetTrailingWhitespaceWidth(_line);
                
                if (w > maxWidth)
                {
                    static NSString *tokenString = nil;
                    if (tokenString == nil)
                    {
                        unichar tokenChar = 0x2026;
                        tokenString = [[NSString alloc] initWithCharacters:&tokenChar length:1];
                    }
                    
                    NSRange range;
                    
                    int position = (int) CTLineGetStringIndexForPosition(_line, NSMakePoint(maxWidth - 22, 0));
                    

                    
                    if(position < 0)
                        position = 0;
                    if(position >= _text.length)
                        position = (int)_text.length - 1;
                    
                    
                    NSDictionary *attrs = [_text attributesAtIndex:position effectiveRange:&range];
                    
                    NSFont *font = [attrs objectForKey:NSFontAttributeName];
                    
                    if(!font)
                        font = TGSystemFont(13);
                    
                    NSColor *color = [attrs objectForKey:NSForegroundColorAttributeName];

                    if(!color)
                        color = TEXT_COLOR;
                    
                    NSDictionary *truncationTokenAttributes = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
                    
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
                bounds.size.width = ceil(bounds.size.width);
                bounds.size.height = _height == 0 ? floor(bounds.size.height) : _height;
                
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
    
    [self setNeedsDisplay:YES];
}


- (NSAttributedString *)text
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

   
    
    if(self.backgroundColor == nil) {
        self.backgroundColor = [NSColor whiteColor];
    }
    
    [self.backgroundColor setFill];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]
                                          graphicsPort];
    
    CGContextSetAllowsAntialiasing(context,true);
    CGContextSetShouldSmoothFonts(context, !IS_RETINA);
    CGContextSetAllowsFontSmoothing(context,!IS_RETINA);
    
    NSRectFill(self.bounds);
    
    if (_line != NULL) {
        
        
        CGFloat ascent;
        CGFloat descent;
        CTLineGetTypographicBounds(_line, &ascent, &descent, NULL);
      //  CGContextSetTextPosition(context, 0.0, (ascent + descent)-ascent);
        
        CGContextSetTextPosition(context, 0.0f, 2);
        CTLineDraw(_line, context);
    }
    
   
    [[NSGraphicsContext currentContext] restoreGraphicsState];

}

@end

