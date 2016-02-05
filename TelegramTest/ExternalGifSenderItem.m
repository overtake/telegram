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


-(id)initWithMedia:(TLMessageMedia *)media additionFlags:(int)additionFlags forConversation:(TL_conversation *)conversation {
    if(self = [super initWithConversation:conversation]) {
        
        self.message = [MessageSender createOutMessage:nil media:media conversation:conversation];
        
        if(additionFlags & (1 << 4))
            self.message.from_id = 0;
        
        [self.message save:YES];
        
    }
    
    return self;
}



-(void)performRequest {
   
    
    dispatch_block_t execute = ^{
        
        if(self.state == MessageSendingStateCancelled)
            return;
        
        
        id request = [TLAPI_messages_sendMedia createWithFlags:[self senderFlags] peer:self.conversation.inputPeer reply_to_msg_id:self.message.reply_to_msg_id media:[TL_inputMediaDocument createWithN_id:[TL_inputDocument createWithN_id:self.message.media.document.n_id access_hash:self.message.media.document.access_hash] caption:@""] random_id:self.message.randomId reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:nil]];
        
        weak();
        
        self.rpc_request = [RPCRequest sendRequest:request successHandler:^(id request, id response) {
            
            strongWeak();
            
            if(strongSelf != nil) {
                [strongSelf updateMessageId:response];
                
                TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[strongSelf updateNewMessageWithUpdates:response] message]];
                
                strongSelf.message.n_id = msg.n_id;
                strongSelf.message.date = msg.date;
                strongSelf.message.media = msg.media;
                
                strongSelf.message.dstate = DeliveryStateNormal;
                
                [strongSelf.message save:YES];
            }
            
            
            
            
            strongSelf.state = MessageSendingStateSent;
            
        } errorHandler:^(id request, RpcError *error) {
            
            strongWeak();
            
            if(strongSelf != nil) {
                strongSelf.message.dstate = DeliveryStateError;
                [strongSelf.message save:YES];
                strongSelf.state = MessageSendingStateError;
            }
            
            
        } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    };
    
    execute();
    
}



@end
