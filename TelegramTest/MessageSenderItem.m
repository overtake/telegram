//
//  MessageSendItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageSenderItem.h"
#import "TLPeer+Extensions.h"
#import "MessageTableItem.h"
@interface MessageSenderItem ()
@property (nonatomic,assign) BOOL noWebpage;
@end

@implementation MessageSenderItem


-(id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation entities:(NSArray *)entities noWebpage:(BOOL)noWebpage additionFlags:(int)additionFlags {
    
    if(self = [super initWithConversation:conversation]) {
        
        message = [message trim];
        
        self.message = [MessageSender createOutMessage:message media:[TL_messageMediaEmpty create] conversation:conversation additionFlags:additionFlags];
        

        self.message.entities = [entities mutableCopy];
        

        
        if(noWebpage)
            self.message.media = [TL_messageMediaWebPage createWithWebpage:[TL_webPageEmpty createWithN_id:0]];
        
        [self.message save:YES];
    
    }

    return self;
}

-(id)initWithMessage:(NSString *)message forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags {
    if(self = [self initWithMessage:message forConversation:conversation  entities:nil noWebpage:YES additionFlags:additionFlags]) {
        
    }
    
    return self;
}


-(SendingQueueType)sendingQueue {
    return SendingQueueMessage;
}

-(void)performRequest {
    
    id request;
    
    
    
    request = [TLAPI_messages_sendMessage createWithFlags:[self senderFlags] peer:[self.conversation inputPeer] reply_to_msg_id:self.message.reply_to_msg_id message:[self.message message] random_id:[self.message randomId] reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:nil] entities:self.message.entities];
    
    
    weak();
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_updateShortSentMessage *response) {
        
        strongWeak();
        
        if(strongSelf != nil) {
            
            
            
            [strongSelf updateMessageId:response];
            
            if([response isKindOfClass:[TL_updates class]]) {
                
                response = (TL_updateShortSentMessage *)[[strongSelf updateNewMessageWithUpdates:response] message];
                
                
            }
            
            strongSelf.message.n_id = response.n_id;
            strongSelf.message.date = response.date;
            strongSelf.message.media = response.media;
            strongSelf.message.entities = response.entities;
            strongSelf.message.dstate = DeliveryStateNormal;
            
            [strongSelf.message save:YES];
            
            strongSelf.state = MessageSendingStateSent;
            
            
            if([strongSelf.message.media isKindOfClass:[TL_messageMediaWebPage class]])
            {
                [Notification perform:UPDATE_WEB_PAGE_ITEMS data:@{KEY_DATA:@{@(strongSelf.message.peer_id):@[@(strongSelf.message.n_id)]},KEY_WEBPAGE:strongSelf.message.media.webpage}];
            }
            
            if(strongSelf.message.entities.count > 0) {
                [Notification perform:UPDATE_MESSAGE_ENTITIES data:@{KEY_MESSAGE:strongSelf.message}];
            }

        }
        
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        weakSelf.state = MessageSendingStateError;
    }];
    
}





-(void)resend {
    
}


@end
