//
//  ExternalGifSenderItem.m
//  Telegram
//
//  Created by keepcoder on 03/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "ExternalGifSenderItem.h"

@interface ExternalGifSenderItem ()
@property (nonatomic,strong) id dispatcher;
@property (nonatomic,strong) RPCRequest *request;
@end

@implementation ExternalGifSenderItem


-(id)initWithMedia:(TLMessageMedia *)media forConversation:(TL_conversation *)conversation {
    if(self = [super initWithConversation:conversation]) {
        
        self.message = [MessageSender createOutMessage:nil media:media conversation:conversation];
        
        [self.message save:YES];
        
        [Notification addObserver:self selector:@selector(didUpdateWebpage:) name:UPDATE_WEB_PAGES];
        
    }
    
    return self;
}


-(void)didUpdateWebpage:(NSNotification *)notification {
    TLWebPage *webpage = notification.userInfo[KEY_WEBPAGE];
    
    [ASQueue dispatchOnStageQueue:^{
        
        if([self.message.media.document.external_url isEqualToString:webpage.url]) {
           
            [self clear];
            
            if(webpage.document != nil) {
                self.message.media.document.external_webpage = webpage;
                [self performRequest];
            } else {
                [self cancel];
                return;
            }
            
            [self.message save:NO];
             
        }
        
    }];
}

-(void)dealloc {
     [self clear];
}

-(void)performRequest {
   
    
    dispatch_block_t execute = ^{
        
        if(self.state == MessageSendingStateCancelled)
            return;
        
        
        id request = [TLAPI_messages_sendMedia createWithFlags:0 peer:self.conversation.inputPeer reply_to_msg_id:0 media:[self.message.media.document isKindOfClass:[TL_externalDocument class]] ? [TL_inputMediaGifExternal createWithUrl:self.message.media.document.external_url q:self.message.media.document.search_q] : [TL_inputMediaDocument createWithN_id:[TL_inputDocument createWithN_id:self.message.media.document.n_id access_hash:self.message.media.document.access_hash]] random_id:self.message.randomId reply_markup:nil];
        
        _request = [RPCRequest sendRequest:request successHandler:^(id request, id response) {
            
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
            
            [self clear];
            
            self.state = MessageSendingStateSent;
            
        } errorHandler:^(id request, RpcError *error) {
            self.state = MessageSendingStateError;
            [self clear];
        } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    };
    
    if([self.message.media.document isKindOfClass:[TL_document class]] || [self.message.media.document.external_webpage isKindOfClass:[TL_webPage class]])
        execute();
    else
        [self requestFutureWebpage];
    
}


-(void)clear {
    [Notification removeObserver:self];
    remove_global_dispatcher(_dispatcher);
}

-(void)requestFutureWebpage {
    
    remove_global_dispatcher(_dispatcher);
    
    _dispatcher = dispatch_in_time(self.message.media.document.perform_date, ^{
        
        _request = [RPCRequest sendRequest:[TLAPI_messages_getWebPagePreview createWithMessage:self.message.media.document.external_url] successHandler:^(id request, TL_messageMediaWebPage *response) {
            
            if([response.webpage isKindOfClass:[TL_webPage class]]) {
                if(response.webpage.document != nil) {
                    self.message.media.document.external_webpage = response.webpage;
                    [self performRequest];
                } else {
                    [self cancel];
                    return;
                }
            } else if([response.webpage isKindOfClass:[TL_webPagePending class]]) {
                self.message.media.document.perform_date = response.webpage.date;
                [self requestFutureWebpage];
            }
            
            [self.message save:NO];
                
        } errorHandler:^(id request, RpcError *error) {
            
            [self cancel];
            
        } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
        
    });
}

-(void)cancel {
    [super cancel];
    [self clear];
    [_request cancelRequest];

}

@end
