#import "NSAttributedString+Hyperlink.h"



@implementation NSMutableAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    
	NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
	NSRange range = NSMakeRange(0, [attrString length]);
	
    
    [attrString addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
    
	[attrString endEditing];
 	
	return attrString;
}

-(NSArray *)detectAndAddLinks:(URLFindType)urlType {
    
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    
    NSArray *linkLocations = [NSString textCheckingResultsForText:self.string highlightMentionsAndTags:urlType & URLFindTypeMentions highlightCommands:urlType & URLFindTypeBotCommands];// [[self string] locationsOfLinks:urlType];
    
    [self beginEditing];
    for( NSValue *link in linkLocations ) {
        NSRange range = [link rangeValue];
        
        if(range.location != NSNotFound) {
            
            NSString *sublink = [self.string substringWithRange:range];
            
            [self addAttribute:NSLinkAttributeName value:sublink range:range];
            [self addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
            [self addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
            [self addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleNone] range:range];
            
            
            if(![sublink hasPrefix:@"@"] && ![sublink hasPrefix:@"#"] && ![sublink hasPrefix:@"/"]) {
                [urls addObject:sublink];
            }
        }
    }
    [self endEditing];
    
    return urls;
    
}



@end