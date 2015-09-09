//
//  MessageSendSecretTextItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageSenderSecretItem.h"
#import "NSMutableData+Extension.h"
#import "SelfDestructionController.h"
#import "DeleteRandomMessagesSenderItem.h"

@implementation MessageSenderSecretItem

-(void)setState:(MessageState)state {
    [super setState:state];
}


-(id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation  {
    if(self = [super initWithConversation:conversation]) {
        
        
        int ttl = self.params.ttl;
        
        self.message = [TL_destructMessage createWithN_id:[MessageSender getFutureMessageId] flags:TGOUTUNREADMESSAGE from_id:UsersManager.currentUserId to_id:[TL_peerSecret createWithChat_id:conversation.peer.chat_id] date:[[MTNetwork instance] getTime] message:message media:[TL_messageMediaEmpty create] destruction_time:0 randomId:rand_long() fakeId:[MessageSender getFakeMessageId] ttl_seconds:ttl == -1 ? 0 : ttl out_seq_no:-1 dstate:DeliveryStatePending];
        
        [self.message save:YES];
    }
    
    return self;
}

-(id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation noWebpage:(BOOL)noWebpage additionFlags:(int)additionFlags {
    if(self = [self initWithMessage:message forConversation:conversation]) {
        
    }
    
    return self;
}

-(void)setMessage:(TL_localMessage *)message {
    [super setMessage:message];
    
     self.action = [[TGSecretAction alloc] initWithActionId:self.message.n_id chat_id:self.conversation.peer.peer_id decryptedData:[self deleteRandomMessageData] senderClass:[DeleteRandomMessagesSenderItem class] layer:self.params.layer];
    
    [self.action save];
            
    [self addEventListener:self.action];
}


-(NSData *)decryptedMessageLayer1 {
    return [Secret1__Environment serializeObject:[Secret1_DecryptedMessage decryptedMessageWithRandom_id:@(self.message.randomId) random_bytes:[[NSMutableData alloc] initWithRandomBytes:16] message:self.message.message media:[Secret1_DecryptedMessageMedia decryptedMessageMediaEmpty]]];
}

-(NSData *)decryptedMessageLayer17 {
    return [Secret17__Environment serializeObject:[Secret17_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(17) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret17_DecryptedMessage decryptedMessageWithRandom_id:@(self.message.randomId) ttl:@(((TL_destructMessage *)self.message).ttl_seconds) message:self.message.message media:[Secret17_DecryptedMessageMedia decryptedMessageMediaEmpty]]]];
}

-(NSData *)decryptedMessageLayer20 {
    return [Secret20__Environment serializeObject:[Secret20_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(20) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret20_DecryptedMessage decryptedMessageWithRandom_id:@(self.message.randomId) ttl:@(((TL_destructMessage *)self.message).ttl_seconds) message:self.message.message media:[Secret20_DecryptedMessageMedia decryptedMessageMediaEmpty]]]];
}

-(NSData *)decryptedMessageLayer23 {
    return [Secret23__Environment serializeObject:[Secret23_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(23) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret23_DecryptedMessage decryptedMessageWithRandom_id:@(self.message.randomId) ttl:@(((TL_destructMessage *)self.message).ttl_seconds) message:self.message.message media:[Secret23_DecryptedMessageMedia decryptedMessageMediaEmpty]]]];
}


-(void)performRequest {
    
    TLAPI_messages_sendEncrypted *request = [TLAPI_messages_sendEncrypted createWithPeer:[TL_inputEncryptedChat createWithChat_id:self.action.chat_id access_hash:self.params.access_hash] random_id:self.message.randomId data:[MessageSender getEncrypted:self.params messageData:[self decryptedMessageLayer]]];
        
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_sentEncryptedMessage *response) {
        
        ((TL_destructMessage *)self.message).date = [response date];
        
        self.message.dstate = DeliveryStateNormal;
        
        [self.message save:YES];
        self.state = MessageSendingStateSent;
       
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateError;
    }];

    
}

@end
