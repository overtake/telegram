//
//  NSFont+RBLFallbackAdditions.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-12-09.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSFont+RBLFallbackAdditions.h"

@implementation NSFont (RBLFallbackAdditions)

+ (NSFont *)rbl_fontWithName:(NSString *)fontName size:(CGFloat)fontSize fallbackNames:(NSArray *)fallbackNames {
	NSParameterAssert(fontName != nil);

	NSSet *mandatoryKeys = [NSSet setWithObjects:NSFontNameAttribute, NSFontSizeAttribute, nil];
	NSMutableArray *fallbackDescriptors = [NSMutableArray arrayWithCapacity:fallbackNames.count];

	for (NSString *fallbackName in fallbackNames) {
		// Our ideal fallback font.
		NSFontDescriptor *searchDescriptor = [NSFontDescriptor fontDescriptorWithName:fallbackName size:fontSize];

		// Now check to see whether a match actually exists, falling back to
		// a different size if necessary.
		NSFontDescriptor *matchingDescriptor = [searchDescriptor matchingFontDescriptorWithMandatoryKeys:mandatoryKeys];
		if (matchingDescriptor == nil) continue;

		[fallbackDescriptors addObject:matchingDescriptor];
	}

	NSMutableArray *remainingFontNames = [fallbackNames mutableCopy];
	NSAssert(fallbackDescriptors.count <= remainingFontNames.count, @"Should have no more fallback font descriptors (%lu) than names to try (%lu)", (unsigned long)fallbackDescriptors.count, (unsigned long)remainingFontNames.count);

	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	if (fallbackDescriptors.count > 0) attributes[NSFontCascadeListAttribute] = fallbackDescriptors;

	while (YES) {
		attributes[NSFontNameAttribute] = fontName;

		NSFont *font = [NSFont fontWithDescriptor:[NSFontDescriptor fontDescriptorWithFontAttributes:attributes] size:fontSize];
		if (font != nil) return font;

		if (remainingFontNames.count == 0) break;

		if (fallbackDescriptors.count > 0) {
			NSString *topName = [fallbackDescriptors[0] fontAttributes][NSFontAttributeName];
			if ([topName isEqual:fontName]) [fallbackDescriptors removeObjectAtIndex:0];
		}

		// Try the next font in the list.
		fontName = remainingFontNames[0];
		[remainingFontNames removeObjectAtIndex:0];
	}

	return nil;
}

@end
