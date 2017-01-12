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
#import "ChannelFilter.h"
#import "MessagesUtils.h"

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
    
    return MAX([[self conversationWithChannelId:channel_id] pts],1);
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
    
    if([update isKindOfClass:[TL_updateNewChannelMessage class]] || [update isKindOfClass:[TL_updateEditChannelMessage class]]) {
        return ((TL_updateNewChannelMessage *)update).message.to_id.channel_id;
    }  else if([update isKindOfClass:[TL_updateDeleteChannelMessages class]]) {
        return [(TL_updateDeleteChannelMessages *)update channel_id];
    } else if([update isKindOfClass:[TL_updateChannelTooLong class]]) {
        return [(TL_updateChannelTooLong *)update channel_id];
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
            
            statefullUpdates = @[NSStringFromClass([TL_updateNewChannelMessage class]),NSStringFromClass([TL_updateDeleteChannelMessages class]),NSStringFromClass([TL_updateEditChannelMessage class])];
            statelessUpdates = @[NSStringFromClass([TL_updateReadChannelInbox class]),NSStringFromClass([TL_updateChannelTooLong class]),NSStringFromClass([TL_updateChannelMessageViews class]),NSStringFromClass([TL_updateChannel class]),NSStringFromClass([TL_updateChannelPinnedMessage class]),NSStringFromClass([TL_updateReadChannelOutbox class])];
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
    
    TL_conversation *channel = [[ChatsManager sharedManager] find:statefulMessage.channel_id];
    
    if(channel) {
        [self addWaitingUpdate:statefulMessage];
    } else {
        [[MTNetwork instance].updateService update];
    }
    
    
    
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
            
            BOOL success = [self proccessStatefullUpdate:statefullMessage];
            
            if(!success)
            {
                *stop = YES;
            }
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
        
        weak();
        
        timer = [[TGTimer alloc] initWithTimeout:2 repeat:NO completion:^{
            
            [weakSelf.channelWaitingUpdates removeAllObjects];
            
            [weakSelf failUpdateWithChannelId:statefullMessage.channel_id limit:50 withCallback:nil errorCallback:nil];
            
        } queue:_queue.nativeQueue reservedObject:@(statefullMessage.channel_id)];
        
        _channelWaitingTimers[@(statefullMessage.channel_id)] = timer;
        
        [timer start];
    }
    
}



