//
//  TGModernConversationHistoryController.m
//  Telegram
//
//  Created by keepcoder on 24.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGModernConversationHistoryController.h"
#import "TGObservableObject.h"

#import "TLPeer+Extensions.h"

@interface TGModernConversationHistoryController ()
@property (nonatomic,strong) ASQueue *queue;
@property (nonatomic,weak) id<TGModernConversationHistoryControllerDelegate> delegate;
@property (nonatomic,assign) BOOL loadNextAfterLoadChannels;
@property (nonatomic,assign) int channelsOffset;

@property (nonatomic,assign) BOOL needMergeChannels;

@end

@implementation TGModernConversationHistoryController


-(id)initWithQueue:(ASQueue *)queue delegate:(id<TGModernConversationHistoryControllerDelegate>)delegate {
    
    if(self = [super init]) {
        _queue = queue;
        _delegate = delegate;
        _state = TGModernCHStateLocal;
    }
    
    return self;
}




-(void)requestNextConversation {
    
    [_queue dispatchOnQueue:^{
        
        if(_isLoading)
            return;
        
        _isLoading = YES;
        
        [self performLoadNext];
        
    }];
    

}

-(void)performLoadNext {
    
    if(_state == TGModernCHStateLocal)
    {
        
        [[Storage manager] dialogsWithOffset:_offset limit:[self.delegate conversationsLoadingLimit] completeHandler:^(NSArray *d) {
            
            [[DialogsManager sharedManager] add:d];
            
             [_queue dispatchOnQueue:^{
                 
                if(d.count < [self.delegate conversationsLoadingLimit]) {
                    
                    _state = TGModernCHStateRemote;
                    
                    [self performLoadNext];
                    
                }
                 
                
                [self dispatchWithFullList:[self mixChannelsWithConversations:d] offset:(int)d.count];
                
            }];
            
            
        }];
    }  else if(_state == TGModernCHStateRemote) {
        
        NSArray *all = [[DialogsManager sharedManager] all];
        
        BOOL fullResort = [[all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type != 2"]] count] == 0;
        
        __block TL_conversation *conversation;
        
        [all enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(obj.type != DialogTypeSecretChat && obj.lastMessage && obj.lastMessage.n_id < TGMINFAKEID && !obj.fake && !obj.isInvisibleChannel) {
                conversation = obj;
                *stop = YES;
            }
            
        }];
        
        id inputPeer = conversation ? conversation.inputPeer : [TL_inputPeerEmpty create];
        int date = conversation.lastMessage.date;
        
        const int limit = 50;
        
        [RPCRequest sendRequest:[TLAPI_messages_getDialogs createWithOffset_date:date offset_id:conversation.lastMessage.n_id offset_peer:inputPeer limit:limit] successHandler:^(id request, TL_messages_dialogs *response) {
            
            
            
            
            [SharedManager proccessGlobalResponse:response];
            
            
            NSMutableArray *converted = [[NSMutableArray alloc] init];
            
           
            [response.dialogs enumerateObjectsUsingBlock:^(TL_dialog *dialog, NSUInteger idx, BOOL *stop) {
                
                TL_localMessage *lastMessage = [[response.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %d",dialog.top_message]] firstObject];
                
                
                TLChat *chat = [[response.chats filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %d",-dialog.peer.peer_id]] firstObject];
                
                TL_conversation *conversation;
                
                
                
                if([dialog.peer isKindOfClass:[TL_peerChannel class]]) {
                    NSArray *f = [response.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.peer_id == %d", dialog.peer.peer_id]];
                    
                    __block TL_localMessage *topMsg;
                    __block TL_localMessage *minMsg;
                    
                    [f enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
                        
                        if(dialog.top_message == obj.n_id)
                            topMsg = obj;
                        
                        if(!minMsg || obj.n_id < minMsg.n_id)
                            minMsg = obj;
                        
                    }];
                    
                    
                    
                    if(f.count == 2) {
                        
                        if(minMsg.n_id != topMsg.n_id) {
                            TGMessageHole *hole = [[TGMessageHole alloc] initWithUniqueId:-rand_int() peer_id:minMsg.peer_id min_id:minMsg.n_id max_id:topMsg.n_id date:minMsg.date count:0];
                            
                            [[Storage manager] insertMessagesHole:hole];
                        }
                        
                        // need create group hole
                        
                        if(!chat.isMegagroup) {
                            TGMessageGroupHole *groupHole = [[TGMessageGroupHole alloc] initWithUniqueId:-rand_int() peer_id:topMsg.peer_id min_id:minMsg.n_id max_id:topMsg.n_id+1 date:topMsg.date count:0];
                            
                            [[Storage manager] insertMessagesHole:groupHole];
                        }
                        
                    }
                    
                    int top_important_message = chat.isMegagroup ? topMsg.n_id : minMsg.n_id;
                    
                    int date = chat.isMegagroup ? topMsg.date : minMsg.date;
                    
                    lastMessage = chat.isMegagroup ? topMsg : minMsg;
                    
                    conversation = [TL_conversation createWithPeer:dialog.peer top_message:dialog.top_message unread_count:dialog.unread_important_count last_message_date:date notify_settings:dialog.notify_settings last_marked_message:top_important_message top_message_fake:top_important_message last_marked_date:minMsg.date sync_message_id:topMsg.n_id read_inbox_max_id:dialog.read_inbox_max_id unread_important_count:dialog.unread_important_count lastMessage:lastMessage pts:dialog.pts isInvisibleChannel:NO top_important_message:top_important_message];
                } else {
                    conversation = [TL_conversation createWithPeer:dialog.peer top_message:dialog.top_message unread_count:chat.migrated_to.channel_id != 0 ? 0 : dialog.unread_count last_message_date:lastMessage.date notify_settings:dialog.notify_settings last_marked_message:dialog.top_message top_message_fake:dialog.top_message last_marked_date:lastMessage.date sync_message_id:lastMessage.n_id read_inbox_max_id:dialog.read_inbox_max_id unread_important_count:dialog.unread_important_count lastMessage:lastMessage pts:dialog.pts isInvisibleChannel:NO top_important_message:dialog.top_important_message];
                }
                
                
                [converted addObject:conversation];
                
            }];
            
            [[DialogsManager sharedManager] add:converted];
            [[Storage manager] insertDialogs:converted];
            
//            NSArray *all = [[DialogsManager sharedManager] all];
//            
//            if(all.count > 0) {
//                NSArray *res =all;//[all subarrayWithRange:NSMakeRange(150, 10)];
//                
//                [res enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    if(obj.chat)
//                        NSLog(@"chatTitle:%@ username:%@ peer_id:%d date:%d",obj.chat.title,obj.chat.username,obj.peer_id,obj.lastMessage.date);
//                    else
//                        NSLog(@"userTitle:%@ username:%@ peer_id:%d date:%d",obj.user.fullName,obj.user.username,obj.peer_id,obj.lastMessage.date);
//                    
//                }];
//                
//                int bp = 0;
//            }
            
            [MessagesManager updateUnreadBadge];
            
            if(converted.count < limit) {
                _state = TGModernCHStateFull;

            }
            
            
            
            [self dispatchWithFullList:converted offset:(int)converted.count];
            
            if(fullResort)
                [Notification perform:DIALOGS_NEED_FULL_RESORT data:@{}];
            
        } errorHandler:^(id request, RpcError *error) {
            
            
            int bp = 0;
            
        } timeout:0 queue:_queue.nativeQueue];
        
    }

}

- (NSArray *)mixChannelsWithConversations:(NSArray *)conversations {
    
    NSArray *join = conversations;
    
    return [join sortedArrayUsingComparator:^NSComparisonResult(TL_conversation * obj1, TL_conversation * obj2) {
        return (obj1.last_real_message_date < obj2.last_real_message_date ? NSOrderedDescending : (obj1.last_real_message_date > obj2.last_real_message_date ? NSOrderedAscending : (obj1.top_message < obj2.top_message ? NSOrderedDescending : NSOrderedAscending)));
    }];
    
}

-(void)dispatchWithFullList:(NSArray *)all offset:(int)offset {
    
    [_delegate didLoadedConversations:all withRange:NSMakeRange(_offset, all.count)];
    
    _offset+= offset;
//    _remoteOffset+= [[all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type == 0 OR self.type == 1"]] count];
//    _localOffset+= [[all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type == 0 OR self.type == 1 OR self.type == 2 OR self.type == 3"]] count];
    _isLoading = NO;

}

-(void)clear {
    _offset = 0;
    _localOffset = 0;
    _remoteOffset = 0;
    _isLoading = NO;
    _delegate = nil;
}


@end
