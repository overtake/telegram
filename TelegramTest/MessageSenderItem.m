//
//  MessageSendItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageSenderItem.h"
#import "TGPeer+Extensions.h"
#import "TGDialog+Extensions.h"
#import "MessageTableItem.h"
@interface MessageSenderItem ()
@end

@implementation MessageSenderItem

-(void)setState:(MessageState)state {
    [super setState:state];
}

-(id)initWithMessage:(NSString *)message forDialog:(TL_conversation *)dialog {
    if(self = [super init]) {
        self.dialog = dialog;
        
        self.message = [MessageSender createOutMessage:message media:[TL_messageMediaEmpty create] dialog:dialog];
        
        [self.message save:YES];
        
    }
    return self;
}


-(void)performRequest {
    
     id request;
    
    if(self.dialog.type != DialogTypeBroadcast) {
        request = [TLAPI_messages_sendMessage createWithPeer:[self.dialog inputPeer] message:[self.message message] random_id:[self.message randomId]];
    } else {
        
        TL_broadcast *broadcast = self.dialog.broadcast;
        
        request = [TLAPI_messages_sendBroadcast createWithContacts:[broadcast inputContacts] message:self.message.message media:[TL_inputMediaEmpty create]];
    }
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_sentMessage * response) {
        
        
        if(self.dialog.type != DialogTypeBroadcast)  {
            
            self.message.n_id = response.n_id;
            self.message.date = response.date;
            
        } else {
            TL_messages_statedMessages *stated = (TL_messages_statedMessages *) response;
            [TL_localMessage convertReceivedMessages:stated.messages];
            
            [SharedManager proccessGlobalResponse:stated];
            
            [Notification perform:MESSAGE_LIST_RECEIVE data:@{KEY_MESSAGE_LIST:stated.messages}];
            [Notification perform:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:stated.messages,@"update_real_date":@(YES)}];
            
        }
        
        self.message.dstate = DeliveryStateNormal;
        
        [self.message save:YES];
        
        self.state = MessageSendingStateSent;

               
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateError;
    }];
    
}



-(void)resend {
    
}

@end
