//
//  RpcErrorParser.m
//  TelegramTest
//
//  Created by keepcoder on 15.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "RpcErrorParser.h"

@implementation RpcErrorParser


+(RpcError *)parseRpcError:(MTRpcError *)error {
    
    NSString *searchedString = [error errorDescription];
    
    
    RpcError *rpcError = [[RpcError alloc] init];
    rpcError.error_code = [error errorCode];
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^([A-Z_0-9]+)(: (.+))?" options:0 error:nil];
    NSArray* matches = [regex matchesInString:searchedString options:0 range:NSMakeRange(0, [searchedString length])];
    
    rpcError.error_msg = [searchedString substringWithRange:[[matches objectAtIndex:0] rangeAtIndex:1]];
    
    
    NSString *numberString;
    
    NSScanner *scanner = [NSScanner scannerWithString:rpcError.error_msg];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    // Throw away characters before the first number.
    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    
    // Collect numbers.
    [scanner scanCharactersFromSet:numbers intoString:&numberString];
    
    rpcError.resultId = [numberString intValue];
    
    return rpcError;
}
@end
