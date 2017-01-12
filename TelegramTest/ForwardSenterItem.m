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

static const int fwdUserFlag = 1 << 31;


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
            
            TLChat *fwdChannel = f.fwd_from.channel_id != 0 ? [[ChatsManager sharedManager] find:f.fwd_from.channel_id] : nil;
            
            if(fwdChannel.isMegagroup)
                fwdChannel = nil;
            
            
            TL_localMessageFwdHeader *fwdHeader = [TL_localMessageFwdHeader createWithFlags:![f.to_id isKindOfClass:[TL_peerChannel class]] && fwdChannel ? fwdUserFlag : 0 from_id:f.fwd_from ? f.fwd_from.from_id : f.from_id date:f.date channel_id:fwdChannel ? fwdChannel.n_id  : [f.to_id isKindOfClass:[TL_peerChannel class]] ? f.to_id.channel_id : 0 channel_post:[f.to_id isKindOfClass:[TL_peerChannel class]] && !f.chat.isMegagroup ? f.n_id : 0 channel_original_id:fwdChannel && [f.to_id isKindOfClass:[TL_peerChannel class]] ? f.to_id.channel_id : 0];
            
            
            TL_localMessage *fake = [TL_localMessage createWithN_id:[MessageSender getFakeMessageId] flags:TGOUTUNREADMESSAGE | TGFWDMESSAGE | TGREADEDCONTENT from_id:[UsersManager currentUserId] to_id:conversation.peer fwd_from:fwdHeader reply_to_msg_id:0 date:[[MTNetwork instance] getTime] message:f.message media:f.media fakeId:f.n_id randomId:random reply_markup:nil entities:f.entities views:f.views via_bot_id:f.via_bot_id edit_date:0 isViewed:NO state:DeliveryStatePending];
            
            
            if (f.reply_markup != nil) {
                
                
                  __block TLKeyboardButton *game = nil;
                
                [f.reply_markup.rows enumerateObjectsUsingBlock:^(TLKeyboardButtonRow *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj.buttons enumerateObjectsUsingBlock:^(TLKeyboardButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if([btn isKindOfClass:[TL_keyboardButtonGame class]]) {
                            game = btn;
                            *stop = YES;
                        }
                        
                    }];
                }];
                
                if(game) {
                    fake.reply_markup = f.reply_markup;
                }
            }
            
            
            if(additionFlags & (1 << 4) || f.isPost & (1 << 4))
                fake.flags|= (1 << 14);
            
            if(conversation.needRemoveFromIdBeforeSend) {
                fake.from_id = 0;
            }

             
            [fake save:i == copy.count-1];
            
            [fakes insertObject:fake atIndex:0];
            
        }
        
        
        self.msg_ids = ids;
        
        self.fakes = fakes;
        
    }
    
    return self;
}


-(void)setFakes:(NSArray *)fakes {
    [fakes enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self setMessage:obj];
    }];
    
    [self setMessage:nil];
    
    _fakes = fakes;
}


-(void)setMsg_ids:(NSArray *)msg_ids {
    _msg_ids = msg_ids;
}

-(void)performRequest {

    if(self.fakes.count == 0) {
        self.state = MessageSendingStateSent;
        return;
    }
    
    NSMutableArray *random_ids = [[NSMutableArray alloc] init];
    
    [self.fakes enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [random_ids addObject:@(obj.randomId)];
    }];
    
    TL_localMessage*msg = [self.fakes firstObject];
    
    TLUser *user = msg.fwd_from.from_id != 0 ? [[UsersManager sharedManager] find:msg.fwd_from.from_id] : nil;
    TLChat *chat =msg.fwd_from.channel_original_id != 0 ? [[ChatsManager sharedManager] find:msg.fwd_from.channel_original_id] :  msg.fwd_from.channel_id != 0 ? [[ChatsManager sharedManager] find:msg.fwd_from.channel_id] : nil;
    
    __block TLInputPeer *peer = msg.fwd_from.channel_id == 0 || msg.fwd_from.flags & fwdUserFlag ? [TL_inputPeerUser createWithUser_id:user.n_id access_hash:user.access_hash] : [TL_inputPeerChannel createWithChannel_id:chat.n_id access_hash:chat.access_hash];
    
    TLAPI_messages_forwardMessages *request = [TLAPI_messages_forwardMessages createWithFlags:[self senderFlags] from_peer:peer n_id:[self.msg_ids mutableCopy] random_id:random_ids to_peer:self.conversation.inputPeer];
    
    weak();
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates *response) {
        
        
        strongWeak();
        
        if(strongSelf != nil) {
            if(response.updates.count < 2)
            {
                [strongSelf cancel];
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
                
                fake.message = stated.message;
                fake.entities = stated.entities;
                fake.date = stated.date;
                fake.n_id = stated.n_id;
                fake.reply_markup = stated.reply_markup;
                fake.dstate = DeliveryStateNormal;
                
                [fake save:i == 0];
            }
            
            strongSelf.state = MessageSendingStateSent;
        }
        
      
        
          
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        weakSelf.state = MessageSendingStateError;
    } timeout:0 queue:[ASQueue globalQueue]._dispatch_queue];

}

-(int)senderFlags {
    
    if(self.fakes.count > 0) {
        
        TL_localMessage *msg = [self.fakes firstObject];
        
        int flags = 0;
        
        flags|=msg.isPost ? 1 << 4 : 0;
        
        if(self.fakes.count == 1 && msg.reply_markup != nil) {
            
            flags|=(1 << 8);
           
            __block TLKeyboardButton *game = nil;
            
            [msg.reply_markup.rows enumerateObjectsUsingBlock:^(TLKeyboardButtonRow *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj.buttons enumerateObjectsUsingBlock:^(TLKeyboardButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if([btn isKindOfClass:[TL_keyboardButtonGame class]]) {
                        game = btn;
                        *stop = YES;
                    }
                    
                }];
            }];
            
            if(game) {
                
            }
        }
        
        return flags;
        
    } else
        return [super senderFlags];
    
}

-(void)updateMessageId:(TLUpdates *)updates {
    
}

@end
