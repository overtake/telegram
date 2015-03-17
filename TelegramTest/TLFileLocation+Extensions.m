//
//  TLFileLocation+Extensions.m
//  TelegramTest
//
//  Created by keepcoder on 28.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLFileLocation+Extensions.h"

@implementation TLFileLocation (Extensions)

-(BOOL)isEqual:(id)object {
    return [object local_id] == self.local_id && [object volume_id] == self.volume_id && [object secret] == self.secret;
}

-(BOOL)isEncrypted {
    return self.local_id == -1;
}


DYNAMIC_PROPERTY(MediaFileURL)


-(NSString *)path {
    NSString *p = [self getMediaFileURL];
    if(!p) {
        p = locationFilePath(self, @"jpg");
        [self setMediaFileURL:p];
    }
    
    return p;
}

DYNAMIC_PROPERTY(SquareMediaURL)


-(NSString *)squarePath {
    NSString *p = [self getSquareMediaURL];
    if(!p) {
        p = locationFilePathWithPrefix(self,@"200x200", @"jpg");
        [self setSquareMediaURL:p];
    }
    
    return p;
}

DYNAMIC_PROPERTY(CacheKey);



- (NSString *) cacheKey {
    
    NSString *string = [self getCacheKey];
    if(!string) {
        string = [NSString stringWithFormat:@"%lu_%lu", self.volume_id, self.secret];
        [self setCacheKey:string];
    }
    
    return string;
}

DYNAMIC_PROPERTY(HashCacheKey);


- (NSUInteger) hashCacheKey {
    NSNumber *number = [self getHashCacheKey];
    if(!number) {
        number = [NSNumber numberWithUnsignedInteger:[[self cacheKey] hash]];
        [self setHashCacheKey:number];
    }
    return [[self cacheKey] hash];
}

-(BOOL)isEqualTo:(TLFileLocation *)object {
    return object.volume_id == self.volume_id && object.local_id == self.local_id && object.secret == self.secret;
}

@end
