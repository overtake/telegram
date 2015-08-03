#import <Cocoa/Cocoa.h>
#import "NSString+FindURLs.h"
@interface NSMutableAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
-(void)detectAndAddLinks:(URLFindType)urlType;
@end