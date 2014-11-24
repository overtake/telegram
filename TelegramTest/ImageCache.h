//
//  ImageCache.h
//  TelegramTest
//
//  Created by keepcoder on 19.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadQueue.h"

@interface ImageCache : NSCache
+(ImageCache *)sharedManager;
//- (NSImage*)imageFromMemory:(TLFileLocation*)location round:(int)round;
- (NSImage *) imageFromMemory:(TLFileLocation *)location;
- (void) editCacheKey:(TLFileLocation *)old withLocation:(TLFileLocation *)location;
- (void) setImage:(NSImage *)image forLocation:(TLFileLocation *)location;
- (NSImage *) imageFromMemory:(TLFileLocation*)location round:(int)round;

- (NSImage *)roundImageFromMemoryByHash:(NSUInteger)hash;
- (void)setRoundImageToMemory:(NSImage *)image hash:(NSUInteger)hash;


-(void)removeFromCache:(TLFileLocation *)location;

- (void) clear;

+(NSCache *)roundedCache;

@end
