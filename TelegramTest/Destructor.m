//
//  Destructor.m
//  Messenger for Telegram
//
//  Created by keepcoder on 24.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "Destructor.h"

@implementation Destructor
-(id)initWithTLL:(int)ttl max_id:(int)max_id chat_id:(int)chat_id {
    if(self = [super init]) {
        self.ttl = ttl;
        self.max_id = max_id;
        self.chat_id = chat_id;
    }
    return self;
}
@end
