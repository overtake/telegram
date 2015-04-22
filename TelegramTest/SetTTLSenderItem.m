//
//  SetTTLSenderItem.m
//  Telegram
//
//  Created by keepcoder on 28.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SetTTLSenderItem.h"
#import "MessagesUtils.h"
#import "SelfDestructionController.h"
@implementation SetTTLSenderItem

-(id)initWithConversation:(TL_conversation *)conversation ttl:(int)ttl {
    if(self = [super initWithConversation:conversation]) {
        
        self.message = [TL_secretServiceMessage createWithN_id:[MessageSender getFutureMessageId] flags:TGOUTMESSAGE from_id:[UsersManager currentUserId] to_id:[TL_peerSecret createWithChat_id:conversation.peer.chat_id] date:[[MTNetwork instance] getTime] action:[TL_messageActionSetMessageTTL createWithTtl:ttl] fakeId:[MessageSender getFakeMessageId] randomId:rand_long() out_seq_no:-1 dstate:DeliveryStateNormal];
        
        [self.message save:YES];
        
        self.params.ttl = ttl;
        
    }
    
    return self;
}

-(void)setMessage:(TL_localMessage *)message {
    [super setMessage:message];
    
    self.action = [[TGSecretAction alloc] initWithActionId:self.message.n_id chat_id:self.conversation.peer.chat_id decryptedData:[self decryptedMessageLayer] senderClass:[SetTTLSenderItem class] layer:self.params.layer];
    
    [self.action save];
    
}


-(NSData *)decryptedMessageLayer1 {
    return [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) random_bytes:self.random_bytes action:[Secret1_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtl_seconds:@([(TL_messageActionSetMessageTTL *)self.message.action ttl])]]];
}

-(NSData *)decryptedMessageLayer17 {
    return [Secret17__Environment serializeObject:[Secret17_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(17) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret17_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtl_seconds:@([(TL_messageActionSetMessageTTL *)self.message.action ttl])]]]];
}

-(NSData *)decryptedMessageLayer20 {
    return [Secret20__Environment serializeObject:[Secret20_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(20) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret20_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret20_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtl_seconds:@([(TL_messageActionSetMessageTTL *)self.message.action ttl])]]]];
}

-(NSData *)decryptedMessageLayer23 {
    return [Secret23__Environment serializeObject:[Secret23_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(23) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret23_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret23_DecryptedMessageAction decryptedMessageActionSetMessageTTLWithTtl_seconds:@([(TL_messageActionSetMessageTTL *)self.message.action ttl])]]]];
}


-(void)performRequest {
    
    TLAPI_messages_sendEncryptedService *request = [TLAPI_messages_sendEncryptedService createWithPeer:[TL_inputEncryptedChat createWithChat_id:self.action.chat_id access_hash:self.action.params.access_hash] random_id:self.random_id data:[MessageSender getEncrypted:self.action.params messageData:self.decryptedMessageLayer]];
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_sentEncryptedMessage *response) {
        
        self.message.dstate = DeliveryStateNormal;
        
        [self.message save:YES];
        
        self.state = MessageSendingStateSent;
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateSent;
    }];
  
}

@end
