//
//  ContextBotSenderItem.m
//  Telegram
//
//  Created by keepcoder on 28/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "ContextBotSenderItem.h"
#import "TGTimer.h"
#import "SpacemanBlocks.h"
@interface ContextBotSenderItem ()
{
    __block SMDelayedBlockHandle _handle;
}
@property (nonatomic,strong) TGTimer *timer;

@end


@implementation ContextBotSenderItem

-(id)initWithBotContextResult:(TLBotInlineResult *)result via_bot_id:(int)via_bot_id queryId:(long)queryId additionFlags:(int)additionFlags conversation:(TL_conversation *)conversation {
    if(self = [super initWithConversation:conversation]) {
        
        TLMessageMedia *media = [TL_messageMediaBotResult createWithBot_result:result query_id:queryId];
        
        self.message = [MessageSender createOutMessage:result.send_message.message media:media conversation:conversation additionFlags:additionFlags];
        
        self.message.entities = result.send_message.entities;
        
        [self.message setVia_bot_id:via_bot_id];
        
        
        [self.message save:YES];
        
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            
            NSMutableDictionary *bots = [[transaction objectForKey:@"bots" inCollection:@"inlinebots"] mutableCopy];
            
            if(!bots) {
                bots = [[NSMutableDictionary alloc] init];
            }
            
            bots[@(via_bot_id)] = @{@"id":@(via_bot_id),@"date":@([[MTNetwork instance] getTime])};
            
            [transaction setObject:bots forKey:@"bots" inCollection:@"inlinebots"];
            
        }];
        
    }
    
    return self;
}

-(void)performRequest {
    
    weak();
    
    _handle = perform_block_after_delay(1.0, ^{
        
        [ASQueue dispatchOnStageQueue:^{
            self.progress = 50.0f;
            
            _timer = [[TGTimer alloc] initWithTimeout:0.5 repeat:YES completion:^{
                
                self.progress+=5.0;
                
                if(self.progress == 100.0f) {
                    [_timer invalidate];
                    _timer = nil;
                }
                
            } queue:[ASQueue globalQueue].nativeQueue];
        }];
        
        
        
    });
    
    self.rpc_request = [RPCRequest sendRequest:[TLAPI_messages_sendInlineBotResult createWithFlags:[self senderFlags] peer:self.conversation.inputPeer reply_to_msg_id:self.message.reply_to_msg_id random_id:self.message.randomId query_id:self.message.media.query_id n_id:self.message.media.bot_result.n_id] successHandler:^(id request, id response) {
        
        strongWeak();
        
        
        
        if(strongSelf != nil) {
            
            cancel_delayed_block(_handle);
            
            [_timer invalidate];
            
            [weakSelf updateMessageId:response];
            
            TLMessage *msg = [[weakSelf updateNewMessageWithUpdates:response] message];
            
            if(msg == nil)
            {
                [weakSelf cancel];
                return;
            }
            
            BOOL needUpdateMessage = !weakSelf.message.media.bot_result.document;
            
            weakSelf.message.n_id = msg.n_id;
            weakSelf.message.date = msg.date;
            weakSelf.message.media = msg.media;
            weakSelf.message.entities = msg.entities;
            
            weakSelf.message.dstate = DeliveryStateNormal;
            
            [weakSelf.message save:YES];
            
            weakSelf.state = MessageSendingStateSent;
            
            
            if([weakSelf.message.media isKindOfClass:[TL_messageMediaWebPage class]])
            {
                [Notification perform:UPDATE_WEB_PAGE_ITEMS data:@{KEY_DATA:@{@(weakSelf.message.peer_id):@[@(weakSelf.message.n_id)]},KEY_WEBPAGE:weakSelf.message.media.webpage}];
            }
            
            if(needUpdateMessage) {
                [Notification perform:UPDATE_EDITED_MESSAGE data:@{KEY_MESSAGE:weakSelf.message,@"nonselect":@(YES)}];
            }

        }
        
        
    } errorHandler:^(id request, RpcError *error) {
        
        strongWeak();
        
        if(strongSelf != nil) {
            if(error.error_code == 400) {
                [self cancel];
            } else {
                self.message.dstate = DeliveryStateError;
                [self.message save:YES];
                
                self.state = MessageSendingStateError;
            }
        }

    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    
}


-(void)dealloc {
    [_timer invalidate];
}


@end
