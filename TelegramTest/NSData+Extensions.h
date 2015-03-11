//
//  NSData+Extensions.h
//  TelegramTest
//
//  Created by keepcoder on 05.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Extensions)
- (NSString *)hexadecimalString;
-(NSData *)gzipInflate;
- (NSData *)gzipDeflate;
-(NSData *)dataWithData:(NSData *)data;

-(id)initWithEmptyBytes:(int)bytes;

@end
