//
//  QueueManager.m
//  Telegram P-Edition
//
//  Created by keepcoder on 30.01.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "QueueManager.h"


@interface QueueManager ()
@property (nonatomic,strong) NSOperationQueue *queue;
@end

@implementation QueueManager

- (id)init {
    if(self = [super init]) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)add:(NSOperation *)operation {
    [self.queue addOperation:operation];
    
    NSLog(@"operation count:%d",self.queue.operationCount);
    
}

+(QueueManager *)sharedManager {
    static QueueManager *s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [[QueueManager alloc] init];
    });
    return s;
}
@end
