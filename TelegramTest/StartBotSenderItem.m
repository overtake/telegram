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
@property (nonatomic,strong) TLUser *bot;
@end

@implementation StartBotSenderItem


-(id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation bot:(TLUser *)bot startParam:(NSString *)startParam {
    
    if(self = [super initWithConversation:conversation]) {
        
        _startParam = startParam;
        _bot = bot;
        
        self.message = [MessageSender createOutMessage:message media:[TL_messageMediaEmpty create] conversation:conversation];
        
        [self.message save:YES];
        
    }
    
    return self;
}



-(SendingQueueType)sendingQueue {
    return SendingQueueMessage;
}

-(void)performRequest {
    
    id request = [TLAPI_messages_startBot createWithBot:_bot.inputUser peer:self.conversation.inputPeer random_id:self.message.randomId start_param:_startParam];
    
    weak();
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates * response) {
        
        strongWeak();
        
        if(strongSelf != nil) {
            [strongSelf updateMessageId:response];
            
            TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[strongSelf updateNewMessageWithUpdates:response] message]];
            
            if(msg == nil)
            {
                [strongSelf cancel];
                return;
            }
            
            strongSelf.message.n_id = msg.n_id;
            strongSelf.message.date = msg.date;
            strongSelf.message.media = msg.media;
            
            strongSelf.message.dstate = DeliveryStateNormal;
            
            [strongSelf.message save:YES];
            
            strongSelf.state = MessageSendingStateSent;
        }
        
        
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        weakSelf.state = MessageSendingStateError;
    }];
    
}


-(void)resend {
    
}

@end
