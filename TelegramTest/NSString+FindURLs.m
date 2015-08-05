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

-(NSArray *)locationsOfLinks {
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:1ULL << 5 error:nil];
    return [detect matchesInString:self options:0 range:NSMakeRange(0, [self length])];
}

- (NSArray *)locationsOfLinks:(URLFindType)findType
{
   
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:1ULL << 5 error:nil];
    
    
    NSMutableArray *userNames = [[NSMutableArray alloc] init];
    NSMutableArray *hashTags = [[NSMutableArray alloc] init];
    NSMutableArray *botCommands = [[NSMutableArray alloc] init];
    NSArray *links = @[];
    
    
    if((findType & URLFindTypeLinks) == URLFindTypeLinks)
        links = [detect matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?<!\\w)@[A-Za-z][A-Za-z0-9_]{4,100}+)" options:NSRegularExpressionCaseInsensitive error:&error];
    if((findType & URLFindTypeMentions) == URLFindTypeMentions)
        userNames = [[regex matchesInString:self options:0 range:NSMakeRange(0, [self length])] mutableCopy];
    
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"(#[\\w]{1,150}+)" options:NSRegularExpressionCaseInsensitive error:&error];
    if((findType & URLFindTypeHashtags) == URLFindTypeHashtags)
        hashTags = [[regex matchesInString:self options:0 range:NSMakeRange(0, [self length])] mutableCopy];
    
    
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"((?<!\\S)/[\\w|\\w@\\w]{1,150}+)" options:NSRegularExpressionCaseInsensitive error:&error];
    if((findType & URLFindTypeBotCommands) == URLFindTypeBotCommands)
        botCommands = [[regex matchesInString:self options:0 range:NSMakeRange(0, [self length])] mutableCopy];
    
    
    [links enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSRange range = [obj range];
        
        NSMutableArray *toremoveUsers = [[NSMutableArray alloc] init];
        NSMutableArray *toremoveTags = [[NSMutableArray alloc] init];
        NSMutableArray *toremoveCommands = [[NSMutableArray alloc] init];
        
        [userNames enumerateObjectsUsingBlock:^(id userObj, NSUInteger idx, BOOL *stop) {
            
            NSRange nameRange = [userObj range];
            
            if(range.location <= nameRange.location && (range.location+range.length) >= (nameRange.location + nameRange.length)) {
                [toremoveUsers addObject:userObj];
            }
            
        }];
        
        
        [hashTags enumerateObjectsUsingBlock:^(id hashObj, NSUInteger idx, BOOL *stop) {
            
            NSRange hashRange = [hashObj range];
            
            if(range.location <= hashRange.location && (range.location+range.length) >= (hashRange.location + hashRange.length)) {
                [toremoveTags addObject:hashObj];
            }
            
        }];
        
        [botCommands enumerateObjectsUsingBlock:^(id commandObject, NSUInteger idx, BOOL *stop) {
            
            NSRange commandRange = [commandObject range];
            
            if(range.location <= commandRange.location && (range.location+range.length) >= (commandRange.location + commandRange.length)) {
                [toremoveCommands addObject:commandObject];
            }
            
        }];
        
        
        [hashTags removeObjectsInArray:toremoveTags];
        [userNames removeObjectsInArray:toremoveUsers];
        [botCommands removeObjectsInArray:toremoveCommands];
        
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
    NSArray* newResult = [links arrayByAddingObjectsFromArray:schemeResult];
    
    return [[[newResult arrayByAddingObjectsFromArray:userNames] arrayByAddingObjectsFromArray:hashTags] arrayByAddingObjectsFromArray:botCommands];
    
    //return [results arrayByAddingObjectsFromArray:userNames];
}



