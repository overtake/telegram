//
//  RBLShadowedTextFieldCell.h
//  Rebel
//
//  Created by Danny Greg on 18/02/2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Use this value to set a shadow to be used as a fallback for all background
// styles.
//
// If a shadow is explicitly set for a particular background style, it will be
// preferred to any shadows set to affect all background styles.
extern NSBackgroundStyle const RBLShadowedTextFieldAllBackgroundStyles;

// A text field cell subclass that allows easy drawing of shadows on text. A
// different shadow can be set for each background style of the cell.
//
// An example use case here is labels within table views.
@interface RBLShadowedTextFieldCell : NSTextFieldCell

// Sets a shadow to be drawn whenever the cell has the provided background style
//
// shadow          - The shadow to use for the given `backgroundStyle`. If nil
//                   it removes any previously set shadow.
// backgroundStyle - The background style for which the given shadow should be
//                   drawn, or `RBLShadowedTextFieldAllBackgroundStyles` if the
//                   shadow should be used as a fallback for all background
//                   styles.
- (void)setShadow:(NSShadow *)shadow forBackgroundStyle:(NSBackgroundStyle)backgroundStyle;

@end
