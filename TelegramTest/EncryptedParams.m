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
@property (nonatomic,strong) NSMutableDictionary *keys;


@end

@implementation EncryptedParams


static NSMutableDictionary *cached;

-(id)initWithChatId:(int)chat_id encrypt_key:(NSData *)encrypt_key key_fingerprint:(long)key_fingerprint a:(NSData *)a p:(NSData *)p random:(NSData *)random g_a_or_b:(NSData *)g_a_or_b g:(int)g state:(int)state access_hash:(long)access_hash layer:(int)layer isAdmin:(BOOL)isAdmin {
    if(self = [super init]) {
        _n_id = chat_id;
        _key_fingerprint = key_fingerprint;
        _a = a;
        _g = g;
        _g_a_or_b = g_a_or_b;
        _random = random;
        _p = p;
        _state = state;
        _access_hash = access_hash;
        _layer = layer;
        _isAdmin = isAdmin;
        _prev_layer = 1;
        _layer = 1;
        _keys = [[NSMutableDictionary alloc] init];
        
        
       
        
        [self setKey:encrypt_key forFingerprint:key_fingerprint];
        
    }
    return self;
}

-(void)setLayer:(int)layer {
    _prev_layer = _layer;
    _layer = MAX(1,layer);
}

-(NSDictionary *)yapObject {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@(self.n_id) forKey:@"chat_id"];
    [data setObject:@(self.key_fingerprint) forKey:@"key_fingerprint"];
    [data setObject:@(self.state) forKey:@"state"];
    [data setObject:@(self.access_hash) forKey:@"access_hash"];
    [data setObject:@(self.layer) forKey:@"layer"];
    [data setObject:@(self.in_seq_no) forKey:@"in_seq_no"];
    [data setObject:@(self.out_seq_no) forKey:@"out_seq_no"];
    [data setObject:@(self.isAdmin) forKey:@"isAdmin"];
    [data setObject:@(self.prev_layer) forKey:@"prevLayer"];
    [data setObject:@(self.ttl) forKey:@"ttl"];
    [data setObject:@(self.g) forKey:@"g"];
    [data setObject:@(self.original_key_fingerprint) forKey:@"original_key_fingerprint"];
    if(self.a)
        [data setObject:self.a forKey:@"a"];
    if(self.p)
        [data setObject:self.p forKey:@"dh_prime"];
    if(self.random)
        [data setObject:self.random forKey:@"random"];
    if(self.g_a_or_b)
        [data setObject:self.g_a_or_b forKey:@"g_a_or_b"];
    if(self.keys)
        [data setObject:self.keys forKey:@"keys"];
    
    return data;
}

-(NSString *)key {
    return [NSString stringWithFormat:@"%d",self.n_id];
}

-(int)out_x {
    return self.isAdmin ? 1 : 0;
}

-(int)in_x {
    return self.isAdmin ? 0 : 1;
}

-(NSData *)ekey:(long)fingerprint {
    return _keys[@(fingerprint)];
}

-(void)setIn_seq_no:(int)in_seq_no {
    _in_seq_no = in_seq_no;
    [self save];
}

-(void)setOut_seq_no:(int)out_seq_no {
    _out_seq_no = out_seq_no;
    [self save];
}

-(void)setTtl:(int)ttl {
    _ttl = ttl;
    [self save];
}


-(id)initWithYap:(NSDictionary *)object {
    if(self = [super init]) {
        _n_id = [[object objectForKey:@"chat_id"] intValue];
        _state = [[object objectForKey:@"state"] intValue];
        _key_fingerprint = [[object objectForKey:@"key_fingerprint"] longValue];
        _a = [object objectForKey:@"a"];
        _g = [[object objectForKey:@"g"] intValue];
        _random = [object objectForKey:@"random"];
        _p = [object objectForKey:@"dh_prime"];
        _access_hash = [[object objectForKey:@"access_hash"] longValue];
        _layer = [[object objectForKey:@"layer"] intValue];
        _in_seq_no = [[object objectForKey:@"in_seq_no"] intValue];
        _out_seq_no = [[object objectForKey:@"out_seq_no"] intValue];
        _isAdmin = [[object objectForKey:@"isAdmin"] intValue];
        _prev_layer = [[object objectForKey:@"prevLayer"] intValue];
        _ttl = [[object objectForKey:@"ttl"] intValue];
        _keys = [object objectForKey:@"keys"];
        _g_a_or_b = [object objectForKey:@"g_a_or_b"];
        _original_key_fingerprint = [[object objectForKey:@"original_key_fingerprint"] longValue];
        
    }
    return self;
}

-(void)save {
    if([[EncryptedParams cache] objectForKey:@(self.n_id)])
        [[EncryptedParams cache] setObject:self forKey:@(self.n_id)];
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSDictionary *params = [self yapObject];
        
        if(params)
            [transaction setObject:[self yapObject] forKey:[self key] inCollection:ENCRYPTED_PARAMS_COLLECTION];
    }];

}
-(NSData *)lastKey {
    return _keys[@(_key_fingerprint)];
}

-(NSData *)firstKey {
    return _keys[@(_original_key_fingerprint == 0 ? _key_fingerprint : _original_key_fingerprint)];
}

-(void)setKey:(NSData *)key forFingerprint:(long)fingerprint {
    if(fingerprint != 0) {
        if(_original_key_fingerprint == 0)
            _original_key_fingerprint = fingerprint;
        [_keys setObject:key forKey:@(fingerprint)];
    }
    
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
    
    [ASQueue dispatchOnStageQueue:^{
        
        if([[self cache] objectForKey:@(chat_id)])
            params = [[self cache] objectForKey:@(chat_id)];
        else {
            [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                params = [[EncryptedParams alloc] initWithYap:[transaction objectForKey:[NSString stringWithFormat:@"%d",chat_id] inCollection:ENCRYPTED_PARAMS_COLLECTION]];
            }];
            
            if(params) {
                [[self cache] setObject:params forKey:@(chat_id)];
            }
            
        }
        
    } synchronous:YES];
    
    
    return params;
}

-(void)discard {

    [RPCRequest sendRequest:[TLAPI_messages_discardEncryption createWithChat_id:_n_id] successHandler:^(RPCRequest *request, id response) {
        
        self.state = EncryptedDiscarted;
        
        [self save];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
    }];
}

@end
