//
//  SecretSenterItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 18.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SecretSenderItem.h"
#import "Crypto.h"
#import "NSMutableData+Extension.h"
#import "UpgradeLayerSenderItem.h"

@interface SecretSenderItem ()<SenderListener>
@property (nonatomic,strong,readonly) NSData *decryptedData;
@end

@implementation SecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation {
    if(self = [self init]) {
        self.conversation = conversation;
    }
    
    return self;
}

-(id)init {
    if(self = [super init]) {
        _random_id = rand_long();
        _random_bytes = [[NSMutableData alloc] initWithRandomBytes:16];
    }
    
    return self;
}

-(void)setConversation:(TL_conversation *)conversation {
    [super setConversation:conversation];
    
    _params = [EncryptedParams findAndCreate:conversation.peer.peer_id];
}

-(void)setAction:(TGSecretAction *)action {
    _action = action;
    [self addEventListener:_action];
}

-(id)initWithSecretAction:(TGSecretAction *)action {
    if(self = [self init]) {
        self.action = action;
        _decryptedData = self.action.decryptedData;
    }
    
    return self;
}


-(id)initWithDecryptedData:(NSData *)decryptedData conversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        _decryptedData = decryptedData;
        self.conversation = conversation;
    }
    
    return self;
    
}

-(NSData *)decryptedMessageLayer0 {
    return nil;
}


-(NSData *)deleteRandomMessageData1 {
    return [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) random_bytes:self.random_bytes action:[Secret1_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:@[@(self.message.randomId)]]]];
}

-(NSData *)deleteRandomMessageData17 {
    return [Secret17__Environment serializeObject:[Secret17_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(17) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*self.params.out_seq_no + [self.params out_x]) message:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret17_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:@[@(self.message.randomId)]]]]];
}

-(NSData *)deleteRandomMessageData20 {
    return [Secret20__Environment serializeObject:[Secret20_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(20) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*self.params.out_seq_no + [self.params out_x]) message:[Secret20_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret20_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:@[@(self.message.randomId)]]]]];
}

-(NSData *)deleteRandomMessageData23 {
    return [Secret23__Environment serializeObject:[Secret23_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(23) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*self.params.out_seq_no + [self.params out_x]) message:[Secret23_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret23_DecryptedMessageAction decryptedMessageActionDeleteMessagesWithRandom_ids:@[@(self.message.randomId)]]]]];
}

-(NSData *)deleteRandomMessageData {
    return  [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"deleteRandomMessageData%d",_params.layer])];;
}

-(id)decryptedMessageLayer {
    
    if(!_decryptedData) {
        
        _decryptedData = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"decryptedMessageLayer%d",_params.layer])];

    }
    
    
    
    return _decryptedData;
}

-(BOOL)increaseSeq {
    return YES;
}


@end
