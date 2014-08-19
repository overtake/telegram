//
//  NSFont+RBLFallbackAdditions.h
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-12-09.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSFont (RBLFallbackAdditions)

// Looks up a font with the given name and size.
//
// If text rendered in the returned font uses a glyph not present in
// `fontName`, the fonts specified by `fallbackNames` are searched in order, and
// the glyph is rendered in the first font that provides it.
//
// If `fontName` does not exist on the system, `fallbackNames` is searched in
// order for a replacement font.
//
// Returns a font that renders in `fontName` by default, and `fallbackNames`
// only if necessary, or `nil` if no fonts by the given names could be found.
+ (NSFont *)rbl_fontWithName:(NSString *)fontName size:(CGFloat)fontSize fallbackNames:(NSArray *)fallbackNames;

@end
