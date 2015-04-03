#import <Cocoa/Cocoa.h>

@interface NSMutableAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
-(void)detectAndAddLinks;
-(void)detectExternalLinks;
@end