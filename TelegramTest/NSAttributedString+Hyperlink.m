#import "NSAttributedString+Hyperlink.h"
#import "NSString+FindURLs.h"

@implementation NSMutableAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    
	NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
	NSRange range = NSMakeRange(0, [attrString length]);
	[attrString beginEditing];
    
    if([aURL absoluteString])
        [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
 	
    [attrString addAttribute:NSFontAttributeName value:[NSFont fontWithName:FONT_NAME size:FONT_SIZE] range:range];
    [attrString addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
	[attrString endEditing];
 	
	return attrString;
}

-(void)detectAndAddLinks {
    
    NSArray *linkLocations = [[self string] locationsOfLinks];
    NSArray *links = [[self string] arrayOfLinks:linkLocations];
    
    [self beginEditing];
    int i = 0;
    for( NSString *link in links ) {
        if(link) {
            id object = [linkLocations objectAtIndex:i];
            if(object) {
                NSRange range = [object range];
                
                if(range.location != NSNotFound) {
                    NSURL *url = [NSURL URLWithString:link];
                    if(url) {
                        [self addAttribute:NSLinkAttributeName value:[url absoluteString] range:range];
                        [self addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
                        [self addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
                        [self addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleNone] range:range];
                        
                    }
                }
            }
        }
        i++;
    }
    [self endEditing];
    
}
@end