//
//  TLClassStore.h
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/26/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializedData.h"
#import "TLRPC.h"
#import "TL_messageActionEncryptedChat.h"
#import "TL_conversation.h"
#import "TL_inputMessagesFilterAudio.h"
@interface TLClassStore : NSObject
+ (TLClassStore*) sharedManager;

- (id)TLDeserialize:(SerializedData*)stream;
- (void)TLSerialize:(TLObject*)obj stream:(SerializedData*)stream;

- (id)deserialize:(NSData*)data;
- (id)constructObject:(NSInputStream *)is;

- (NSData*)serialize:(TLObject*)obj;
- (NSData*)serialize:(TLObject*)obj isCacheSerialize:(bool)isCacheSerialize;

- (SerializedData*)streamWithConstuctor:(int)constructor isFirstRequest:(BOOL)isFirstRequest;
@end

@interface RpcLayer : NSObject

@property (nonatomic, strong) id query;

@end
