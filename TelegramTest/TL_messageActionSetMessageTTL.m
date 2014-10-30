//
//  TL_messageActionSetMessageTTL.m
//  Telegram
//
//  Created by keepcoder on 28.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_messageActionSetMessageTTL.h"

@implementation TL_messageActionSetMessageTTL


+(TL_messageActionSetMessageTTL*)createWithTtl:(int)ttl {
    TL_messageActionSetMessageTTL *obj = [[TL_messageActionSetMessageTTL alloc] init];
    obj.ttl = ttl;
    
    return obj;
}

-(void)serialize:(SerializedData *)stream {
    [stream writeInt:self.ttl];
}

-(void)unserialize:(SerializedData *)stream {
    self.ttl = [stream readInt];
}

@end