-(void)proccessHoleWithNewMessage:(NSArray *)messages channel:(TLChat *)channel {
    
    messages = [messages sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self.n_id" ascending:YES]]];
    
    
    [[Storage manager] insertMessages:messages];
    
    [Notification performOnStageQueue:MESSAGE_LIST_UPDATE_TOP data:@{KEY_MESSAGE_LIST:messages}];
    
    
}

-(BOOL)proccessUpdate:(id)update {
    
    
    if(![update isKindOfClass:[TL_updateChannel class]]) {
        
        TL_conversation *conversation = [self conversationWithChannelId:[self channelIdWithUpdate:update]];
        
        if(conversation && conversation.isInvisibleChannel) {
            
            [self proccessUpdate:[TL_updateChannel createWithChannel_id:[self channelIdWithUpdate:update]]];
            
            return YES;
            
        }
        
    }
    
    if ([update isKindOfClass:[TL_updateChannelWebPage class]]) {
        
        TLWebPage *page = [update webpage];
        
        TLMessageMedia *media = [TL_messageMediaWebPage createWithWebpage:page];
        
        [[Storage manager] messagesWithWebpage:media callback:^(NSDictionary *peers) {
            
            [Notification perform:UPDATE_WEB_PAGES data:@{KEY_WEBPAGE:page}];
            
            [Notification perform:UPDATE_WEB_PAGE_ITEMS data:@{KEY_DATA:peers,KEY_WEBPAGE:page}];
        }];
        
        return YES;
    }
    
    if([update isKindOfClass:[TL_updateNewChannelMessage class]])
    {
        
        TL_localMessage *message = [TL_localMessage convertReceivedMessage:[(TL_updateNewChannelMessage *)update message]];
        
        
        if((message.from_id > 0 && !message.fromUser) || (message.fwd_from != nil && !message.fwdObject) || ((message.via_bot_id != 0 && ![[UsersManager sharedManager] find:message.via_bot_id]) || ![TGProccessUpdates checkMessageEntityUsers:message])) {
            
            
            [self failUpdateWithChannelId:[self channelIdWithUpdate:update] limit:50 withCallback:nil errorCallback:nil];
            return NO;
        }

        
        
        [MessagesManager addAndUpdateMessage:message];
        
    } else if([update isKindOfClass:[TL_updateEditChannelMessage class]]) {
      
        TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[(TL_updateEditChannelMessage *)update message]];
        
        if([TGProccessUpdates checkMessageEntityUsers:msg]) {
            if(msg)
            [[Storage manager] addSupportMessages:@[msg]];
            
            TL_conversation *conversation = [self conversationWithChannelId:abs(msg.peer_id)];
            
            
            [[Storage manager] addHolesAroundMessage:msg];
            
            [[Storage manager] insertMessages:@[msg]];
            
            if(conversation.lastMessage.n_id == msg.n_id) {
                conversation.lastMessage = msg;
                [Notification perform:[Notification notificationNameByDialog:conversation action:@"message"] data:@{KEY_DIALOG:conversation,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:conversation]}];
            }
            
            
            
            [Notification perform:UPDATE_EDITED_MESSAGE data:@{KEY_MESSAGE:msg}];
        } else {
            return NO;
        }
        
    } else if( [update isKindOfClass:[TL_updateDeleteChannelMessages class]]) {
        
        NSMutableArray *channelMessages = [NSMutableArray array];
        
        int peer_id = -[(TL_updateDeleteChannelMessages *)update channel_id];
    
        
        [[update messages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [channelMessages addObject:@(channelMsgId([obj intValue], peer_id))];
        }];
        
        
        [[DialogsManager sharedManager] deleteChannelMessags:channelMessages];

        
        TLChat *channel = [[ChatsManager sharedManager] find:-peer_id];
        
        if(!channel.isBroadcast && !channel.isMegagroup) {
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

        }
        
        
        
    } else if([update isKindOfClass:[TL_updateMessageID class]]) {
        [[Storage manager] updateMessageId:[(TL_updateMessageID *)update random_id] msg_id:[(TL_updateMessageID *)update n_id] isChannel:YES];
        [Notification performOnStageQueue:MESSAGE_UPDATE_MESSAGE_ID data:@{KEY_MESSAGE_ID:@([(TL_updateMessageID *)update n_id]),KEY_RANDOM_ID:@([(TL_updateMessageID *)update random_id])}];
    } else if([update isKindOfClass:[TL_updateReadChannelInbox class]]) {
    
        TL_conversation *conversation = [self conversationWithChannelId:[update channel_id]];
        
        if(conversation.unread_count > 0) {
            [[DialogsManager sharedManager] markChannelMessagesAsRead:[update channel_id] max_id:[(TL_updateReadChannelInbox *)update max_id] n_out:NO completionHandler:^{}];
        }
        
        
        
    } else if([update isKindOfClass:[TL_updateReadChannelOutbox class]]) {
        
        [[DialogsManager sharedManager] markChannelMessagesAsRead:[update channel_id] max_id:[(TL_updateReadChannelInbox *)update max_id] n_out:YES completionHandler:^{}];
        
    } else if([update isKindOfClass:[TL_updateChannelTooLong class]]) {
        
        TL_conversation *channel = [self conversationWithChannelId:[self channelIdWithUpdate:update]];
        
        if(channel) {
             [self failUpdateWithChannelId:[update channel_id] limit:10 withCallback:nil errorCallback:nil];
        }
        
        
    } else if([update isKindOfClass:[TL_updateChannelMessageViews class]]) {
        
        TL_updateChannelMessageViews *views = (TL_updateChannelMessageViews *)update;
        
        [[Storage manager] updateMessageViews:views.views channelMsgId:channelMsgId(views.n_id, -views.channel_id)];
        
        [Notification perform:UPDATE_MESSAGE_VIEWS data:@{KEY_DATA:@{@(views.n_id):@(views.views)},KEY_MESSAGE_ID_LIST:@[@(views.n_id)],KEY_PEER_ID:@(-views.channel_id)}];
        
    } else if([update isKindOfClass:[TL_updateMessageID class]]) {
        [[MTNetwork instance].updateService.proccessor addUpdate:update];
    } else if([update isKindOfClass:[TL_updateChannel class]]) {
        
        //TODO
        // update channel interface.
        
        
        TLChat *chat = [[ChatsManager sharedManager] find:[update channel_id]];
        
        
        if(!chat)
            return NO;
        
        TL_conversation *channel = [self conversationWithChannelId:[update channel_id]];
        
        BOOL addInviteMessage = channel == nil;
        
        
        if(!channel) {
            channel = [[DialogsManager sharedManager] createDialogForChannel:chat];
            
            [[DialogsManager sharedManager] add:@[channel]];
            
            channel.invisibleChannel = NO;
            [channel save];
            
        }
        
        
        dispatch_block_t dispatch = ^{
            if(!chat.isLeft && chat.type != TLChatTypeForbidden) {
                
                [[ChatFullManager sharedManager] requestChatFull:chat.n_id withCallback:^(TLChatFull *fullChat) {
                   
                    if(fullChat.migrated_from_chat_id == 0) {
                        [RPCRequest sendRequest:[TLAPI_channels_getParticipant createWithChannel:chat.inputPeer user_id:[[UsersManager currentUser] inputUser]] successHandler:^(id request, TL_channels_channelParticipant *participant) {
                            
                            [SharedManager proccessGlobalResponse:participant];
                            
                            if([participant.participant isKindOfClass:[TL_channelParticipantSelf class]]) {
                                TL_localMessage *msg = [TL_localMessageService createWithFlags:TGMENTIONMESSAGE n_id:0 from_id:[participant.participant inviter_id] to_id:channel.peer reply_to_msg_id:0 date:participant.participant.date action:([TL_messageActionChatAddUser createWithUsers:[@[@([UsersManager currentUserId])] mutableCopy]]) fakeId:[MessageSender getFakeMessageId] randomId:rand_long() dstate:DeliveryStateNormal];
                                
                                channel.invisibleChannel = NO;
                                
                                [channel save];
                                [msg save:participant.participant.date > channel.last_message_date];
                                
                            }
                            
                            
                        } errorHandler:^(id request, RpcError *error) {
                            
                            [self failUpdateWithChannelId:[update channel_id] limit:50 withCallback:nil errorCallback:nil];
                            
                        }];

                    } else {
                        channel.invisibleChannel = NO;
                        [channel save];
                        [self failUpdateWithChannelId:[update channel_id] limit:50 withCallback:nil errorCallback:nil];
                        
                        if([[DialogsManager sharedManager] find:-fullChat.migrated_from_chat_id]) {
                            [Notification perform:SWAP_DIALOG data:@{@"o":@(-fullChat.migrated_from_chat_id),@"n":@(channel.peer_id)}];
                        }
                    }
                
                }];
                
            }
            
        };
        
        if(addInviteMessage) {
            
            _channelsInUpdating[@(channel.peer_id)] = [RPCRequest sendRequest:[TLAPI_updates_getChannelDifference createWithFlags:(1 << 0) channel:chat.inputPeer filter:[TL_channelMessagesFilterEmpty create] pts:1 limit:INT32_MAX] successHandler:^(id request, TL_updates_channelDifference *response) {
                
                channel.pts = response.pts;
                if (!channel.isPinned) {
                    channel.last_message_date = channel.lastMessage.date;
                }
                
                channel.last_marked_message = [response top_message];
                channel.last_marked_date = [[MTNetwork instance] getTime];
                
                channel.read_inbox_max_id = [response read_inbox_max_id];
                channel.unread_count = [response unread_count];
                
                if(!chat.isCreator)
                    dispatch();
                else
                {
                    [TL_localMessage convertReceivedMessages:[response n_messages]];
                    
                    [self proccessHoleWithNewMessage:[response n_messages] channel:chat];
                }
                
                [_channelsInUpdating removeObjectForKey:@(channel.peer_id)];
                
                [[DialogsManager sharedManager] notifyAfterUpdateConversation:channel];
                
            } errorHandler:^(id request, RpcError *error) {
                
                [_channelsInUpdating removeObjectForKey:@(channel.peer_id)];
            }];
        } else {
            dispatch();
        }
    
    } else if([update isKindOfClass:[TL_updateChannelPinnedMessage class]]) {
        TLChatFull *chat = [[ChatFullManager sharedManager] find:[update channel_id]];
        
        chat.pinned_msg_id = [(TL_updateChannelPinnedMessage *)update n_id];
        
        [Notification perform:UPDATE_PINNED_MESSAGE data:@{KEY_PEER_ID:@(-[update channel_id]),KEY_MESSAGE_ID:@(chat.pinned_msg_id)}];
    }

    
    return YES;
}


