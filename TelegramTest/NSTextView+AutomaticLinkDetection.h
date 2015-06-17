//
//  NSTextView+AutomaticLinkDetection.h
//  AutoLink
//
//  Created by Randall Brown on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "NSString+FindURLs.h"
@interface NSTextView (NSTextView_AutomaticLinkDetection)

-(void)detectAndAddLinks:(URLFindType)urlType;

@end
