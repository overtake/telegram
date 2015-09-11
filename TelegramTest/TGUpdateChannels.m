//
//  TGUpdateChannels.m
//  Telegram
//
//  Created by keepcoder on 20.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGUpdateChannels.h"
#import "TGUpdateChannelContainer.h"
#import "TGTimer.h"
@interface TGUpdateChannels ()
@property (nonatomic,strong) ASQueue *queue;
@property (nonatomic,strong) NSMutableDictionary *channelWaitingUpdates;
@property (nonatomic,strong) NSMutableDictionary *channelWaitingTimers;

@end

@implementation TGUpdateChannels

-(id)initWithQueue:(ASQueue *)queue {
    if(self = [super init]) {
        _queue = queue;
        _channelWaitingUpdates = [[NSMutableDictionary alloc] init];
        _channelWaitingTimers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(int)ptsWithChannelId:(int)channel_id {
    
    return MAX([[[DialogsManager sharedManager] find:-channel_id] pts],1);
}

-(TL_conversation *)conversationWithChannelId:(int)channel_id {
    
    TL_conversation *conversation = [[DialogsManager sharedManager] find:-channel_id];
    
    if(!conversation) {
        conversation = [[Storage manager] selectConversation:[TL_peerChannel createWithChannel_id:channel_id]];
        
        assert(conversation != nil);
        
        [[DialogsManager sharedManager] add:@[conversation]];
    }
    
    
    return conversation;
    
}



-(int)channelIdWithUpdate:(id)update {
    
    if([update isKindOfClass:[TL_updateNewChannelMessage class]]) {
        return ((TL_updateNewChannelMessage *)update).message.to_id.channel_id;
    } else if([update isKindOfClass:[TL_updateChannelPts class]]) {
        return [(TL_updateChannelPts *)update channel_id];
    } else if([update isKindOfClass:[TL_updateDeleteChannelMessages class]]) {
        return [[(TL_updateDeleteChannelMessages *)update peer] channel_id];

    }
    
    return 0;
}

/*
 updateNewChannelMessage message:Message pts:int pts_count:int = Update;
 updateReadChannelInbox peer:Peer max_id:int = Update;
 */

-(void)addUpdate:(id)update {
    
    [_queue dispatchOnQueue:^{
        
        
        static NSArray *statefullUpdates;
        static NSArray *statelessUpdates;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            statefullUpdates = @[NSStringFromClass([TL_updateNewChannelMessage class]),NSStringFromClass([TL_updateDeleteChannelMessages class]),NSStringFromClass([TL_updateChannelPts class])];
            statelessUpdates = @[NSStringFromClass([TL_updateReadChannelInbox class]),NSStringFromClass([TL_updateChannelTooLong class]),NSStringFromClass([TL_updateChannelGroup class]),NSStringFromClass([TL_updateChannelMessageViews class])];
        });
        
        if([statefullUpdates indexOfObject:[update className]] != NSNotFound)
        {
            [self addStatefullUpdate:[[TGUpdateChannelContainer alloc] initWithPts:[update pts] pts_count:[update pts_count] channel_id:[self channelIdWithUpdate:update] update:update]];
        }  else if([statelessUpdates indexOfObject:[update className]] != NSNotFound) {
            [self proccessStatelessUpdate:update];
        }
        
        
        
    }];

}

-(void)addStatefullUpdate:(TGUpdateChannelContainer *)statefulMessage {
    
    if(statefulMessage.pts == 0 || [self ptsWithChannelId:statefulMessage.channel_id] + statefulMessage.pts_count == statefulMessage.pts )
    {
        [self proccessStatefullUpdate:statefulMessage];
        
        return;
    }
    
    
    [self addWaitingUpdate:statefulMessage];
    
}


