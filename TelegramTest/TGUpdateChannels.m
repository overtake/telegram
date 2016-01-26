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
#import "TGForceChannelUpdate.h"
#import "TLPeer+Extensions.h"



@interface TGUpdateChannels ()
@property (nonatomic,strong) ASQueue *queue;
@property (nonatomic,strong) NSMutableDictionary *channelWaitingUpdates;
@property (nonatomic,strong) NSMutableDictionary *channelWaitingTimers;

@property (nonatomic,strong) NSMutableDictionary *channelsInUpdating;


@end

@implementation TGUpdateChannels

-(id)initWithQueue:(ASQueue *)queue {
    if(self = [super init]) {
        _queue = queue;
        _channelWaitingUpdates = [[NSMutableDictionary alloc] init];
        _channelWaitingTimers = [[NSMutableDictionary alloc] init];
        _channelsInUpdating = [[NSMutableDictionary alloc] init];
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
        
        if(conversation) {
            [[DialogsManager sharedManager] add:@[conversation]];
        }
                
        
    }
    
    
    return conversation;
    
}



-(int)channelIdWithUpdate:(id)update {
    
    if([update isKindOfClass:[TL_updateNewChannelMessage class]]) {
        return ((TL_updateNewChannelMessage *)update).message.to_id.channel_id;
    }  else if([update isKindOfClass:[TL_updateDeleteChannelMessages class]]) {
        return [(TL_updateDeleteChannelMessages *)update channel_id];
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
            
            statefullUpdates = @[NSStringFromClass([TL_updateNewChannelMessage class]),NSStringFromClass([TL_updateDeleteChannelMessages class])];
            statelessUpdates = @[NSStringFromClass([TL_updateReadChannelInbox class]),NSStringFromClass([TL_updateChannelTooLong class]),NSStringFromClass([TL_updateChannelGroup class]),NSStringFromClass([TL_updateChannelMessageViews class]),NSStringFromClass([TL_updateChannel class])];
        });
        
        if([statefullUpdates indexOfObject:[update className]] != NSNotFound)
        {
            
            if(_channelsInUpdating[@([self channelIdWithUpdate:update])] == nil) {
                [self addStatefullUpdate:[[TGUpdateChannelContainer alloc] initWithPts:[update pts] pts_count:[update pts_count] channel_id:[self channelIdWithUpdate:update] update:update]];
            }
            
            
        }  else if([statelessUpdates indexOfObject:[update className]] != NSNotFound) {
            [self proccessStatelessUpdate:update];
        } else if([update isKindOfClass:[TGForceChannelUpdate class]]) {
            [self proccessUpdate:[(TGForceChannelUpdate *)update update]];
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
            
            [self failUpdateWithChannelId:statefullMessage.channel_id limit:50 withCallback:nil errorCallback:nil];
            
        } queue:_queue.nativeQueue reservedObject:@(statefullMessage.channel_id)];
        
        [timer start];
    }
    
}


-(TGMessageGroupHole *)proccessUnimportantGroup:(NSArray *)messages {
    
    TL_localMessage *minMsg = [[Storage manager] lastMessageAroundMinId:[(TL_localMessage *)messages[0] channelMsgId] important:YES isTop:NO];
    
    TL_localMessage *minUnimportantMsg = [messages firstObject];
    TL_localMessage *maxUnimportantMsg = [messages lastObject];
    
    
    int minId = minMsg ? minMsg.n_id : minUnimportantMsg.n_id - 1;
    
    TGMessageGroupHole *hole = [[[Storage manager] groupHoles:minUnimportantMsg.peer_id min:minId max:maxUnimportantMsg.n_id +1] lastObject];
    
    if(hole == nil)
        hole = [[TGMessageGroupHole alloc] initWithUniqueId:-rand_int() peer_id:minUnimportantMsg.peer_id min_id:minId max_id:maxUnimportantMsg.n_id+1 date:minUnimportantMsg.date-1  count:0];
    
    hole.max_id = maxUnimportantMsg.n_id+1;
    hole.messagesCount+= (int)messages.count;
    
    [hole save];
    
    [[Storage manager] insertMessages:messages];
    
    return hole;

}


-(void)proccessHoleWithNewMessage:(NSArray *)messages {
    
    messages = [messages sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self.n_id" ascending:YES]]];
    
    NSMutableArray *unimporantMessages = [[NSMutableArray alloc] init];
    
    
    
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
        
        if(![obj isImportantMessage])
            [unimporantMessages addObject:obj];
        
        if([obj isImportantMessage] || idx == messages.count-1) {
            
            if([obj isImportantMessage]) {
                [obj save:NO];
            }
            
            if(unimporantMessages.count > 0) {
                TGMessageGroupHole *hole = [self proccessUnimportantGroup:[unimporantMessages copy]];
                [groups addObject:hole];
                [unimporantMessages removeAllObjects];
            }
           
        }
    }];
    
    [Notification performOnStageQueue:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:messages}];
    
    [groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         [Notification perform:UPDATE_MESSAGE_GROUP_HOLE data:@{KEY_GROUP_HOLE:obj}];
    }];
    
}

