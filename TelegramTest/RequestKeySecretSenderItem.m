//
//  RequestKeySecretSenderItem.m
//  Telegram
//
//  Created by keepcoder on 02.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "RequestKeySecretSenderItem.h"

@interface RequestKeySecretSenderItem ()
@property (nonatomic,strong) NSNumber *exchange_id;
@property (nonatomic,strong) NSData *g_a;
@end

@implementation RequestKeySecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation exchange_id:(long)exchange_id g_a:(NSData *)g_a {
    if(self = [super initWithConversation:conversation]) {
        _exchange_id = @(exchange_id);
        _g_a = g_a;
        
        self.action = [[TGSecretAction alloc] initWithActionId:[MessageSender getFutureMessageId] chat_id:conversation.peer.chat_id decryptedData:[self decryptedMessageLayer]  senderClass:[RequestKeySecretSenderItem class] layer:self.params.layer];
        
        [self.action save];
    }
    
    return self;
}


-(NSData *)decryptedMessageLayer20 {
    return [Secret20__Environment serializeObject:[Secret20_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(20) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret20_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret20_DecryptedMessageAction decryptedMessageActionRequestKeyWithExchange_id:self.exchange_id g_a:self.g_a]]]];
}

-(NSData *)decryptedMessageLayer23 {
    return [Secret23__Environment serializeObject:[Secret23_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(23) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret23_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret23_DecryptedMessageAction decryptedMessageActionRequestKeyWithExchange_id:self.exchange_id g_a:self.g_a]]]];
}


-(void)performRequest {
    
    TLAPI_messages_sendEncryptedService *request = [TLAPI_messages_sendEncryptedService createWithPeer:[TL_inputEncryptedChat createWithChat_id:self.action.chat_id access_hash:self.action.params.access_hash] random_id:self.random_id data:[MessageSender getEncrypted:self.action.params messageData:self.action.decryptedData]];
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_sentEncryptedMessage *response) {
        
        
        self.state = MessageSendingStateSent;
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateSent;
    }];
    
}

@end
