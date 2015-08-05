#import <Cocoa/Cocoa.h>
#import "NSString+FindURLs.h"
@interface NSMutableAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
-(NSArray *)detectAndAddLinks:(URLFindType)urlType;
@end