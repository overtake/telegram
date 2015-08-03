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

-(void)detectAndAddLinks:(URLFindType)urlType {
    
    NSArray *linkLocations = [NSString textCheckingResultsForText:self.string highlightMentionsAndTags:urlType & URLFindTypeMentions highlightCommands:urlType & URLFindTypeBotCommands];// [[self string] locationsOfLinks:urlType];
    
    [self beginEditing];
    for( NSValue *link in linkLocations ) {
        NSRange range = [link rangeValue];
        
        if(range.location != NSNotFound) {
            //  NSURL *url = [NSURL URLWithString:link];
            //  if(url) {
            [self addAttribute:NSLinkAttributeName value:[self.string substringWithRange:range] range:range];
            [self addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
            [self addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
            [self addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleNone] range:range];
            
            //  }
        }
    }
    [self endEditing];
    
}



@end