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


#define MIN_ENCRYPTED_LAYER 1
#define MAX_ENCRYPTED_LAYER 23


@property (atomic,assign) long original_key_fingerprint;
@property (atomic,assign) long access_hash;
@property (atomic,strong) NSData *p;
@property (atomic,strong) NSData *a;
@property (atomic,strong) NSData *random;
@property (atomic,assign) int g;
@property (atomic,strong) NSData *g_a_or_b;
@property (atomic,assign) long key_fingerprint;
@property (atomic,assign) int n_id;
@property (atomic,assign) BOOL isAdmin;
@property (nonatomic,assign) int layer;
@property (atomic,assign) int prev_layer;

@property (nonatomic,assign) int in_seq_no;
@property (nonatomic,assign) int out_seq_no;

@property (nonatomic,assign) int ttl;


@property (nonatomic,assign) EncryptedState state;

typedef void (^stateHandler)(EncryptedState state);


@property (nonatomic,copy) stateHandler stateHandler;

-(id)initWithChatId:(int)chat_id encrypt_key:(NSData *)encrypt_key key_fingerprint:(long)key_fingerprint a:(NSData *)a p:(NSData *)p random:(NSData *)random g_a_or_b:(NSData *)g_a_or_b g:(int)g state:(int)state access_hash:(long)access_hash layer:(int)layer isAdmin:(BOOL)isAdmin;
-(NSDictionary *)yapObject;
-(id)initWithYap:(NSDictionary *)object;

-(void)save;
+(EncryptedParams *)findAndCreate:(int)chat_id;

-(NSData *)ekey:(long)fingerprint;
-(NSData *)lastKey;
-(NSData *)firstKey;
-(void)setKey:(NSData *)key forFingerprint:(long)fingerprint;


-(int)in_x;
-(int)out_x;

-(void)discard;


@end
