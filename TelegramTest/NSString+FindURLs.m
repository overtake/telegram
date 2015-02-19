//
//  NSString+FindURLs.m
//  timezone
//
//  Created by Randall Brown on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
    //detect range of links
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:1ULL << 5 error:nil];
    
    
    NSArray *results = [detect matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    NSError *error = nil;
    
    //detect range of @ (usernames)
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?<!\\w)@[\\w]{5,100}+)" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSMutableArray* userNames = [[regex matchesInString:self options:0 range:NSMakeRange(0, [self length])] mutableCopy];
    
    
    
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSRange range = [obj range];
        
        NSMutableArray *toremove = [[NSMutableArray alloc] init];
        
        [userNames enumerateObjectsUsingBlock:^(id userObj, NSUInteger idx, BOOL *stop) {
            
            NSRange nameRange = [userObj range];
            
            if(range.location <= nameRange.location && (range.location+range.length) > (nameRange.location + nameRange.length)) {
                [toremove addObject:userObj];
            }
            
        }];
        
        [userNames removeObjectsInArray:toremove];
        
        
    }];
    
    //detect range of URL Schemes
    
    // Run the following command to have a list of schemes available
    //System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump | egrep "(bindings.*\:$)"|sort
    
    
    //Load the list on the first run to memory
    
    
    //check the contents of messages against the schemes (Regex or other?)
    
    //return the range of URL scheme to program
    
   return [results arrayByAddingObjectsFromArray:userNames];
}

@end
