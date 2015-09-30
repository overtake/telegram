//
//  OEXTokenAttachmentCell.m
//  OEXTokenField
//
//  Created by Nicolas BACHSCHMIDT on 16/03/2013.
//  Copyright (c) 2013 Octiplex. All rights reserved.
//

#import "TMTokenCell.h"

static CGFloat const kOEXTokenAttachmentTitleMargin = 5;
static CGFloat const kOEXTokenAttachmentTokenMargin = 5;
static CGFloat const kLOL = 0;


@implementation TMTokenCell
{
    // Theses ivars are set at the begining of the draw
    OEXTokenDrawingMode _drawingMode;
    OEXTokenJoinStyle   _joinStyle;
}

#pragma mark - Geometry

- (id)initTextCell:(NSString *)aString {
    self = [super initTextCell:aString];
    self.font = TGSystemLightFont(12);
    return self;
}

- (NSPoint)cellBaselineOffset
{
    return NSMakePoint(0, self.font.descender);
}

- (NSSize)cellSize
{
    NSSize titleSize = [self.stringValue sizeWithAttributes:@{NSFontAttributeName:self.font}];
//    titleSize.width += 4
    titleSize.height += 4;
    return [self cellSizeForTitleSize:titleSize];
}

- (NSSize)cellSizeForTitleSize:(NSSize)titleSize
{
    NSSize size = titleSize;
    // Add margins + height for the token rounded edges
    size.width += size.height + kOEXTokenAttachmentTitleMargin * 2;
    size.height += kLOL;
    NSRect rect = {NSZeroPoint, size};
    return NSIntegralRect(rect).size;
}

- (NSRect)titleRectForBounds:(NSRect)bounds
{
    bounds.size.height -= kLOL;
    bounds.size.width = MAX(bounds.size.width, kOEXTokenAttachmentTitleMargin * 2 + bounds.size.height);
    
    return NSInsetRect(bounds, kOEXTokenAttachmentTitleMargin + bounds.size.height / 2, 0);
}

#pragma mark - Drawing

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager
{
    _drawingMode = OEXTokenDrawingModeDefault;
    _joinStyle = OEXTokenJoinStyleNone;
    
    if ( [controlView respondsToSelector:@selector(selectedRanges)] )
    {
        for ( NSValue *rangeValue in [(id) controlView selectedRanges] )
        {
            NSRange range = rangeValue.rangeValue;
            if ( ! NSLocationInRange(charIndex, range) )
                continue;
            
//            if ( controlView.window.isKeyWindow )
                _drawingMode = OEXTokenDrawingModeSelected;
            
            // TODO: RTL is not supported yet
            if ( range.location < charIndex )
                _joinStyle |= OEXTokenJoinStyleLeft;
            if ( NSMaxRange(range) > charIndex + 1 )
                _joinStyle |= OEXTokenJoinStyleRight;
        }
    }
    
    [self drawTokenWithFrame:cellFrame inView:controlView];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [self drawWithFrame:cellFrame inView:controlView characterIndex:NSNotFound layoutManager:nil];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [self drawWithFrame:cellFrame inView:controlView characterIndex:NSNotFound layoutManager:nil];
}

- (void)drawTokenWithFrame:(NSRect)rect inView:(NSView *)controlView
{
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    NSColor *fillColor = [self tokenFillColorForDrawingMode:self.tokenDrawingMode];
    NSColor *strokeColor = [self tokenStrokeColorForDrawingMode:self.tokenDrawingMode];
    
    NSBezierPath *path = [self tokenPathForBounds:rect joinStyle:self.tokenJoinStyle];
    [path addClip];
    
    if ( fillColor ) {
        [fillColor setFill];
        [path fill];
    }
    
    if ( strokeColor ) {
        [strokeColor setStroke];
        [path stroke];
    }
    
    [self drawTitleWithFrame:[self titleRectForBounds:rect] inView:controlView];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)drawTitleWithFrame:(NSRect)rect inView:(NSView *)controlView;
{
    rect.origin.y += 2;
    NSColor *textColor = [self tokenTitleColorForDrawingMode:self.tokenDrawingMode];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.stringValue drawInRect:rect withAttributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName:textColor, NSParagraphStyleAttributeName:style}];
}

#pragma mark - State

- (OEXTokenDrawingMode)tokenDrawingMode
{
    return _drawingMode;
}

- (OEXTokenJoinStyle)tokenJoinStyle
{
    return _joinStyle;
}

