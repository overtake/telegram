//
//  ContextBotSenderItem.m
//  Telegram
//
//  Created by keepcoder on 28/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "ContextBotSenderItem.h"


@implementation ContextBotSenderItem

-(id)initWithBotContextResult:(TLBotInlineResult *)result via_bot_id:(int)via_bot_id queryId:(long)queryId additionFlags:(int)additionFlags conversation:(TL_conversation *)conversation {
    if(self = [super initWithConversation:conversation]) {
        
        TLMessageMedia *media = [TL_messageMediaBotResult createWithBot_result:result query_id:queryId];
        
        self.message = [MessageSender createOutMessage:result.send_message.message media:media conversation:conversation];
        
        self.message.entities = result.send_message.entities;
        
        [self.message setVia_bot_id:via_bot_id];
        
        if(additionFlags & (1 << 4))
            self.message.from_id = 0;
        
        [self.message save:YES];
        
    }
    
    return self;
}

-(void)performRequest {
    
    self.rpc_request = [RPCRequest sendRequest:[TLAPI_messages_sendInlineBotResult createWithFlags:[self senderFlags] peer:self.conversation.inputPeer reply_to_msg_id:self.message.reply_to_msg_id random_id:self.message.randomId query_id:self.message.media.query_id n_id:self.message.media.bot_result.n_id] successHandler:^(id request, id response) {
        
        [self updateMessageId:response];
        
        TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[self updateNewMessageWithUpdates:response] message]];
        
        if(msg == nil)
        {
            [self cancel];
            return;
        }
        
        self.message.n_id = msg.n_id;
        self.message.date = msg.date;
        self.message.media = msg.media;
        self.message.entities = msg.entities;
        
        self.message.dstate = DeliveryStateNormal;
        
        [self.message save:YES];
        
        self.state = MessageSendingStateSent;
        
    } errorHandler:^(id request, RpcError *error) {
        
        if(error.error_code == 400) {
            [self cancel];
        } else {
            self.message.dstate = DeliveryStateError;
            [self.message save:YES];
            
            self.state = MessageSendingStateError;
        }
        
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    
}



@end
