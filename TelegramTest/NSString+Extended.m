//
//  NSString+Extended.m
//  Telegram
//
//  Created by Dmitry Kondratyev on 11/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "NSString+Extended.h"



@implementation NSString (Extended)

- (NSString *) singleLine {
    return [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (NSString *)URLDecode {
    return [[self
             stringByReplacingOccurrencesOfString:@"+" withString:@" "]
            stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *) trim {
    
    NSString *string = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSRange range = NSMakeRange(0, 1);
    while(range.length != 0) {
        range = [string rangeOfString:@"  "];
        string = [string stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    string = [string stringByReplacingOccurrencesOfString:@" -- " withString:@" — "];
    string = [string stringByReplacingOccurrencesOfString:@"<<" withString:@"«"];
    string = [string stringByReplacingOccurrencesOfString:@">>" withString:@"»"];
    
    return string;
}

- (NSArray *)getEmojiFromString {
    
    __block NSMutableDictionary *temp = [NSMutableDictionary dictionary];

    
    [self enumerateSubstringsInRange: NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         
         const unichar hs = [substring characterAtIndex: 0];
         
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             const unichar ls = [substring characterAtIndex: 1];
             const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
             
             if((0x1d000 <= uc && uc <= 0x1f77f)) {
                 [temp setObject:substring forKey:@(uc)];
             }
             
             
             // non surrogate
         } else {
             if((0x2100 <= hs && hs <= 0x26ff)) {
                 [temp setObject:substring forKey:@(hs)];
             }

         }
     }];
    
    return [temp allValues];
}

static NSTextField *testTextField() {
    static NSTextField *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSTextField alloc] init];
        [instance setBordered:NO];
        [instance setEditable:NO];
        [instance setBezeled:NO];
        [instance setSelectable:NO];
    });
    return instance;
}

- (NSSize) sizeForTextFieldForWidth:(int)width {
    NSTextField *textField = testTextField();
    [textField setStringValue:self];
    NSSize size = [[textField cell] cellSizeForBounds:NSMakeRect(0, 0, width, FLT_MAX)];
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
}

- (NSString*)htmlentities {
    // take this string obj and wrap it in a root element to ensure only a single root element exists
//    NSString* string = [NSString stringWithFormat:@"<root>%@</root>", self];
//    
//    // add the string to the xml parser
//    NSStringEncoding encoding = string.fastestEncoding;
//    NSData* data = [string dataUsingEncoding:encoding];
//    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
//    
//    // parse the content keeping track of any chars found outside tags (this will be the stripped content)
//    NSString_stripHtml_XMLParsee* parsee = [[NSString_stripHtml_XMLParsee alloc] init];
//    parser.delegate = parsee;
//    [parser parse];
//    
//    // log any errors encountered while parsing
//    //NSError * error = nil;
//    //if((error = [parser parserError])) {
//    //    DLog(@"This is a warning only. There was an error parsing the string to strip HTML. This error may be because the string did not contain valid XML, however the result will likely have been decoded correctly anyway.: %@", error);
//    //}
//    
//    // any chars found while parsing are the stripped content
//    NSString* strippedString = [parsee getCharsFound];
    
    NSString *strippedString = [self stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    
    strippedString = [strippedString stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    
    // get the raw text out of the parsee after parsing, and return it
    return strippedString;
}
@end

