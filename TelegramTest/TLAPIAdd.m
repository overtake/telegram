//
//  TLAPIAdd.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLAPIAdd.h"
#import "ClassStore.h"



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