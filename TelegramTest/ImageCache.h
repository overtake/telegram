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
//- (NSImage*)imageFromMemory:(TGFileLocation*)location round:(int)round;
- (NSImage *) imageFromMemory:(TGFileLocation *)location;
- (void) editCacheKey:(TGFileLocation *)old withLocation:(TGFileLocation *)location;
- (void) setImage:(NSImage *)image forLocation:(TGFileLocation *)location;
- (NSImage *) imageFromMemory:(TGFileLocation*)location round:(int)round;

- (NSImage *)roundImageFromMemoryByHash:(NSUInteger)hash;
- (void)setRoundImageToMemory:(NSImage *)image hash:(NSUInteger)hash;


-(void)removeFromCache:(TGFileLocation *)location;

- (void) clear;
@end