-(void)proccessUpdate:(id)update {
    if([update isKindOfClass:[TL_updateNewChannelMessage class]])
    {
        
        TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[(TL_updateNewChannelMessage *)update message]];
        
        if(![self conversationWithChannelId:abs(msg.peer_id)]) {
            [self proccessUpdate:[TL_updateChannel createWithChannel_id:abs(msg.peer_id)]];
            return;
        }
        

        if(![msg isImportantMessage]) {
            
            TGMessageGroupHole *hole = [self proccessUnimportantGroup:@[msg]];
            
            [Notification perform:UPDATE_MESSAGE_GROUP_HOLE data:@{KEY_GROUP_HOLE:hole}];
            
        }
        
        
        [MessagesManager addAndUpdateMessage:msg];
        
    } else if( [update isKindOfClass:[TL_updateDeleteChannelMessages class]]) {
        
        NSMutableArray *channelMessages = [NSMutableArray array];
        
        int peer_id = -[(TL_updateDeleteChannelMessages *)update channel_id];
    
        
        [[update messages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [channelMessages addObject:@(channelMsgId([obj intValue], peer_id))];
        }];
        
        
        [[DialogsManager sharedManager] deleteChannelMessags:channelMessages];

        
        [[update messages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            
            TL_localMessage *topMsg = [[Storage manager] lastMessageAroundMinId:channelMsgId([obj intValue], peer_id) important:YES isTop:NO];
            
            TL_localMessage *botMsg = [[Storage manager] lastMessageAroundMinId:channelMsgId([obj intValue], peer_id) important:YES isTop:YES];
            
            int topMsgId = topMsg ? topMsg.n_id : [obj intValue]-1;
            int botMsgId = botMsg ? botMsg.n_id : [obj intValue]+1;
            
            NSArray *groupHoles = [[Storage manager] groupHoles:peer_id min:topMsgId max:botMsgId];
            
            if(groupHoles.count == 1) {
        
                TGMessageGroupHole *hole = [groupHoles firstObject];
                
                if(hole.max_id > [obj intValue] && hole.min_id < [obj intValue])
                     hole.messagesCount--;
                else {
                    hole.min_id = topMsg.n_id;
                }
                
                if(hole.messagesCount == 0)
                    [hole remove];
                else
                    [hole save];
                
                [Notification perform:UPDATE_MESSAGE_GROUP_HOLE data:@{KEY_GROUP_HOLE:hole}];

            } else if(groupHoles.count == 2) {
                
                TGMessageGroupHole *topHole = groupHoles[0];
                TGMessageGroupHole *botHole = groupHoles[1];
                
                [botHole remove];
                
                
                topHole.max_id = botHole.max_id;
                topHole.messagesCount += botHole.messagesCount;
                [topHole save];
                
                [Notification perform:UPDATE_MESSAGE_GROUP_HOLE data:@{KEY_GROUP_HOLE:topHole}];
                [Notification performOnStageQueue:MESSAGE_DELETE_EVENT data:@{KEY_DATA:@[@{KEY_PEER_ID:@(botHole.peer_id),KEY_MESSAGE_ID:@(botHole.uniqueId)}]}];
                
            }
            
        }];
        
        
    } else if([update isKindOfClass:[TL_updateMessageID class]]) {
        [[Storage manager] updateMessageId:[(TL_updateMessageID *)update random_id] msg_id:[(TL_updateMessageID *)update n_id]];
        [Notification performOnStageQueue:MESSAGE_UPDATE_MESSAGE_ID data:@{KEY_MESSAGE_ID:@([(TL_updateMessageID *)update n_id]),KEY_RANDOM_ID:@([(TL_updateMessageID *)update random_id])}];
    } else if([update isKindOfClass:[TL_updateReadChannelInbox class]]) {
        
        [[DialogsManager sharedManager] markChannelMessagesAsRead:[update channel_id] max_id:[(TL_updateReadChannelInbox *)update max_id]];
        
    } else if([update isKindOfClass:[TL_updateChannelTooLong class]]) {
        
        [self failUpdateWithChannelId:[update channel_id] limit:50 withCallback:nil errorCallback:nil];
        
        
    } else if([update isKindOfClass:[TL_updateChannelMessageViews class]]) {
        
        TL_updateChannelMessageViews *views = (TL_updateChannelMessageViews *)update;
        
        [[Storage manager] updateMessageViews:views.views channelMsgId:channelMsgId(views.n_id, views.peer.peer_id)];
        
        [Notification perform:UPDATE_MESSAGE_VIEWS data:@{KEY_DATA:@{@(views.n_id):@(views.views)},KEY_MESSAGE_ID_LIST:@[@(views.n_id)],KEY_PEER_ID:@(-views.channel_id)}];
        
    } else if([update isKindOfClass:[TL_updateMessageID class]]) {
        [[MTNetwork instance].updateService.proccessor addUpdate:update];
    } else if([update isKindOfClass:[TL_updateChannel class]]) {
        
        //TODO
        // update channel interface.
        
        
        TLChat *chat = [[ChatsManager sharedManager] find:[update channel_id]];
        
        
        if(!chat)
            return;
        
        TL_conversation *channel = [self conversationWithChannelId:[update channel_id]];
        
        BOOL addInviteMessage = channel == nil;
        
        
        if(!channel) {
            channel = [[DialogsManager sharedManager] createDialogForChannel:chat];
            
            [[DialogsManager sharedManager] add:@[channel]];
            
            channel.invisibleChannel = NO;
            [channel save];
            
        }
        
        
        dispatch_block_t dispatch = ^{
            if(!chat.left && chat.type != TLChatTypeForbidden) {
                
                [[FullChatManager sharedManager] performLoad:chat.n_id callback:^(TLChatFull *fullChat) {
                   
                    if(fullChat.migrated_from_chat_id == 0) {
                        [RPCRequest sendRequest:[TLAPI_channels_getParticipant createWithChannel:chat.inputPeer user_id:[[UsersManager currentUser] inputUser]] successHandler:^(id request, TL_channels_channelParticipant *participant) {
                            
                            [SharedManager proccessGlobalResponse:participant];
                            
                            if([participant.participant isKindOfClass:[TL_channelParticipantSelf class]]) {
                                TL_localMessage *msg = [TL_localMessageService createWithFlags:TGMENTIONMESSAGE n_id:0 from_id:[participant.participant inviter_id] to_id:channel.peer date:participant.participant.date action:([TL_messageActionChatAddUser createWithUsers:[@[@([UsersManager currentUserId])] mutableCopy]]) fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
                                
                                channel.invisibleChannel = NO;
                                
                                [channel save];
                                [MessagesManager addAndUpdateMessage:msg];
                                
                            }
                            
                            
                        } errorHandler:^(id request, RpcError *error) {
                            
                            [self failUpdateWithChannelId:[update channel_id] limit:50 withCallback:nil errorCallback:nil];
                            
                        }];

                    } else {
                        
                        [self failUpdateWithChannelId:[update channel_id] limit:50 withCallback:nil errorCallback:nil];
                    }
                
                }];
                
            }
            
        };
        
        if(addInviteMessage) {
            
            _channelsInUpdating[@(channel.peer_id)] = [RPCRequest sendRequest:[TLAPI_updates_getChannelDifference createWithChannel:chat.inputPeer filter:[TL_channelMessagesFilterEmpty create] pts:1 limit:INT32_MAX] successHandler:^(id request, TL_updates_channelDifference *response) {
                
                channel.pts = response.pts;
                channel.top_important_message = [response top_important_message];
                channel.last_message_date = channel.lastMessage.date;
                
                channel.last_marked_message = [response top_message];
                channel.last_marked_date = [[MTNetwork instance] getTime];
                
                channel.read_inbox_max_id = [response read_inbox_max_id];
                channel.unread_count = [response unread_important_count];
                
                if(!chat.isCreator)
                    dispatch();
                else
                {
                    [TL_localMessage convertReceivedMessages:[response n_messages]];
                    
                    [self proccessHoleWithNewMessage:[response n_messages]];
                }
                
                [_channelsInUpdating removeObjectForKey:@(channel.peer_id)];
                
                [[DialogsManager sharedManager] notifyAfterUpdateConversation:channel];
                
            } errorHandler:^(id request, RpcError *error) {
                
                [_channelsInUpdating removeObjectForKey:@(channel.peer_id)];
            }];
        }
    
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


-(void)failUpdateWithChannelId:(int)channel_id limit:(int)limit withCallback:(void (^)(id response, TGMessageHole *longHole))callback errorCallback:(void (^)(RpcError *error))errorCallback
{
    TL_channel *channel = [[ChatsManager sharedManager] find:channel_id];
    
    TL_conversation *conversation = [self conversationWithChannelId:channel_id];
    
    if(conversation) {
        id request = _channelsInUpdating[@(channel_id)];
        
        
        if(request == nil) {
            _channelsInUpdating[@(channel_id)] = [RPCRequest sendRequest:[TLAPI_updates_getChannelDifference createWithChannel:[TL_inputChannel createWithChannel_id:channel_id access_hash:channel.access_hash] filter:[TL_channelMessagesFilterEmpty create] pts:[self ptsWithChannelId:channel_id] limit:limit] successHandler:^(id request, id response) {
                
                
                TGMessageHole *longHole;
                
                
                if([response isKindOfClass:[TL_updates_channelDifferenceEmpty class]]) {
                    
                    
                } else if([response isKindOfClass:[TL_updates_channelDifference class]]) {
                    
                    if(conversation.pts < [response pts]) {
                        
                        [[response other_updates] enumerateObjectsUsingBlock:^(TLUpdate *obj, NSUInteger idx, BOOL *stop) {
                            
                            obj.channel_id = channel_id;
                            
                            [self proccessUpdate:obj];
                            
                        }];
                        
                        conversation.pts = [response pts];
                        
                        [conversation save];
                        
                        [TL_localMessage convertReceivedMessages:[response n_messages]];
                        
                        [self proccessHoleWithNewMessage:[response n_messages]];
                    }
                    
                    
                } else if([response isKindOfClass:[TL_updates_channelDifferenceTooLong class]]) {
                    
                    if(conversation.pts < [response pts]) {
                        __block TL_localMessage *topMsg;
                        __block TL_localMessage *importantMsg;
                        
                        [[response messages] enumerateObjectsUsingBlock:^(TLMessage *obj, NSUInteger idx, BOOL *stop) {
                            
                            TL_localMessage *c = [TL_localMessage convertReceivedMessage:obj];
                            
                            if([response top_message] == c.n_id)
                                topMsg = c;
                            
                            if(!importantMsg || c.n_id < importantMsg.n_id)
                                importantMsg = c;
                            
                        }];
                        
                        [[Storage manager] invalidateChannelMessagesWithPts:conversation.pts];
                        
                        conversation.pts = [response pts];
                        
                        conversation.top_message = [response top_message];
                        conversation.lastMessage = importantMsg;
                        conversation.top_important_message = conversation.chat.isMegagroup ? [response top_message] : [response top_important_message];
                        conversation.last_message_date = conversation.lastMessage.date;
                        
                        if(conversation.last_marked_message == 0) {
                            conversation.last_marked_message =  conversation.chat.isMegagroup ? [response top_message] : [response top_important_message];
                            conversation.last_marked_date = conversation.last_message_date;
                        }
                        
                        conversation.read_inbox_max_id = [response read_inbox_max_id];
                        conversation.unread_count = conversation.chat.isMegagroup ? [response unread_count] : [response unread_important_count];
                        
                        [conversation save];
                        
                        [[DialogsManager sharedManager] add:@[conversation]];
                        
                        [[DialogsManager sharedManager] notifyAfterUpdateConversation:conversation];
                        
                        
                        
                        
                        
                        
                        // insert holes
                        {
                            int maxSyncedId = [[Storage manager] syncedMessageIdWithPeerId:conversation.peer_id important:NO latest:YES isChannel:YES];
                            
                            if(importantMsg.n_id > maxSyncedId && maxSyncedId > 0) {
                                longHole = [[TGMessageHole alloc] initWithUniqueId:-rand_int() peer_id:importantMsg.peer_id min_id:maxSyncedId+1 max_id:importantMsg.n_id-1 date:0 count:0];
                                
                                [longHole save];
                            }
                            
                            
                            if(importantMsg.n_id != topMsg.n_id) {
                                TGMessageHole *nextHole = [[TGMessageHole alloc] initWithUniqueId:-rand_int() peer_id:importantMsg.peer_id min_id:importantMsg.n_id max_id:topMsg.n_id+1 date:0 count:0];
                                
                                [nextHole save];
                                
                                if(longHole == nil)
                                    longHole = nextHole;
                            }
                            
                        }
                    }
                    
                    
                    
                    [SharedManager proccessGlobalResponse:response];
                }
                
                
                if(callback != nil)
                {
                    callback(response,longHole);
                }
                
                
                [_channelsInUpdating removeObjectForKey:@(channel_id)];
                
            } errorHandler:^(id request, RpcError *error) {
                
                if(errorCallback != nil)
                {
                    errorCallback(error);
                }
                
                if([error.error_msg isEqualToString:@"CHANNEL_PRIVATE"]) {
                    
                    [self addUpdate:[TL_updateChannel createWithChannel_id:channel_id]];
            
                }
                
                [_channelsInUpdating removeObjectForKey:@(channel_id)];
                
            } timeout:0 queue:_queue.nativeQueue];
        }

    } else {
        if(channel != nil)
            [self addUpdate:[TL_updateChannel createWithChannel_id:channel_id]];
    }
    
    
}




@end
