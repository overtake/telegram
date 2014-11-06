//
//  TGFileLocation+Extensions.h
//  TelegramTest
//
//  Created by keepcoder on 28.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLRPC.h"

@interface TGFileLocation (Extensions)
- (BOOL) isEncrypted;
- (NSString *) cacheKey;
- (NSUInteger) hashCacheKey;

-(NSString *)path;

-(NSString *)squarePath;
@end
