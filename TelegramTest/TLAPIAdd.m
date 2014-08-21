//
//  TLAPIAdd.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLAPIAdd.h"

@implementation TL_initConnection

@end


@implementation TL_invokeAfter

-(void)serialize:(SerializedData *)stream {
    [stream writeLong:self.msg_id];
    [stream writeData:[self.query getData:NO]];
}

-(void)unserialize:(SerializedData *)stream {
    self.msg_id = [stream readLong];
    self.query = [[TLClassStore sharedManager] TLDeserialize:stream];
}


@end
