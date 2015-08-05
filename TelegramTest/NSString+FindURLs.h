//
//  NSString+FindURLs.h
//
//

#import <Foundation/Foundation.h>

typedef enum {
    URLFindTypeAll = 30,
    URLFindTypeLinks = 2,
    URLFindTypeMentions = 4,
    URLFindTypeHashtags = 8,
    URLFindTypeBotCommands = 16
} URLFindType;

@interface NSString (NSString_FindURLs)


- (NSArray *)arrayOfLinks:(NSArray *)results;
- (NSArray *)locationsOfLinks:(URLFindType)findType;
- (NSArray *)locationsOfHashtags;
- (NSArray *)locationsOfLinks;
- (NSString *)webpageLink;
- (BOOL)isStringWithUrl;
+ (NSArray *)textCheckingResultsForText:(NSString *)text highlightMentionsAndTags:(bool)highlightMentionsAndTags highlightCommands:(bool)highlightCommands;


@end
