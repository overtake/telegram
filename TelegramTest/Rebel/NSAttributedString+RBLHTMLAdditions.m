//
//  NSAttributedString+RBLHTMLAdditions.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-12-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSAttributedString+RBLHTMLAdditions.h"

@implementation NSAttributedString (RBLHTMLAdditions)

+ (instancetype)rbl_attributedStringWithHTML:(NSString *)HTMLString {
	NSParameterAssert(HTMLString != nil);

	NSStringEncoding encoding = HTMLString.fastestEncoding;

	NSData *data = [HTMLString dataUsingEncoding:encoding];
	if (data == nil) return nil;

	NSDictionary *options = @{ NSCharacterEncodingDocumentAttribute: @(encoding) };
	return [[self alloc] initWithHTML:data options:options documentAttributes:NULL];
}

@end
