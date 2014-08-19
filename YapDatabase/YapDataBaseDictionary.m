//
//  YapDataBaseDictionary.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "YapDataBaseDictionary.h"

@implementation NSDictionary(OLDKEYS)

+ (id)sharedKeySetForKeysNew:(NSArray *)keys {
    return keys;
}

@end

@implementation NSMutableDictionary(OLDKEYS)

+ (id)dictionaryWithSharedKeySetNew:(NSArray *)keyset {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for(NSString *string in keyset) {
        [dictionary setObject:[NSNull null] forKey:string];
    }
    return dictionary;
}

@end

