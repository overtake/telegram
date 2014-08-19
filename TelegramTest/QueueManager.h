//
//  QueueManager.h
//  Telegram P-Edition
//
//  Created by keepcoder on 30.01.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface QueueManager : NSObject

+(QueueManager *)sharedManager;
-(void)add:(NSOperation *)operation;
@end
