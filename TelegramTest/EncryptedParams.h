//
//  EncryptedParams.h
//  Telegram P-Edition
//
//  Created by keepcoder on 17.12.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncryptedParams : NSObject


typedef enum  {
    EncryptedWaitOnline = 0,
    EncryptedAllowed = 1,
    EncryptedDiscarted = 2,
    EncryptedRequested = 3
} EncryptedState;


@property (nonatomic,assign) long access_hash;
@property (nonatomic,strong) NSData *encrypt_key;
@property (nonatomic,strong) NSData *dh_prime;
@property (nonatomic,strong) NSData *a;
@property (nonatomic,strong) NSData *g_a;
@property (nonatomic,assign) long key_fingerprints;
@property (nonatomic,assign) int n_id;
@property (nonatomic,assign) EncryptedState state;

typedef void (^stateHandler)(EncryptedState state);


@property (nonatomic,copy) stateHandler stateHandler;

-(id)initWithChatId:(int)chat_id encrypt_key:(NSData *)encrypt_key key_fingerprings:(long)key_fingerprints a:(NSData *)a g_a:(NSData *)g_a dh_prime:(NSData *)dh_prime state:(int)state access_hash:(long)access_hash;
-(NSDictionary *)yapObject;
-(id)initWithYap:(NSDictionary *)object;

-(void)save;
+(EncryptedParams *)findAndCreate:(int)chat_id;


@end
