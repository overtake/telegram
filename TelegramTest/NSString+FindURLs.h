//
//  NSString+FindURLs.h
//
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_FindURLs)


- (NSArray *) arrayOfLinks:(NSArray *)results;
- (NSArray *) locationsOfLinks;
- (NSArray *) locationsOfHashtags;
@end
