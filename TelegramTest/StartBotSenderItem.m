//
//  MessageSendItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "StartBotSenderItem.h"
#import "TLPeer+Extensions.h"
#import "MessageTableItem.h"
@interface StartBotSenderItem ()
@property (nonatomic,strong) NSString *startParam;
@end

@implementation StartBotSenderItem


-(id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation startParam:(NSString *)startParam {
    
    if(self = [super initWithConversation:conversation]) {
        
        _startParam = startParam;
        
        self.message = [MessageSender createOutMessage:message media:[TL_messageMediaEmpty create] conversation:conversation];
        
    }
    
    return self;
}



-(SendingQueueType)sendingQueue {
    return SendingQueueMessage;
}

-(void)performRequest {
    
    id request = [TLAPI_messages_startBot createWithBot:self.conversation.inputPeer chat_id:0 random_id:self.message.randomId start_param:_startParam];
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_sentMessage * response) {
        
        self.message.n_id = response.n_id;
        self.message.date = response.date;
        self.message.media = response.media;
            
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
