//
//  SQueue+ASExtension.m
//  Telegram
//
//  Created by keepcoder on 06/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "SQueue+ASExtension.h"

@implementation SQueue (ASExtension)


- (void)dispatchOnQueue:(dispatch_block_t)block {
    [self dispatch:block];
}
- (void)dispatchOnQueue:(dispatch_block_t)block synchronous:(bool)synchronous {
    if(synchronous)
        [self dispatchSync:block];
    else
        [self dispatch:block];
}

@end
