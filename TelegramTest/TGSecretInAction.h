//
//  TGSecretInputAction.h
//  Telegram
//
//  Created by keepcoder on 30.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGSecretInAction : NSObject
@property (nonatomic,assign,readonly) int actionId;
@property (nonatomic,assign,readonly) int chat_id;
@property (nonatomic,strong,readonly) NSData *messageData;
@property (nonatomic,strong,readonly) NSData *fileData;
@property (nonatomic,assign,readonly) int in_seq_no;
@property (nonatomic,assign,readonly) int date;

@property (nonatomic,assign,readonly) int layer;

-(id)initWithActionId:(int)actionId chat_id:(int)chat_id messageData:(NSData *)messageData fileData:(NSData *)fileData date:(int)date in_seq_no:(int)in_seq_no layer:(int)layer;

@end
