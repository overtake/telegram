//
//  SecretSenterItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 18.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SenderItem.h"
#import "SecretLayer1.h"
#import "SecretLayer17.h"
#import "SecretLayer20.h"
#import "SecretLayer23.h"
#import "TGSecretAction.h"
#import "NSMutableData+Extension.h"
@interface SecretSenderItem : SenderItem


@property (nonatomic,strong,readonly) EncryptedParams *params;

@property (nonatomic,assign) long random_id;
@property (nonatomic,strong) NSData *random_bytes;

@property (nonatomic,strong) TGSecretAction *action;

-(id)initWithSecretAction:(TGSecretAction *)action;


-(id)initWithDecryptedData:(NSData *)decryptedData conversation:(TL_conversation *)conversation;

-(NSData *)decryptedMessageLayer;
-(NSData *)deleteRandomMessageData;

-(BOOL)increaseSeq;


@end
