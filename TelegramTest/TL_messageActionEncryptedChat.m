//
//  TL_messageActionEncryptedChatCreated.m
//  Telegram P-Edition
//
//  Created by keepcoder on 25.01.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_messageActionEncryptedChat.h"

@implementation TL_messageActionEncryptedChat
+(TL_messageActionEncryptedChat*)createWithTitle:(NSString*)title {
	TL_messageActionEncryptedChat* obj = [[TL_messageActionEncryptedChat alloc] init];
	obj.title = title;
	return obj;
}
-(void)serialize:(SerializedData*)stream {
	[stream writeString:self.title];
}
-(void)unserialize:(SerializedData*)stream {
	self.title = [stream readString];
}

-(id)copy {
    TL_messageActionEncryptedChat* obj = [[TL_messageActionEncryptedChat alloc] init];

    obj.title = self.title;
    
    return obj;
}

@end
