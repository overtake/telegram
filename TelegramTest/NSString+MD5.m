//
//  NSString+MD5.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/24/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "NSString+MD5.h"

@implementation NSString (MD5)


-(NSString*)md5sum
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/sbin/md5"];
    [task setArguments:@[self]];
    
    NSPipe *outPipe = [[NSPipe alloc] init];
    [task setStandardOutput:outPipe];
    
    [task launch];
    NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    
    if ([task terminationStatus] != 0) {
        NSLog(@"NSString + MD5 : error");
        return nil;
    }
    
    NSString *str = [[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
    
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    return str;
}


@end
