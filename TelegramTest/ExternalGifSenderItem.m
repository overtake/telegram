//
//  ExternalGifSenderItem.m
//  Telegram
//
//  Created by keepcoder on 03/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "ExternalGifSenderItem.h"

@interface ExternalGifSenderItem ()
@end

@implementation ExternalGifSenderItem


-(id)initWithMedia:(TLMessageMedia *)media forConversation:(TL_conversation *)conversation {
    if(self = [super initWithConversation:conversation]) {
        
        self.message = [MessageSender createOutMessage:nil media:media conversation:conversation];
        
        [self.message save:YES];
        
    }
    
    return self;
}



-(void)performRequest {
   
    
    dispatch_block_t execute = ^{
        
        if(self.state == MessageSendingStateCancelled)
            return;
        
        
        id request = [TLAPI_messages_sendMedia createWithFlags:0 peer:self.conversation.inputPeer reply_to_msg_id:0 media:[self.message.media.document isKindOfClass:[TL_externalDocument class]] ? [TL_inputMediaGifExternal createWithUrl:self.message.media.document.external_url q:self.message.media.document.search_q] : [TL_inputMediaDocument createWithN_id:[TL_inputDocument createWithN_id:self.message.media.document.n_id access_hash:self.message.media.document.access_hash]] random_id:self.message.randomId reply_markup:nil];
        
        self.rpc_request = [RPCRequest sendRequest:request successHandler:^(id request, id response) {
            
            [self updateMessageId:response];
            
            TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[self updateNewMessageWithUpdates:response] message]];
            
            self.message.n_id = msg.n_id;
            self.message.date = msg.date;
            self.message.media = msg.media;
            self.message.entities = msg.entities;
            
            if([self.message.media isKindOfClass:[TL_messageMediaWebPage class]])
            {
                [Notification perform:UPDATE_WEB_PAGE_ITEMS data:@{KEY_DATA:@{@(self.message.peer_id):@[@(self.message.n_id)]},KEY_WEBPAGE:self.message.media.webpage}];
            }
            
            if(self.message.entities.count > 0) {
                [Notification perform:UPDATE_MESSAGE_ENTITIES data:@{KEY_MESSAGE:self.message}];
            }

            
            self.message.dstate = DeliveryStateNormal;
            
            [self.message save:YES];
            
            
            self.state = MessageSendingStateSent;
            
        } errorHandler:^(id request, RpcError *error) {
            self.state = MessageSendingStateError;
        } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    };
    
    execute();
    
}



@end
