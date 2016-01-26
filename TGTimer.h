/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@interface TGTimer : NSObject

@property (nonatomic) NSTimeInterval timeoutDate;

@property (nonatomic,strong) id reservedObject;

- (id)initWithTimeout:(NSTimeInterval)timeout repeat:(bool)repeat completion:(dispatch_block_t)completion queue:(dispatch_queue_t)queue;

- (id)initWithTimeout:(NSTimeInterval)timeout repeat:(bool)repeat completion:(dispatch_block_t)completion queue:(dispatch_queue_t)queue reservedObject:(id)object;

- (void)start;
- (void)fireAndInvalidate;
- (void)fire;
- (void)invalidate;
- (bool)isScheduled;
- (void)resetTimeout:(NSTimeInterval)timeout;
- (NSTimeInterval)remainingTime;

@end
