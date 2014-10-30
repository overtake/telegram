//
//  FlushHistorySecretSenderItem.m
//  Telegram
//
//  Created by keepcoder on 30.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "FlushHistorySecretSenderItem.h"
#import "SelfDestructionController.h"
@implementation FlushHistorySecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation {
    if(self = [super initWithConversation:conversation]) {
        self.action = [[TGSecretAction alloc] initWithActionId:[MessageSender getFutureMessageId] chat_id:self.params.n_id decryptedData:[self decryptedMessageLayer] senderClass:[self class]];
    }
    
    return self;
}



-(NSData *)decryptedMessageLayer1 {
    return [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) random_bytes:self.random_bytes action:[Secret1_DecryptedMessageAction decryptedMessageActionFlushHistory]]];
}

-(NSData *)decryptedMessageLayer17 {
    return [Secret17__Environment serializeObject:[Secret17_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(17) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret17_DecryptedMessageAction decryptedMessageActionFlushHistory]]]];
}


-(void)performRequest {
    
    
    TLAPI_messages_sendEncryptedService *request = [TLAPI_messages_sendEncryptedService createWithPeer:[TL_inputEncryptedChat createWithChat_id:self.action.chat_id access_hash:self.action.params.access_hash] random_id:self.random_id data:[MessageSender getEncrypted:self.action.params messageData:self.action.decryptedData]];
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_sentEncryptedMessage *response) {
        
        
        self.state = MessageSendingStateSent;
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateError;
    }];
    
}


@end