+ (NSArray *)textCheckingResultsForText:(NSString *)text highlightMentionsAndTags:(bool)highlightMentionsAndTags highlightCommands:(bool)highlightCommands
{
    bool containsSomething = false;
    
    int length = (int)text.length;
    
    int digitsInRow = 0;
    int schemeSequence = 0;
    int dotSequence = 0;
    
    unichar lastChar = 0;
    
    SEL sel = @selector(characterAtIndex:);
    unichar (*characterAtIndexImp)(id, SEL, NSUInteger) = (typeof(characterAtIndexImp))[text methodForSelector:sel];
    
    for (int i = 0; i < length; i++)
    {
        unichar c = characterAtIndexImp(text, sel, i);
        
        if (highlightMentionsAndTags && (c == '@' || c == '#'))
        {
            containsSomething = true;
            break;
        }
        
        if (c >= '0' && c <= '9')
        {
            digitsInRow++;
            if (digitsInRow >= 6)
            {
                containsSomething = true;
                break;
            }
            
            schemeSequence = 0;
            dotSequence = 0;
        }
        else if (!(c != ' ' && digitsInRow > 0))
            digitsInRow = 0;
        
        if (c == ':')
        {
            if (schemeSequence == 0)
                schemeSequence = 1;
            else
                schemeSequence = 0;
        }
        else if (c == '/')
        {
            if (highlightCommands)
            {
                containsSomething = true;
                break;
            }
            
            if (schemeSequence == 2)
            {
                containsSomething = true;
                break;
            }
            
            if (schemeSequence == 1)
                schemeSequence++;
            else
                schemeSequence = 0;
        }
        else if (c == '.')
        {
            if (dotSequence == 0 && lastChar != ' ')
                dotSequence++;
            else
                dotSequence = 0;
        }
        else if (c != ' ' && lastChar == '.' && dotSequence == 1)
        {
            containsSomething = true;
            break;
        }
        else
        {
            dotSequence = 0;
        }
        
        lastChar = c;
    }
    
    if (containsSomething)
    {
        NSError *error = nil;
        static NSDataDetector *dataDetector = nil;
        if (dataDetector == nil)
            dataDetector = [NSDataDetector dataDetectorWithTypes:(int)(NSTextCheckingTypeLink) error:&error];
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        [dataDetector enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *match, __unused NSMatchingFlags flags, __unused BOOL *stop)
         {
             NSTextCheckingType type = [match resultType];
             if (type == NSTextCheckingTypeLink || type == NSTextCheckingTypePhoneNumber)
             {
                 [results addObject:[NSValue valueWithRange:match.range]];
             }
         }];
        
        static NSCharacterSet *characterSet = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          characterSet = [NSCharacterSet alphanumericCharacterSet];
                      });
        
        if (containsSomething && (highlightMentionsAndTags || highlightCommands))
        {
            int mentionStart = -1;
            int hashtagStart = -1;
            int commandStart = -1;
            
            unichar previous = 0;
            for (int i = 0; i < length; i++)
            {
                unichar c = characterAtIndexImp(text, sel, i);
                if (highlightMentionsAndTags && commandStart == -1)
                {
                    if (mentionStart != -1)
                    {
                        if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'))
                        {
                            if (i > mentionStart + 1)
                            {
                                NSRange range = NSMakeRange(mentionStart + 1, i - mentionStart - 1);
                                NSRange mentionRange = NSMakeRange(range.location - 1, range.length + 1);
                                
                                unichar mentionStartChar = [text characterAtIndex:mentionRange.location + 1];
                                if (!(mentionRange.length <= 5 || (mentionStartChar >= '0' && mentionStartChar <= '9')))
                                {
                                    [results addObject:[NSValue valueWithRange:mentionRange]];
                                }
                            }
                            mentionStart = -1;
                        }
                    }
                    else if (hashtagStart != -1)
                    {
                        if (c == ' ' || (![characterSet characterIsMember:c] && c != '_'))
                        {
                            if (i > hashtagStart + 1)
                            {
                                NSRange range = NSMakeRange(hashtagStart + 1, i - hashtagStart - 1);
                                NSRange hashtagRange = NSMakeRange(range.location - 1, range.length + 1);
                                
                                [results addObject:[NSValue valueWithRange:hashtagRange]];
                            }
                            hashtagStart = -1;
                        }
                    }
                    
                    if (c == '@')
                    {
                        mentionStart = i;
                    }
                    else if (c == '#')
                    {
                        hashtagStart = i;
                    }
                }
                
                if (highlightCommands && mentionStart == -1 && hashtagStart == -1)
                {
                    if (commandStart != -1 && ![characterSet characterIsMember:c] && c != '@' && c != '_')
                    {
                        if (i - commandStart > 1)
                        {
                            NSRange range = NSMakeRange(commandStart, i - commandStart);
                            [results addObject:[NSValue valueWithRange:range]];
                        }
                        
                        commandStart = -1;
                    }
                    else if (c == '/' && (previous == 0 || previous == ' ' || previous == '\n' || previous == '\t'))
                    {
                        commandStart = i;
                    }
                }
                previous = c;
            }
            
            if (mentionStart != -1 && mentionStart + 1 < length - 1)
            {
                NSRange range = NSMakeRange(mentionStart + 1, length - mentionStart - 1);
                NSRange mentionRange = NSMakeRange(range.location - 1, range.length + 1);
                unichar mentionStartChar = [text characterAtIndex:mentionRange.location + 1];
                if (!(mentionRange.length <= 5 || (mentionStartChar >= '0' && mentionStartChar <= '9')))
                {
                    [results addObject:[NSValue valueWithRange:mentionRange]];
                }
            }
            
            if (hashtagStart != -1 && hashtagStart + 1 < length - 1)
            {
                NSRange range = NSMakeRange(hashtagStart + 1, length - hashtagStart - 1);
                NSRange hashtagRange = NSMakeRange(range.location - 1, range.length + 1);
                [results addObject:[NSValue valueWithRange:hashtagRange]];
            }
            
            if (commandStart != -1 && commandStart + 1 < length)
            {
                NSRange range = NSMakeRange(commandStart, length - commandStart);
                [results addObject:[NSValue valueWithRange:range]];
            }
        }
        
        return results;
    }
    
    return nil;
}

- (NSArray *) locationsOfHashtags {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(#[\\w]{1,150}+)" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSMutableArray* hashTags = [[regex matchesInString:self options:0 range:NSMakeRange(0, [self length])] mutableCopy];
    
    return hashTags;
}

-(NSString *)webpageLink
{
    
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:1ULL << 5 error:nil];
    
    NSArray *arrayOfLinks = [self arrayOfLinks:[detect matchesInString:self options:0 range:NSMakeRange(0, [self length])]];
    
    return arrayOfLinks.count > 0 ? arrayOfLinks[0] : nil;
    
}


- (BOOL)isStringWithUrl
{
    
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:1ULL << 5 error:nil];
    
    return  [detect matchesInString:self options:0 range:NSMakeRange(0, [self length])].count > 0;
    
}

@end
