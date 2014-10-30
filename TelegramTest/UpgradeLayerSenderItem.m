//
//  UpgradeLayerSenderItem.m
//  Telegram
//
//  Created by keepcoder on 27.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UpgradeLayerSenderItem.h"

@implementation UpgradeLayerSenderItem

-(id)initWithConversation:(TL_conversation *)conversation {
    if( self = [super initWithConversation:conversation] ) {
        
       self.action = [[TGSecretAction alloc] initWithActionId:[MessageSender getFutureMessageId] chat_id:conversation.peer.chat_id decryptedData:[self decryptedMessageLayer]  senderClass:[UpgradeLayerSenderItem class]];
        
    }
    
    return self;
}

-(NSData *)decryptedMessageLayer1 {
    return [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) random_bytes:self.random_bytes action:[Secret1_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:@(MAX_ENCRYPTED_LAYER)]]];
}

-(NSData *)decryptedMessageLayer17 {
    return [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) random_bytes:self.random_bytes action:[Secret1_DecryptedMessageAction decryptedMessageActionNotifyLayerWithLayer:@(MAX_ENCRYPTED_LAYER)]]];
}


-(BOOL)increaseSeq {
    return self.params.prev_layer >= 17;
}

- (void)performRequest {
    
    TLAPI_messages_sendEncryptedService *request = [TLAPI_messages_sendEncryptedService createWithPeer:[TL_inputEncryptedChat createWithChat_id:self.action.chat_id access_hash:self.action.params.access_hash] random_id:self.random_id data:[MessageSender getEncrypted:self.action.params messageData:self.action.decryptedData]];
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
    }];
    
    
}

@end
