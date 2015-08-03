//
//  ImageLoader.h
//  TelegramTest
//
//  Created by keepcoder on 19.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"
@class DownloadOperation;
@interface DownloadQueue : NSObject


+(dispatch_queue_t)nativeQueue;

+ (void)dispatchOnStageQueue:(dispatch_block_t)block;

+ (void)dispatchOnStageQueue:(dispatch_block_t)block synchronous:(BOOL)synchronous;


+ (void)dispatchOnDownloadQueue:(dispatch_block_t)block;

+ (void)dispatchOnDownloadQueue:(dispatch_block_t)block synchronous:(BOOL)synchronous;

+(void)addAndStartItem:(DownloadItem *)item;
+(void)removeItem:(DownloadItem *)item;
+(void)pauseItem:(DownloadItem *)item;
+(void)resetItem:(DownloadItem *)item;

+(void)setProgress:(float)progress toOperation:(DownloadOperation *)operation;


+(DownloadItem *)find:(long)key;

@end
