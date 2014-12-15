//
//  TLAPIAdd.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLAPIAdd.h"

@implementation TL_initConnection

- (NSData*)getData {
    SerializedData* stream = [TLClassStore streamWithConstuctor:1769565673];
    
    [stream writeInt:API_ID];
    [stream writeString:self.device_model];
    [stream writeString:self.system_version];
    [stream writeString:self.app_version];
    [stream writeString:self.lang_code];
    
    [stream writeData:[self.query getData]];
    
	return [stream getOutput];
}
@end



@implementation TL_invokeAfter
+(TL_invokeAfter*)createWithMsg_id:(long)msg_id query:(NSData*)query {
    TL_invokeAfter* obj = [[TL_invokeAfter alloc] init];
    obj.msg_id = msg_id;
    obj.query = query;
    return obj;
}
-(void)serialize:(SerializedData*)stream {
    [stream writeLong:self.msg_id];
    [stream writeData:self.query];
}

@end