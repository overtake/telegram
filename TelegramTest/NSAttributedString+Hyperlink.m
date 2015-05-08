#import "NSAttributedString+Hyperlink.h"
#import "NSString+FindURLs.h"


@implementation NSMutableAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    
	NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
	NSRange range = NSMakeRange(0, [attrString length]);
	
    
    [attrString addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
    
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
                  //  NSURL *url = [NSURL URLWithString:link];
                  //  if(url) {
                        [self addAttribute:NSLinkAttributeName value:link range:range];
                        [self addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
                        [self addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
                        [self addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleNone] range:range];
                        
                  //  }
                }
            }
        }
        i++;
    }
    [self endEditing];
    
}

-(void)detectExternalLinks {
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:1ULL << 5 error:nil];
    
    
    NSArray *linkLocations = [detect matchesInString:[self string] options:0 range:NSMakeRange(0, [self length])];
    
    NSArray *links = [[self string] arrayOfLinks:linkLocations];
    
    [self beginEditing];
    int i = 0;
    for( NSString *link in links ) {
        if(link) {
            id object = [linkLocations objectAtIndex:i];
            if(object) {
                NSRange range = [object range];
                
                if(range.location != NSNotFound) {
                    //  NSURL *url = [NSURL URLWithString:link];
                    //  if(url) {
                    [self addAttribute:NSLinkAttributeName value:link range:range];
                    [self addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
                    [self addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
                    [self addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleNone] range:range];
                    
                    //  }
                }
            }
        }
        i++;
    }
    [self endEditing];
}


@end