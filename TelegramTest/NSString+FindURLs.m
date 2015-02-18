//
//  NSString+FindURLs.m
//  timezone
//
//  Created by Randall Brown on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+FindURLs.h"
#import "FileUtils.h"

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
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    
    
    
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
            
            if(range.location >= nameRange.location && (range.location+range.length) > (nameRange.location + nameRange.length)) {
                [toremove addObject:userObj];
            }
            
        }];
        
        
        
        [userNames removeObjectsInArray:toremove];
        
        
    }];
    
    
    
    //Load the list on the regex
    NSArray *schemesToFind = urlSchemes();
    NSString *schemeRegexString = @"";
    for (NSString *scheme in schemesToFind) {
        //explaining the regex: for example, if "spotify:" (open spotify) and "x-apple.systempreferences:" (open system preference) is on the array, the final regex will be /(spotify:\S*)| (x-apple.systempreferences:\S*)" witch says: "find the letters 'spotify:', in this order, followed by or not by any charachter until any whitespace is found OR find the letters 'x-apple.systempreferences:', in this order, followed by or not by any charachter until any whitespace is found"
        schemeRegexString = [schemeRegexString stringByAppendingString:[NSString stringWithFormat:@"(%@\\S*)|", scheme]];
    }
    //remove last character of string "|"
    schemeRegexString = [schemeRegexString substringToIndex:schemeRegexString.length-(schemeRegexString.length>0)];

    //detect occurence of array into string
    NSRegularExpression *schemeRegex = [NSRegularExpression regularExpressionWithPattern:schemeRegexString options:0 error:&error];
    
    
    //check the contents of messages against the schemes (Regex or other?)
    NSArray* schemeResult = [schemeRegex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    //return the range of URL scheme to program
    NSArray* newResult = [results arrayByAddingObjectsFromArray:schemeResult];
    
    return [newResult arrayByAddingObjectsFromArray:userNames];;
}



/*
 //the following code has been commented because there's no programatic way of determining all the URL schemes presented on a system, thus forcing the creation of the .txt for handling known URL schemes
-(NSArray *) listOfURIsOnTheSystem {
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    
    // Run the following command to have a list of schemes available
    //System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump | egrep "(bindings.*\:$)"|sort
    task.launchPath = @"/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister";
    task.arguments = @[@"-dump",@"|egrep", @"\"(bindings.*\\:$)\"|sort"];
    task.standardOutput = pipe;
    
    //Run
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString * output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
 
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(bindings.*\\:$)" options:0 error:&error];
    
    if (error) {
        NSAlert *alert = [[NSAlert alloc] init] ;
        [alert setMessageText:error.localizedDescription];
        [alert runModal];
        return @[];
    }
    
    return @[];
    
}
*/
@end
