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
        request = [TLAPI_messages_sendMedia createWithPeer:self.conversation.inputPeer reply_to_msg_id:self.message.reply_to_msg_id media:media random_id:rand_long()];
    } else {
        request = [TLAPI_messages_sendBroadcast createWithContacts:[self.conversation.broadcast inputContacts] message:self.message.message media:media];
    }
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_statedMessage * response) {
        
        if(self.conversation.type != DialogTypeBroadcast)  {
            self.message.n_id = response.message.n_id;
            self.message.date = response.message.date;
            
        } else {
            TL_messages_statedMessages *stated = (TL_messages_statedMessages *) response;
            [Notification perform:MESSAGE_LIST_RECEIVE data:@{KEY_MESSAGE_LIST:stated.messages}];
            [Notification perform:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:stated.messages,@"update_real_date":@(YES)}];
            
        }
        
        
        self.message.dstate = DeliveryStateNormal;
        
        [SharedManager proccessGlobalResponse:response];
        
        [self.message save:YES];
        
        self.state = MessageSendingStateSent;
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateError;
    }];

}


@end
