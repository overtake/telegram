//
//  TGCache.h
//  Telegram
//
//  Created by keepcoder on 17.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGCache : NSObject


extern NSString *const IMGCACHE;
extern NSString *const THUMBCACHE;
extern NSString *const PVCACHE;
extern NSString *const PCCACHE;
extern NSString *const AVACACHE;


+(void)cacheImage:(NSImage *)image forKey:(NSString *)key groups:(NSArray *)groups;

+(NSImage *)cachedImage:(NSString *)key;
+(NSImage *)cachedImage:(NSString *)key group:(NSArray *)groups;


+(void)removeCachedImage:(NSString *)key;
+(void)removeCachedImage:(NSString *)key groups:(NSArray *)groups;


+(void)removeAllCachedImages:(NSArray *)groups;


+(void)setMemoryLimit:(NSUInteger)limit group:(NSString *)group;
+(void)setCountLimit:(NSUInteger)limit group:(NSString *)group;

+(void)changeKey:(NSString *)key withKey:(NSString *)nkey;


+(void)clear;

@end