-(BOOL)proccessStatefullUpdate:(TGUpdateChannelContainer *)statefulMessage {
    
    BOOL success = [self proccessUpdate:statefulMessage.update];
    
    if(success) {
        if(statefulMessage.pts > 0) {
            TL_conversation *conversation = [self conversationWithChannelId:statefulMessage.channel_id];
            
            conversation.pts = [statefulMessage pts];
            
            [conversation save];
        }
    }
    
    return success;
    
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
            _channelsInUpdating[@(channel_id)] = [RPCRequest sendRequest:[TLAPI_updates_getChannelDifference createWithFlags:(1 << 0) channel:[TL_inputChannel createWithChannel_id:channel_id access_hash:channel.access_hash] filter:[TL_channelMessagesFilterEmpty create] pts:[self ptsWithChannelId:channel_id] limit:limit] successHandler:^(id request, id response) {
                
                
               if(channel && channel.isLeft)
                   return;
                
                TGMessageHole *longHole;
                BOOL dispatched = NO;
                
                if([response isKindOfClass:[TL_updates_channelDifferenceEmpty class]]) {
                    
                    
                } else if([response isKindOfClass:[TL_updates_channelDifference class]]) {
                    
                    if(conversation.pts < [response pts]) {
                        
                        NSMutableArray *messages = [[response n_messages] mutableCopy];
                        
                        [[response n_messages] removeAllObjects];
                        
                        [SharedManager proccessGlobalResponse:response];
                        
                        [TL_localMessage convertReceivedMessages:messages];
                        
                        
                        [[DialogsManager sharedManager] markChannelMessagesAsRead:channel_id max_id:conversation.read_inbox_max_id n_out:NO completionHandler:nil];


                        
                        [self proccessHoleWithNewMessage:messages channel:channel];
                        
                        [[response other_updates] enumerateObjectsUsingBlock:^(TLUpdate *obj, NSUInteger idx, BOOL *stop) {
                            
                            obj.channel_id = channel_id;
                            
                            [self proccessUpdate:obj];
                            
                        }];
                        
                        conversation.pts = [response pts];
                        
                        [conversation save];
                        
                        
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
                        if(!conversation.isPinned) {
                            conversation.last_message_date = conversation.lastMessage.date;
                        }
                        
                        conversation.last_marked_message = [response read_inbox_max_id];
                        
                        conversation.read_inbox_max_id = [response read_inbox_max_id];
                        conversation.unread_count = [response unread_count];
                        
                        [conversation save];
                        
                        [[DialogsManager sharedManager] add:@[conversation]];
                        
                        [[DialogsManager sharedManager] notifyAfterUpdateConversation:conversation];
                        
                        
                        
                        // insert holes
                        {
                            dispatched = YES;
                            
                            [[Storage manager] addHolesAroundMessage:topMsg completionHandler:^(TGMessageHole *hole,BOOL next) {
                                
                                if(callback != nil)
                                {
                                    callback(response,hole);
                                    
                                }
                                
                            }];
                            
                            
                        }
                    }
                    
                    
                    
                    [SharedManager proccessGlobalResponse:response];
                }
                
                
                if(callback != nil && !dispatched)
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
