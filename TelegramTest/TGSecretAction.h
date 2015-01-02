//
//  TGEncryptedAction.h
//  Telegram
//
//  Created by keepcoder on 28.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MTProto.h"
#import "SenderListener.h"
@class SecretSenderItem;

@interface TGSecretAction : NSObject<SenderListener>

@property (nonatomic,assign,readonly) int actionId; 
@property (nonatomic,assign,readonly) int chat_id;
@property (nonatomic,assign,readonly) int layer;




@property (nonatomic,strong,readonly) NSData *decryptedData;

@property (nonatomic,strong,readonly) Class senderClass;

@property (nonatomic,strong,readonly) EncryptedParams *params;



-(id)initWithActionId:(int)actionId chat_id:(int)chat_id decryptedData:(NSData *)decryptedData senderClass:(Class)senderClass layer:(int)layer;

-(id)initWithActionId:(int)actionId chat_id:(int)chat_id decryptedData:(NSData *)decryptedData layer:(int)layer;

+(id)requestActionWithMessageId:(int)messageId;


+(void)dequeAllStorageActions;


-(void)save;
-(void)remove;
@end
