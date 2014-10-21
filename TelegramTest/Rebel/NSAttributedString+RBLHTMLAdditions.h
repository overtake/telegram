//
//  NSAttributedString+RBLHTMLAdditions.h
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-12-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSAttributedString (RBLHTMLAdditions)

// Returns an attributed string initialized from HTML.
+ (instancetype)rbl_attributedStringWithHTML:(NSString *)HTMLString;

@end
