//
//  EncryptedParams.m
//  Telegram P-Edition
//
//  Created by keepcoder on 17.12.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "EncryptedParams.h"
#import "Crypto.h"

@interface EncryptedParams ()
@end

@implementation EncryptedParams


static NSMutableDictionary *cached;

-(id)initWithChatId:(int)chat_id encrypt_key:(NSData *)encrypt_key key_fingerprings:(long)key_fingerprints a:(NSData *)a g_a:(NSData *)g_a dh_prime:(NSData *)dh_prime state:(int)state access_hash:(long)access_hash {
    if(self = [super init]) {
        self.n_id = chat_id;
        self.encrypt_key = encrypt_key;
        self.key_fingerprints = key_fingerprints;
        self.a = a;
        self.g_a = g_a;
        self.dh_prime = dh_prime;
        self->_state = state;
        self.access_hash = access_hash;
    }
    return self;
}



-(NSDictionary *)yapObject {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@(self.n_id) forKey:@"chat_id"];
    [data setObject:@(self.key_fingerprints) forKey:@"key_fingerprints"];
    [data setObject:@(self.state) forKey:@"state"];
    [data setObject:@(self.access_hash) forKey:@"access_hash"];
    if(self.encrypt_key)
        [data setObject:self.encrypt_key forKey:@"encrypt_key"];
    if(self.a)
        [data setObject:self.a forKey:@"a"];
    if(self.dh_prime)
        [data setObject:self.dh_prime forKey:@"dh_prime"];
    if(self.g_a)
        [data setObject:self.g_a forKey:@"g_a"];
    
    return data;
}

-(NSString *)key {
    return [NSString stringWithFormat:@"%d",self.n_id];
}

-(id)initWithYap:(NSDictionary *)object {
    if(self = [super init]) {
        self.n_id = [[object objectForKey:@"chat_id"] intValue];
        self.state = [[object objectForKey:@"state"] intValue];
        self.encrypt_key = [object objectForKey:@"encrypt_key"];
        self.key_fingerprints = [[object objectForKey:@"key_fingerprints"] longValue];
        self.a = [object objectForKey:@"a"];
        self.g_a = [object objectForKey:@"g_a"];
        self.dh_prime = [object objectForKey:@"dh_prime"];
        self.access_hash = [[object objectForKey:@"access_hash"] longValue];
        if(self.encrypt_key.length != 256) {
            self.encrypt_key = [Crypto exp:[self g_a] b:self.a dhPrime:self.dh_prime];
        }
    }
    return self;
}

-(void)save {
    if([[EncryptedParams cache] objectForKey:@(self.n_id)])
        [[EncryptedParams cache] setObject:self forKey:@(self.n_id)];
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:[self yapObject] forKey:[self key] inCollection:ENCRYPTED_PARAMS_COLLECTION];
    }];

}

+(NSMutableDictionary *)cache {
    if(cached == nil)
        cached = [[NSMutableDictionary alloc] init];
    return cached;
}


-(void)setState:(EncryptedState)state {
    self->_state = state;
    [LoopingUtils runOnMainQueueAsync:^{
        if(self.stateHandler)
            self.stateHandler(state);
    }];
}


+(EncryptedParams *)findAndCreate:(int)chat_id {
    __block EncryptedParams *params;
    if([[self cache] objectForKey:@(chat_id)])
        return [[self cache] objectForKey:@(chat_id)];
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        params = [[EncryptedParams alloc] initWithYap:[transaction objectForKey:[NSString stringWithFormat:@"%d",chat_id] inCollection:ENCRYPTED_PARAMS_COLLECTION]];
    }];
    [[self cache] setObject:params forKey:@(chat_id)];
    return params;
}

@end
