//
//  TelegramTokenCell.h
//  Telegram
//
//  Created by Dmitry Kondratyev on 11/16/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    OEXTokenDrawingModeDefault,
    OEXTokenDrawingModeHighlighted,
    OEXTokenDrawingModeSelected
} OEXTokenDrawingMode;

typedef enum {
    OEXTokenJoinStyleNone,
    OEXTokenJoinStyleLeft,
    OEXTokenJoinStyleBoth,
    OEXTokenJoinStyleRight
} OEXTokenJoinStyle;


@interface TMTokenCell : NSTextAttachmentCell
- (NSSize)cellSizeForTitleSize:(NSSize)titleSize;
- (NSRect)titleRectForBounds:(NSRect)bounds;

- (void)drawTokenWithFrame:(NSRect)rect inView:(NSView *)controlView;
- (void)drawTitleWithFrame:(NSRect)rect inView:(NSView *)controlView;

- (OEXTokenDrawingMode)tokenDrawingMode;
- (OEXTokenJoinStyle)tokenJoinStyle;

- (NSColor *)tokenFillColorForDrawingMode:(OEXTokenDrawingMode)drawingMode;
- (NSColor *)tokenStrokeColorForDrawingMode:(OEXTokenDrawingMode)drawingMode;
- (NSColor *)tokenTitleColorForDrawingMode:(OEXTokenDrawingMode)drawingMode;

- (NSBezierPath *)tokenPathForBounds:(NSRect)bounds joinStyle:(OEXTokenJoinStyle)joinStyle;
@end
