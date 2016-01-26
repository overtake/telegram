//
//  ForwardSenterItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 18.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ForwardSenterItem.h"
#import "NSArray+BlockFiltering.h"
#import "MessageTableItem.h"
#import "TLPeer+Extensions.h"



@interface ForwardSenterItem ()

@property (nonatomic,strong) TLInputPeer *from_peer;
@end


@implementation ForwardSenterItem

-(void)setState:(MessageState)state {
    [super setState:state];
}


-(id)initWithMessages:(NSArray *)msgs forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags {
    if(self = [super init]) {
        self.conversation = conversation;
        
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        NSMutableArray *fakes = [[NSMutableArray alloc] init];
        NSMutableArray *copy = [msgs mutableCopy];
        
        [copy sortUsingComparator:^NSComparisonResult(TL_localMessage * obj1, TL_localMessage * obj2) {
            return [@(obj1.n_id) compare:@(obj2.n_id)];
        }];
        
        
        
        for (int i = 0; i < copy.count; i++) {
            
            long random = rand_long();
            
            TL_localMessage *f = copy[i];
            
            
            
            [ids addObject:@([f n_id])];
            
            TL_localMessage *fake = [TL_localMessage createWithN_id:0 flags:TGOUTUNREADMESSAGE | TGFWDMESSAGE from_id:[UsersManager currentUserId] to_id:conversation.peer fwd_from_id:[f.to_id isKindOfClass:[TL_peerChannel class]] && !f.chat.isMegagroup ? f.to_id : [f.fwd_from_id isKindOfClass:[TL_peerChannel class]] && !f.chat.isMegagroup ? f.fwd_from_id : [TL_peerUser createWithUser_id:f.fwd_from_id.user_id != 0 ? f.fwd_from_id.user_id : f.from_id] fwd_date:f.date reply_to_msg_id:0 date:[[MTNetwork instance] getTime] message:f.message media:f.media fakeId:[MessageSender getFakeMessageId] randomId:random reply_markup:nil entities:f.entities views:f.views isViewed:NO state:DeliveryStatePending];
            
            
            if([f.fwd_from_id isKindOfClass:[TL_peerChannel class]] || ([f.to_id isKindOfClass:[TL_peerChannel class]] && f.chat.isMegagroup)) {
                _from_peer = [f.to_id inputPeer];
            }
            
            
            if(additionFlags & (1 << 4))
                fake.from_id = 0;
             
            [fake save:i == copy.count-1];
            
            [fakes insertObject:fake atIndex:0];
            
        }
        
        
        self.msg_ids = ids;
        
        self.fakes = fakes;
        
    }
    
    return self;
}



-(void)setTableItems:(NSArray *)tableItems {
    self->_tableItems = tableItems;
    for (MessageTableItem *item in tableItems) {
        item.messageSender = self;
    }
}

-(void)performRequest {

    if(self.fakes.count == 0) {
        self.state = MessageSendingStateSent;
        return;
    }
    
    NSMutableArray *random_ids = [[NSMutableArray alloc] init];
    
    __block TLInputPeer *from_peer = _from_peer;
    
    [self.fakes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TL_localMessage  *obj, NSUInteger idx, BOOL *stop) {
        [random_ids addObject:@(obj.randomId)];
        
        if(!from_peer) {
            from_peer = [obj.fwd_from_id inputPeer];
        }
        
    }];
    
    TLAPI_messages_forwardMessages *request = [TLAPI_messages_forwardMessages createWithFlags:[self senderFlags] from_peer:from_peer n_id:[self.msg_ids mutableCopy] random_id:random_ids to_peer:self.conversation.inputPeer];
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates *response) {
        
        
        if(response.updates.count < 2)
        {
            [self cancel];
            return;
        }
        
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        
        [response.updates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if([obj isKindOfClass:[TL_updateNewMessage class]] || [obj isKindOfClass:[TL_updateNewChannelMessage class]]) {
                [messages addObject:[TL_localMessage convertReceivedMessage:(TL_localMessage *)[obj message]]];
            }
            
        }];
        
        int k = (int) messages.count;
        
        for(int i = 0; i < messages.count; i++) {
            
            --k;
            
            TL_localMessage *fake = self.fakes[i];
            TL_localMessage *stated = messages[k];
            
            fake.date = stated.date;
            fake.n_id = stated.n_id;
            fake.dstate = DeliveryStateNormal;
            
            [fake save:i == 0];
        }
        
        self.state = MessageSendingStateSent;
        
          
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateError;
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];

}

-(int)senderFlags {
    
    if(self.fakes.count > 0) {
        
        TL_localMessage *msg = [self.fakes firstObject];
        
        int flags = 0;
        
        flags|=msg.from_id == 0 ? 1 << 4 : 0;
        
        return flags;
        
    } else
        return [super senderFlags];
    
}

-(void)updateMessageId:(TLUpdates *)updates {
    
}

@end
