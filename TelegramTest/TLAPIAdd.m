//
//  TLAPIAdd.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLAPIAdd.h"

@implementation TL_initConnection

- (NSData*)getData:(BOOL)isFirstRequest {
    SerializedData* stream = [[TLClassStore sharedManager] streamWithConstuctor:1769565673 isFirstRequest:isFirstRequest];
    
    [stream writeInt:API_ID];
    [stream writeString:self.device_model];
    [stream writeString:self.system_version];
    [stream writeString:self.app_version];
    [stream writeString:self.lang_code];
    
    [stream writeData:[self.query getData:NO]];
    
	return [stream getOutput];
}
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
