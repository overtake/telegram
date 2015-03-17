//
//  NSString+FindURLs.m
//

//

#import "NSString+FindURLs.h"

@implementation NSString (NSString_FindURLs)

//NSString *urlRegEx = @"^(http|https|ftp)\://(([a-zA-Z0-9-.]+\.[a-zA-Z]{2,3})|([0-2]*\d*\d\.[0-2]*\d*\d\.[0-2]*\d*\d\.[0-2]*\d*\d))(:[a-zA-Z0-9]*)?/?([a-zA-Z0-9-._\?\,\'/\+&%\$#\=~])*[^.\,)(\s]$";


- (NSArray *)arrayOfLinks:(NSArray *)results
{
    
    NSMutableArray *links = [NSMutableArray array];
    
    for( id result in results )
    {
        [links addObject:[self substringWithRange:[result range]]];
    }
    
    
    return links;  
}

- (NSArray *)locationsOfLinks
{
   
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:1ULL << 5 error:nil];
    
    
    NSArray *results = [detect matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?<!\\w)@[\\w]{2,100}+)" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSMutableArray* userNames = [[regex matchesInString:self options:0 range:NSMakeRange(0, [self length])] mutableCopy];
    
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"((?<!\\w)#[\\w]{1,150}+)" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSMutableArray* hashTags = [[regex matchesInString:self options:0 range:NSMakeRange(0, [self length])] mutableCopy];
    
    
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSRange range = [obj range];
        
        NSMutableArray *toremoveUsers = [[NSMutableArray alloc] init];
        NSMutableArray *toremoveTags = [[NSMutableArray alloc] init];
        
        [userNames enumerateObjectsUsingBlock:^(id userObj, NSUInteger idx, BOOL *stop) {
            
            NSRange nameRange = [userObj range];
            
            if(range.location <= nameRange.location && (range.location+range.length) > (nameRange.location + nameRange.length)) {
                [toremoveUsers addObject:userObj];
            }
            
        }];
        
        
        [hashTags enumerateObjectsUsingBlock:^(id hashObj, NSUInteger idx, BOOL *stop) {
            
            NSRange hashRange = [hashObj range];
            
            if(range.location <= hashRange.location && (range.location+range.length) > (hashRange.location + hashRange.length)) {
                [toremoveTags addObject:hashObj];
            }
            
        }];
        
        [hashTags removeObjectsInArray:toremoveTags];
        [userNames removeObjectsInArray:toremoveUsers];
        
    }];
    
    
    //Load the list on the regex
    NSArray *schemesToFind = @[@"spotify:", @"x-apple.systempreferences://"]; //dumb version
    NSString *schemeRegexString = @"";
    for (NSString *scheme in schemesToFind) {
        schemeRegexString = [schemeRegexString stringByAppendingString:[NSString stringWithFormat:@"(%@.+)|", scheme]];
    }
    //remove last character of string |
    schemeRegexString = [schemeRegexString substringToIndex:schemeRegexString.length-(schemeRegexString.length>0)];
    
    //detect occurence of array into string
    NSRegularExpression *schemeRegex = [NSRegularExpression regularExpressionWithPattern:schemeRegexString options:0 error:&error];
    
    
    //check the contents of messages against the schemes (Regex or other?)
    NSArray* schemeResult = [schemeRegex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    //return the range of URL scheme to program
    NSArray* newResult = [results arrayByAddingObjectsFromArray:schemeResult];
    
    return [[newResult arrayByAddingObjectsFromArray:userNames] arrayByAddingObjectsFromArray:hashTags];
    
    //return [results arrayByAddingObjectsFromArray:userNames];
}

@end
