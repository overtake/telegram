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
#define MAX_ENCRYPTED_LAYER 20

@property (atomic,assign) long access_hash;
@property (atomic,strong) NSData *encrypt_key;
@property (atomic,strong) NSData *dh_prime;
@property (atomic,strong) NSData *a;
@property (atomic,strong) NSData *g_a;
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

-(id)initWithChatId:(int)chat_id encrypt_key:(NSData *)encrypt_key key_fingerprint:(long)key_fingerprint a:(NSData *)a g_a:(NSData *)g_a dh_prime:(NSData *)dh_prime state:(int)state access_hash:(long)access_hash layer:(int)layer isAdmin:(BOOL)isAdmin;
-(NSDictionary *)yapObject;
-(id)initWithYap:(NSDictionary *)object;

-(void)save;
+(EncryptedParams *)findAndCreate:(int)chat_id;

-(NSData *)encryptedKey:(int)fingerprint;

-(int)in_x;
-(int)out_x;

@end