-(void)addWaitingUpdate:(TGUpdateChannelContainer *)statefullMessage {
    
    NSMutableArray *updates = _channelWaitingUpdates[@(statefullMessage.channel_id)];
    
    if(!updates)
    {
        updates = [[NSMutableArray alloc] init];
        _channelWaitingUpdates[@(statefullMessage.channel_id)] = updates;
    }
    
    [updates addObject:statefullMessage];
    
    
    [updates sortUsingComparator:^NSComparisonResult(TGUpdateChannelContainer * obj1, TGUpdateChannelContainer * obj2) {
        return obj1.pts < obj2.pts ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    
    NSMutableArray *success = [[NSMutableArray alloc] init];
    
    [updates enumerateObjectsUsingBlock:^(TGUpdateChannelContainer *statefulMessage, NSUInteger idx, BOOL *stop) {
        
        if(statefulMessage.pts > 0 && [self ptsWithChannelId:statefulMessage.pts] + statefulMessage.pts_count == statefulMessage.pts )
        {
            [success addObject:statefullMessage];
            
            [self proccessStatefullUpdate:statefullMessage];
        }
        
    }];
    

    [updates removeObjectsInArray:success];
    
    if(updates.count > 0) {
        
        TGTimer *timer = _channelWaitingTimers[@(statefullMessage.channel_id)];
        
        if(timer)
        {
            [timer invalidate];
            [_channelWaitingTimers removeObjectForKey:@(statefullMessage.channel_id)];
        }
        
        timer = [[TGTimer alloc] initWithTimeout:2 repeat:NO completion:^{
            
            [self failUpdateWithChannelId:statefullMessage.channel_id limit:100 withCallback:nil];
            
        } queue:_queue.nativeQueue reservedObject:@(statefullMessage.channel_id)];
        
        [timer start];
    }
    
}


-(void)proccessUpdate:(id)update {
    if([update isKindOfClass:[TL_updateNewChannelMessage class]])
    {
        TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[(TL_updateNewChannelMessage *)update message]];
        
        int minId = [[Storage manager] lastSyncedMessageIdWithChannelId:msg.peer_id important:YES];
        
        TGMessageGroupHole *hole = [[[Storage manager] groupHoles:msg.peer_id min:minId max:INT32_MAX] lastObject];
        
        if(hole.max_id != minId) {
            if(![msg isImportantMessage]) {
                
                if(!hole)
                    hole = [[TGMessageGroupHole alloc] initWithUniqueId:-rand_int() peer_id:msg.peer_id min_id:msg.n_id max_id:msg.n_id+1 date:msg.date count:0];
                
                hole.max_id = msg.n_id+1;
                hole.messagesCount++;
                hole.date = msg.date;
                
                [hole save];
                
                [Notification perform:UPDATE_MESSAGE_GROUP_HOLE data:@{KEY_GROUP_HOLE:hole}];
                
            }
        }
        
        
        [MessagesManager addAndUpdateMessage:msg];
        
    } else if( [update isKindOfClass:[TL_updateDeleteChannelMessages class]]) {
        
        NSMutableArray *channelMessages = [NSMutableArray array];
        
        int peer_id = -[[(TL_updateDeleteChannelMessages *)update peer] channel_id];
        
        [[update messages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            
            NSArray *groupHoles = [[Storage manager] groupHoles:peer_id min:[obj intValue] max:[obj intValue]+1];
            
            if(groupHoles.count == 1) {
                TGMessageGroupHole *hole = [groupHoles firstObject];
                
                hole.messagesCount--;
                
                if(hole.messagesCount == 0) {
                    [hole remove];
                } else
                    [hole save];
                
                [Notification perform:UPDATE_MESSAGE_GROUP_HOLE data:@{KEY_GROUP_HOLE:hole}];
            }
            
            [channelMessages addObject:@(channelMsgId([obj intValue], peer_id))];
        }];
        
        [[DialogsManager sharedManager] deleteChannelMessags:channelMessages];
        
    } else if([update isKindOfClass:[TL_updateMessageID class]]) {
        [[Storage manager] updateMessageId:[(TL_updateMessageID *)update random_id] msg_id:[(TL_updateMessageID *)update n_id]];
        [Notification perform:MESSAGE_UPDATE_MESSAGE_ID data:@{KEY_MESSAGE_ID:@([(TL_updateMessageID *)update n_id]),KEY_RANDOM_ID:@([(TL_updateMessageID *)update random_id])}];
    } else if([update isKindOfClass:[TL_updateReadChannelInbox class]]) {
        
    } else if([update isKindOfClass:[TL_updateChannelTooLong class]]) {
        
        [self failUpdateWithChannelId:[update channel_id] limit:100 withCallback:nil];
        
    } else if([update isKindOfClass:[TL_updateChannelMessageViews class]]) {
        
        int bp = 0;
        
    }

}


-(void)proccessStatefullUpdate:(TGUpdateChannelContainer *)statefulMessage {
    
    [self proccessUpdate:statefulMessage.update];
    
    if(statefulMessage.pts > 0) {
        TL_conversation *conversation = [self conversationWithChannelId:statefulMessage.channel_id];
        
        conversation.pts = [statefulMessage pts];
        
        [conversation save];
    }
    
}


-(void)proccessStatelessUpdate:(id)update {
    
    [self proccessUpdate:update];
    
}


-(void)failUpdateWithChannelId:(int)channel_id limit:(int)limit withCallback:(void (^)(id response, TGMessageHole *longHole))callback
{
    TL_channel *channel = [[ChatsManager sharedManager] find:channel_id];
    
    assert(channel_id != 0);
    
    [RPCRequest sendRequest:[TLAPI_updates_getChannelDifference createWithPeer:[TL_inputPeerChannel createWithChannel_id:channel_id access_hash:channel.access_hash] filter:[TL_channelMessagesFilterEmpty create] pts:[self ptsWithChannelId:channel_id] limit:limit] successHandler:^(id request, id response) {
        
        
        TGMessageHole *longHole;
        
        TL_conversation *conversation = [self conversationWithChannelId:channel_id];
        
        if([response isKindOfClass:[TL_updates_channelDifferenceEmpty class]]) {
            
            
        } else if([response isKindOfClass:[TL_updates_channelDifference class]]) {
            
            
            [[response other_updates] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                [self proccessUpdate:obj];
                
            }];
            
            conversation.pts = [(TL_updates_channelDifference *)response pts];
            
            [conversation save];
            
            [TL_localMessage convertReceivedMessages:[response n_messages]];
            
            [[Storage manager] insertMessages:[response n_messages]];
            
            [Notification perform:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:[response n_messages]}];
            
            
        } else if([response isKindOfClass:[TL_updates_channelDifferenceTooLong class]]) {
            
            
            __block TL_localMessage *topMsg;
            __block TL_localMessage *minMsg;
            
            [[response messages] enumerateObjectsUsingBlock:^(TLMessage *obj, NSUInteger idx, BOOL *stop) {
                
                TL_localMessage *c = [TL_localMessage convertReceivedMessage:obj];
                
                if([response top_message] == c.n_id)
                    topMsg = c;
                
                if(!minMsg || c.n_id < minMsg.n_id)
                    minMsg = c;
                
            }];
            
            [[Storage manager] invalidateChannelMessagesWithPts:conversation.pts];
            
            conversation.pts = [response pts];
            
            conversation.top_message = [response top_message];
            conversation.lastMessage = topMsg;
            conversation.read_inbox_max_id = [response read_inbox_max_id];
            conversation.unread_count = [response unread_count];
            
            [conversation save];
            
            [[DialogsManager sharedManager] notifyAfterUpdateConversation:conversation];
            
            
            
            
           
            
            // insert holes
            {
                if(minMsg.n_id != topMsg.n_id) {
                    TGMessageHole *hole = [[TGMessageHole alloc] initWithUniqueId:-rand_int() peer_id:minMsg.peer_id min_id:minMsg.n_id max_id:topMsg.n_id date:minMsg.date count:0];
                    
                    [[Storage manager] insertMessagesHole:hole];
                }
                
                int maxSyncedId = [[Storage manager] lastSyncedMessageIdWithChannelId:conversation.peer_id important:NO];
                
                longHole = [[TGMessageHole alloc] initWithUniqueId:-rand_int() peer_id:topMsg.peer_id min_id:maxSyncedId max_id:minMsg.n_id date:minMsg.date count:0];
                
                [[Storage manager] insertMessagesHole:longHole];
                
            }
            
            [SharedManager proccessGlobalResponse:response];
        }
        
        
        if(callback != nil)
        {
            callback(response,longHole);
        }
        
        
    } errorHandler:^(id request, RpcError *error) {
        

    } timeout:0 queue:_queue.nativeQueue];
}




@end
