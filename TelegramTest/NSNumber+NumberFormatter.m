//
//  NSNumber+NumberFormatter.m
//  Telegram P-Edition
//
//  Created by keepcoder on 25.12.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "NSNumber+NumberFormatter.h"

@implementation NSNumber (NumberFormatter)


-(NSString*)prettyFormatter:(unsigned long)n iteration:(int)iteration {
    NSArray *keys = @[@"K",@"M",@"B",@"T"];
    
    unsigned long d = (n / 100) / 10.0;
    BOOL isRound = (d * 10) %10 == 0;
    if(d < 1000) {
        return [NSString stringWithFormat:@"%lu%@",(d > 99.9 || isRound || (!isRound && d > 9.99)) ? d * 10 / 10 : d,[keys objectAtIndex:iteration]];
    } else return [self prettyFormatter:d iteration:iteration+1];
}


-(NSString *)prettyNumber {
    
    if([self unsignedLongValue] < 1000)
        return [NSString stringWithFormat:@"%@",self];
    
    return [self prettyFormatter:[self unsignedLongValue] iteration:0];
}
@end
