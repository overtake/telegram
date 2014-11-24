//
//  TLFileLocation+Extensions.h
//  TelegramTest
//
//  Created by keepcoder on 28.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "MTProto.h"

@interface TLFileLocation (Extensions)
- (BOOL) isEncrypted;
- (NSString *) cacheKey;
- (NSUInteger) hashCacheKey;

-(NSString *)path;

-(NSString *)squarePath;
@end
