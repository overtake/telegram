//
//  MessageSendSecretTextItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageSenderSecretItem.h"
#import "NSMutableData+Extension.h"



@implementation MessageSenderSecretItem

-(void)setState:(MessageState)state {
    [super setState:state];
}


-(id)initWithMessage:(NSString *)message forDialog:(TL_conversation *)dialog {
    if(self = [super init]) {
        self.dialog = dialog;
        
        self.message = [TL_destructMessage createWithN_id:0 from_id:UsersManager.currentUserId to_id:[TL_peerSecret createWithChat_id:dialog.peer.chat_id] n_out:YES unread:YES date:[[MTNetwork instance] getTime] message:message media:[TL_messageMediaEmpty create] destruction_time:0 randomId:rand_long() fakeId:[MessageSender getFakeMessageId] dstate:DeliveryStatePending];
        
        [self.message save:YES];
    }
    
    return self;
}


-(void)performRequest {
    
    TL_decryptedMessage *msg = [TL_decryptedMessage createWithRandom_id:((TL_destructMessage *)self.message).randomId random_bytes:[[NSMutableData alloc] initWithRandomBytes:256] message:self.message.message media:[TL_decryptedMessageMediaEmpty create]];
    
    NSData *messageData = [[TLClassStore sharedManager] serialize:msg];
    
    TLAPI_messages_sendEncrypted *request = [TLAPI_messages_sendEncrypted createWithPeer:[self.dialog.encryptedChat inputPeer] random_id:((TL_destructMessage *)self.message).randomId data:[MessageSender getEncrypted:self.dialog messageData:messageData]];
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_sentEncryptedMessage *response) {
        ((TL_destructMessage *)self.message).date = [response date];
        
        ((TL_destructMessage *)self.message).n_id = [MessageSender getFutureMessageId];
        
        self.message.dstate = DeliveryStateNormal;
        
        [self.message save:YES];
        self.state = MessageSendingStateSent;
       
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateError;
    }];

    
}

@end
