//
//  ShareContactSenterItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 18.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ShareContactSenterItem.h"

@interface ShareContactSenterItem ()
@end

@implementation ShareContactSenterItem

-(void)setState:(MessageState)state {
    [super setState:state];
}


-(id)initWithContact:(TLUser *)contact forConversation:(TL_conversation *)conversation {
    if(self = [super init]) {
        self.conversation = conversation;
        TL_messageMediaContact *media = [TL_messageMediaContact createWithPhone_number:contact.phone  first_name:contact.first_name last_name:contact.last_name user_id:contact.n_id];
        
        self.message = [MessageSender createOutMessage:@"" media:media conversation:conversation];
        
        [self.message save:YES];

    }
    return self;
}


-(void)performRequest {
    
    
    id request;
    
    TLInputMedia *media = [TL_inputMediaContact createWithPhone_number:self.message.media.phone_number first_name:self.message.media.first_name last_name:self.message.media.last_name];
    
    if(self.conversation.type != DialogTypeBroadcast) {
        request = [TLAPI_messages_sendMedia createWithFlags:self.message.reply_to_msg_id != 0 ? 1 : 0 peer:self.conversation.inputPeer reply_to_msg_id:self.message.reply_to_msg_id media:media random_id:self.message.randomId];
    } else {
        request = [TLAPI_messages_sendBroadcast createWithContacts:[self.conversation.broadcast inputContacts] random_id:[self.conversation.broadcast generateRandomIds] message:self.message.message media:media];
    }
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates * response) {
        
        if(response.updates.count < 2)
        {
            [self cancel];
            return;
        }
        
        TLMessage *msg = [TL_localMessage convertReceivedMessage:(TLMessage *) ( [response.updates[1] message])];
        
        if(self.conversation.type != DialogTypeBroadcast)  {
            self.message.n_id = msg.n_id;
            self.message.date = msg.date;
            
        } 
        
        
        self.message.dstate = DeliveryStateNormal;
        
        [SharedManager proccessGlobalResponse:response];
        
        [self.message save:YES];
        
        self.state = MessageSendingStateSent;
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateError;
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];

}


@end