- (NSColor *)tokenFillColorForDrawingMode:(OEXTokenDrawingMode)drawingMode
{
    // Those colors are Stolen From Apple
    switch ( drawingMode )
    {
        case OEXTokenDrawingModeDefault:
            return [NSColor colorWithDeviceRed:0.8706 green:0.9059 blue:0.9725 alpha:1];
        case OEXTokenDrawingModeHighlighted:
            return [NSColor colorWithDeviceRed:0.7330 green:0.8078 blue:0.9451 alpha:1];
        case OEXTokenDrawingModeSelected:
            return [NSColor colorWithDeviceRed:0.3490 green:0.5451 blue:0.9255 alpha:1];
    }
}

- (NSColor *)tokenStrokeColorForDrawingMode:(OEXTokenDrawingMode)drawingMode
{
    // Those colors are Stolen From Apple
    switch ( drawingMode )
    {
        case OEXTokenDrawingModeDefault:
            return [NSColor colorWithDeviceRed:0.6431 green:0.7412 blue:0.9255 alpha:1];
        case OEXTokenDrawingModeHighlighted:
            return [NSColor colorWithDeviceRed:0.4275 green:0.5843 blue:0.8784 alpha:1];
        case OEXTokenDrawingModeSelected:
            return [NSColor colorWithDeviceRed:0.3490 green:0.5451 blue:0.9255 alpha:1];
    }
}

- (NSColor *)tokenTitleColorForDrawingMode:(OEXTokenDrawingMode)drawingMode
{
    switch ( drawingMode )
    {
        case OEXTokenDrawingModeDefault:
        case OEXTokenDrawingModeHighlighted:
            return [NSColor controlTextColor];
        case OEXTokenDrawingModeSelected:
            return [NSColor alternateSelectedControlTextColor];
    }
}

#pragma mark - Geometry

- (NSBezierPath *)tokenPathForBounds:(NSRect)bounds joinStyle:(OEXTokenJoinStyle)jointStyle
{
    

    bounds.size.height -= kLOL;
    bounds.size.width = MAX(bounds.size.width, kOEXTokenAttachmentTokenMargin * 2 + bounds.size.height);
    
    jointStyle = 0;
    
    CGFloat radius = bounds.size.height / 2;
    CGRect innerRect = NSInsetRect(bounds, kOEXTokenAttachmentTokenMargin + radius, 0);
//    innerRect.origin.y = 2;
    
//    bounds.origin.y = kLOL/2;
    
//    CGFloat x0 = NSMinX(bounds);
    CGFloat x1 = NSMinX(innerRect);
    CGFloat x2 = NSMaxX(innerRect);
//    CGFloat x3 = NSMaxX(bounds);
    CGFloat minY = NSMinY(bounds);
    CGFloat maxY = NSMaxY(bounds);
    CGFloat midY = NSMidY(bounds);
    
    NSBezierPath *path = [NSBezierPath new];
//    [path moveToPoint:NSMakePoint(x1, minY)];
    
    
    midY += kLOL/2;
    maxY -= kLOL/2;
    minY += kLOL/2;
    
//    // Left edge
//    if ( jointStyle & OEXTokenJoinStyleLeft ) {
//        [path lineToPoint:NSMakePoint(x0, minY)];
//        [path lineToPoint:NSMakePoint(x0, maxY)];
//        [path lineToPoint:NSMakePoint(x1, maxY)];
//    }
//    else {
        // Degrees?! O_o
        [path appendBezierPathWithArcWithCenter:NSMakePoint(x1, midY) radius:radius startAngle:-90 endAngle:90 clockwise:YES];
//    }
    
    // Top edge
//    [path lineToPoint:NSMakePoint(x2, maxY)];
    
//    // Right edge
//    if ( jointStyle & OEXTokenJoinStyleRight ) {
//        [path lineToPoint:NSMakePoint(x3, maxY)];
//        [path lineToPoint:NSMakePoint(x3, minY)];
//        [path lineToPoint:NSMakePoint(x2, minY)];
//    }
//    else {
        [path appendBezierPathWithArcWithCenter:NSMakePoint(x2, midY) radius:radius startAngle:90 endAngle:-90 clockwise:YES];
//    }
    
    // Bottom edge
    [path lineToPoint:NSMakePoint(x1, minY)];
    [path closePath];
    
    // As we'll clip to the path, let's double the desired line width (1)
    [path setLineWidth:2];
    
    return path;
}

@end
