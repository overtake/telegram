//
//  NSTextView+AutomaticLinkDetection.m
//  AutoLink
//
//  Created by Randall Brown on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSTextView+AutomaticLinkDetection.h"
#import "NSString+FindURLs.h"
#import "NSAttributedString+Hyperlink.h"
@implementation NSTextView (NSTextView_AutomaticLinkDetection)

-(void)detectAndAddLinks:(URLFindType)urlType
{
    NSArray *linkLocations = [[self string] locationsOfLinks:urlType];
    NSArray *links = [[self string] arrayOfLinks:linkLocations];
    
    NSRange selectRange = self.selectedRange;
    
    int i=0;
    for( NSString *link in links )
    {
       NSAttributedString *linkString = [NSMutableAttributedString hyperlinkFromString:link withURL:[NSURL URLWithString:link]];
        
       [[self textStorage] replaceCharactersInRange:[[linkLocations objectAtIndex:i] range] withAttributedString:linkString];
        
        
       i++;
    }
    
    self.selectedRange = selectRange;
   
}

@end
