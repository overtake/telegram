//
//  TL_messageActionBotDescription.m
//  Telegram
//
//  Created by keepcoder on 05.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TL_messageActionBotDescription.h"

@implementation TL_messageActionBotDescription

+(TL_messageActionBotDescription*)createWithTitle:(NSString*)title {
    TL_messageActionBotDescription* obj = [[TL_messageActionBotDescription alloc] init];
    obj.title = title;
    return obj;
}
-(void)serialize:(SerializedData*)stream {
    [stream writeString:self.title];
}
-(void)unserialize:(SerializedData*)stream {
    self.title = [stream readString];
}

@end
