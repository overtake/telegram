//
//  DialogsManager.m
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "DialogsManager.h"
#import "TLPeer+Extensions.h"
#import "Telegram.h"
#import "PreviewObject.h"
#import "SenderHeader.h"
#import "MessagesUtils.h"
#import "FullUsersManager.h"
#import "SelfDestructionController.h"
@interface DialogsManager ()
@property (nonatomic,strong) NSMutableArray *dialogs;
@property (nonatomic,assign) NSInteger maxCount;
@end

@implementation DialogsManager


-(id)initWithQueue:(ASQueue *)queue {
    if(self = [super initWithQueue:queue]) {
        [Notification addObserver:self selector:@selector(setTopMessageToDialog:) name:MESSAGE_UPDATE_TOP_MESSAGE];
        [Notification addObserver:self selector:@selector(setTopMessagesToDialogs:) name:MESSAGE_LIST_UPDATE_TOP];
    }
    return self;
}

- (void)dealloc {
    [Notification removeObserver:self];
}

-(NSArray *)unloadedConversationsWithMessages:(NSArray *)messages {
    NSMutableDictionary *unloaded = [NSMutableDictionary dictionary];
    
    [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TL_conversation *conversation = [self find:obj.peer_id];
        
        if(!conversation) {
            unloaded[@(obj.peer_id)] = @(1);
        }
        
        
    }];
    
    return unloaded.allKeys;
}

- (void)updateReadList:(NSNotification *)notify {
    NSArray *copy = [notify.userInfo objectForKey:KEY_MESSAGE_ID_LIST];
   
    [[Storage manager] messages:^(NSArray *messages) {
        


    } forIds:copy random:NO queue:self.queue];
    
    
}


- (void)drop {
    [self.queue dispatchOnQueue:^{
        [self->list removeAllObjects];
        [self->keys removeAllObjects];
        
        [Notification perform:DIALOGS_NEED_FULL_RESORT data:@{KEY_DIALOGS:self->list}];
    }];
  
}

- (TL_conversation *)createDialogForUser:(TLUser *)user {
    __block TL_conversation *dialog;
    
    [ASQueue dispatchOnStageQueue:^{
        dialog = [TL_conversation createWithPeer:[TL_peerUser createWithUser_id:user.n_id] top_message:0 unread_count:0 last_message_date:0 notify_settings:nil last_marked_message:0 top_message_fake:0 last_marked_date:0 sync_message_id:0 read_inbox_max_id:0 read_outbox_max_id:0 draft:[TL_draftMessageEmpty create] lastMessage:nil];
   
        [dialog setUser:user];
        dialog.fake = YES;
        [self add:@[dialog]];
        
    } synchronous:YES];
   
    return dialog;
}

- (TL_conversation *)createDialogForChat:(TLChat *)chat {
    
    
    __block TL_conversation *dialog;
    
    [ASQueue dispatchOnStageQueue:^{
        
        if(chat.isChannel) {
            dialog = [self createDialogForChannel:chat];
        } else
            dialog = [TL_conversation createWithPeer:[TL_peerChat createWithChat_id:chat.n_id] top_message:0 unread_count:0 last_message_date:0 notify_settings:nil last_marked_message:0 top_message_fake:0 last_marked_date:0 sync_message_id:0 read_inbox_max_id:0 read_outbox_max_id:0 draft:[TL_draftMessageEmpty create] lastMessage:nil];
        
        
        dialog.fake = YES;
        [self add:@[dialog]];
        
    } synchronous:YES];
    
    return dialog;

}

- (TL_conversation *)createDialogForChannel:(TLChat *)chat {
    
    
    __block TL_conversation *dialog;
    
    [ASQueue dispatchOnStageQueue:^{
        dialog = [TL_conversation createWithPeer:[TL_peerChannel createWithChannel_id:chat.n_id] top_message:0 unread_count:0 last_message_date:0 notify_settings:nil last_marked_message:0 top_message_fake:0 last_marked_date:0 sync_message_id:0 read_inbox_max_id:0 read_outbox_max_id:0 draft:[TL_draftMessageEmpty create] lastMessage:nil pts:0 isInvisibleChannel:YES];
        
        [dialog save];
        
        
        dialog.fake = YES;
        [self add:@[dialog]];
        
    } synchronous:YES];
    
    return dialog;
    
}

- (TL_conversation *)createDialogEncryptedChat:(TLEncryptedChat *)chat {
    
    __block TL_conversation *dialog;
    
    [ASQueue dispatchOnStageQueue:^{
        dialog = [TL_conversation createWithPeer:[TL_peerSecret createWithChat_id:chat.n_id] top_message:0 unread_count:0 last_message_date:0 notify_settings:nil last_marked_message:0 top_message_fake:0 last_marked_date:0 sync_message_id:0 read_inbox_max_id:0 read_outbox_max_id:0 draft:[TL_draftMessageEmpty create] lastMessage:nil];
        
        
        dialog.fake = YES;
        [self add:@[dialog]];
        
    } synchronous:YES];
    
    return dialog;

}

- (TL_conversation *)createDialogForMessage:(TL_localMessage *)message {
    
    __block TL_conversation *dialog;
    
    [ASQueue dispatchOnStageQueue:^{
        dialog = [TL_conversation createWithPeer:[message peer] top_message:0 unread_count:0  last_message_date:message.date notify_settings:nil last_marked_message:message.n_id top_message_fake:0 last_marked_date:message.date sync_message_id:message.n_id read_inbox_max_id:0 read_outbox_max_id:message.n_id-1 draft:[TL_draftMessageEmpty create] lastMessage:message];
        
        
        dialog.fake = YES;
        [self add:@[dialog]];
        
    } synchronous:YES];
    
    return dialog;
    
}

- (void)deleteMessagesWithMessageIds:(NSArray *)ids {
    
    
    [self.queue dispatchOnQueue:^{
        
        [[Storage manager] deleteMessages:ids completeHandler:^(NSArray *peer_update) {
            
            
            [peer_update enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                int peer_id = [obj[KEY_PEER_ID] intValue];
                int msg_id = [obj[KEY_MESSAGE_ID] intValue];
                
                TL_conversation *conversation = [[DialogsManager sharedManager] find:peer_id];
                
                if(conversation.top_message == msg_id) {
                    [self updateLastMessageForDialog:conversation];
                }
                
                
            }];
            
            [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_DATA:peer_update}];
            
        }];
        
    }];
    
}


- (void)deleteMessagesWithRandomMessageIds:(NSArray *)ids isChannelMessages:(BOOL)isChannelMessages {
    
    
    [self.queue dispatchOnQueue:^{
        
        
        [[Storage manager] deleteMessagesWithRandomIds:ids isChannelMessages:isChannelMessages completeHandler:^(NSArray *peer_update_data) {
            
            [peer_update_data enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                TL_conversation *conversation = [[DialogsManager sharedManager] find:[obj[KEY_PEER_ID] intValue]];
                
                [self updateLastMessageForDialog:conversation];
                
            }];
            
            [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_DATA:peer_update_data}];
            
        }];
        
    }];
    
}

-(void)deleteChannelMessags:(NSArray *)messageIds {
    [[Storage manager] deleteChannelMessages:messageIds completeHandler:^(NSArray *peer_update,NSDictionary *readCount) {
        
        [peer_update enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            
            TL_conversation *conversation = [[DialogsManager sharedManager] find:[obj[KEY_PEER_ID] intValue]];
            
            conversation.unread_count-=[readCount[@(conversation.peer_id)] intValue];
            
            [self updateLastMessageForDialog:conversation];
            
        }];
        
        [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_DATA:peer_update}];
        
    }];

}

-(void)updateLastMessageForDialog:(TL_conversation *)dialog {
    
    [self.queue dispatchOnQueue:^{
        [[Storage manager] lastMessageWithConversation:dialog completeHandler:^(TL_localMessage *lastMessage) {
           
            if(lastMessage) {
                
                dialog.top_message = lastMessage.n_id;
                dialog.last_message_date = lastMessage ? lastMessage.date : dialog.last_message_date;
                dialog.last_marked_message = lastMessage.n_id;
                dialog.last_marked_date = lastMessage.date;
                
                [self checkBotKeyboard:dialog forMessage:lastMessage notify:YES];
                
                dialog.lastMessage = lastMessage;
                
                [dialog save];
                
                [self notifyAfterUpdateConversation:dialog];
                
            } else {
                
                [RPCRequest sendRequest:[TLAPI_messages_getHistory createWithPeer:dialog.inputPeer offset_id:0 offset_date:0 add_offset:0 limit:100 max_id:0 min_id:0] successHandler:^(id request, TL_messages_messages *response) {
                    
                    [SharedManager proccessGlobalResponse:response];
                    
                    if(response.messages.count == 0) {
                        [self completeDeleteConversation:nil dialog:dialog];
                        
                        
                        dialog.lastMessage = lastMessage;
                        
                        [dialog save];
                        
                        [self notifyAfterUpdateConversation:dialog];
                        
                    } else {
                        [self updateLastMessageForDialog:dialog];
                    }
                    
                    
                } errorHandler:^(id request, RpcError *error) {
                    
                }];
                
            }
            
            
            
            
        }];
    }];
}


-(void)notifyAfterUpdateConversation:(TL_conversation *)conversation {
    
    [self.queue dispatchOnQueue:^{
        
        if(conversation != nil) {
            [Notification perform:[Notification notificationNameByDialog:conversation action:@"message"] data:@{KEY_DIALOG:conversation,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:conversation]}];
            
            
            
            NSUInteger position = [self positionForConversation:conversation];
            
            [Notification perform:DIALOG_MOVE_POSITION data:@{KEY_DIALOG:conversation, KEY_POSITION:@(position)}];
            
            [MessagesManager updateUnreadBadge];
        }
        
    }];
    
}


-(BOOL)checkBotKeyboard:(TL_conversation *)conversation forMessage:(TL_localMessage *)message notify:(BOOL)notify {
    
    __block BOOL needNotify = NO;
    
    if(message.fromUser.isBot || ([message.action isKindOfClass:[TL_messageActionChatDeleteUser class]])) {
        if(message.reply_markup != nil && !message.n_out) {
            __block TL_localMessage *currentKeyboard;
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
                
                currentKeyboard = [transaction objectForKey:conversation.cacheKey inCollection:BOT_COMMANDS];
                
                if([message.reply_markup isKindOfClass:[TL_replyKeyboardHide class]]) {
                    if((!message.reply_markup.isSelective || message.isMentioned))
                        if(currentKeyboard.from_id == message.from_id) {
                            [transaction removeObjectForKey:conversation.cacheKey inCollection:BOT_COMMANDS];
                            needNotify = YES;
                        }
                } else if([message.reply_markup isKindOfClass:[TL_replyKeyboardMarkup class]]) {
                    if((!message.reply_markup.isSelective || message.isMentioned))
                        [transaction setObject:message forKey:conversation.cacheKey inCollection:BOT_COMMANDS];
                    needNotify = YES;
                }
                
            }];
            
            if([message.reply_markup isKindOfClass:[TL_replyKeyboardForceReply class]]) {
                
                TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:message.peer_id];
                
                [template setReplyMessage:message save:YES];
                
                [template performNotification];
                
                notify = NO;

                
            }
            
            if(notify)
                [Notification perform:[Notification notificationNameByDialog:conversation action:@"botKeyboard"] data:@{KEY_DIALOG:conversation}];
        } else if(!message.n_out || [message.action isKindOfClass:[TL_messageActionChatDeleteUser class]]) {
            
            __block BOOL updKeyboard = NO;
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
                
                TL_localMessage *msg = [transaction objectForKey:conversation.cacheKey inCollection:BOT_COMMANDS];
                
                if(msg){
                                
                    if(msg.from_id == message.action.user_id) {
                        [transaction removeObjectForKey:conversation.cacheKey inCollection:BOT_COMMANDS];
                        needNotify = YES;
                        updKeyboard = YES;
                    }
                }
                
                
            }];
            if(updKeyboard && notify)
                [Notification perform:[Notification notificationNameByDialog:conversation action:@"botKeyboard"] data:@{KEY_DIALOG:conversation}];
        }
    }
    
    return needNotify;
}

-(NSUInteger)positionForConversation:(TL_conversation *)dialog {
    [self resort];
    return [self->list indexOfObject:dialog];
}


-(void)completeDeleteConversation:(dispatch_block_t)completeHandler dialog:(TL_conversation *)dialog {
   
    [[Storage manager] deleteDialog:dialog completeHandler:^{
        [self.queue dispatchOnQueue:^{
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
                [transaction removeObjectForKey:dialog.cacheKey inCollection:BOT_COMMANDS];
            }];
            
            [Notification perform:DIALOG_DELETE data:@{KEY_DIALOG:dialog}];
            
            [Notification perform:MESSAGE_FLUSH_HISTORY data:@{KEY_DIALOG:dialog}];
            
            [self->list removeObject:dialog];
            [self->keys removeObjectForKey:@(dialog.peer_id)];
                        
            [MessagesManager updateUnreadBadge];
            
            if(dialog.chat != nil) {
                [[ChatFullManager sharedManager] removeObjectWithKey:@(dialog.chat.n_id)];
                [[ChatsManager sharedManager] removeObjectWithKey:@(dialog.chat.n_id)];
            }
            
            
        }];
        
        if(completeHandler)
            completeHandler();
    }];
    
}

- (void)deleteDialog:(TL_conversation *)dialog completeHandler:(dispatch_block_t)completeHandler {
    if(dialog == nil) {
        ELog(@"dialog is nil, check this");
        return;
    }
    
    dispatch_block_t newBlock = ^{
        
        dispatch_block_t block = ^{
            [self completeDeleteConversation:completeHandler dialog:dialog];
        };
        
        if(dialog.type != DialogTypeSecretChat && dialog.type != DialogTypeBroadcast && dialog.type != DialogTypeChannel)
            [self _clearHistory:dialog justClear:NO completeHandler:^{
                block();
            }];
        else {
            block();
        }
    };

    if(dialog.type == DialogTypeSecretChat) {
        [RPCRequest sendRequest:[TLAPI_messages_discardEncryption createWithChat_id:dialog.peer.chat_id] successHandler:^(RPCRequest *request, id response) {
            newBlock();
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            newBlock();
        }];
        return;
    }
    
    if(dialog.type == DialogTypeBroadcast) {
        [[BroadcastManager sharedManager] remove:@[dialog.broadcast]];
        newBlock();
        return;
    }
    
    if((dialog.type == DialogTypeChat || dialog.type == DialogTypeChannel) && !dialog.chat.isLeft && dialog.chat.type == TLChatTypeNormal) {
        
        id request = [TLAPI_messages_deleteChatUser createWithChat_id:dialog.chat.n_id user_id:[[UsersManager currentUser] inputUser]];
        
        if(dialog.type == DialogTypeChannel) {
            request = [TLAPI_channels_leaveChannel createWithChannel:dialog.chat.inputPeer];
            if(dialog.chat.isCreator) {
                request = [TLAPI_channels_deleteChannel createWithChannel:dialog.chat.inputPeer];
            }
            
        }
        
        
        [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
            newBlock();
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            newBlock();
        }];
        return;
    }
    
    
    newBlock();
}

- (void)_clearHistory:(TL_conversation *)dialog justClear:(BOOL)justClear completeHandler:(dispatch_block_t)block {
    [RPCRequest sendRequest:[TLAPI_messages_deleteHistory createWithFlags:justClear ? (1 << 0) : 0 peer:[dialog inputPeer] max_id:INT32_MAX] successHandler:^(RPCRequest *request, TL_messages_affectedHistory *response) {
        if([response offset] != 0)
            [self _clearHistory:dialog justClear:justClear completeHandler:(dispatch_block_t)block];
        else {
            if(block)
                block();
        }
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(block)
            block();
    }];
}


-(void)clearHistory:(TL_conversation *)dialog completeHandler:(dispatch_block_t)block {
    
    dispatch_block_t blockSuccess = ^{
        dialog.top_message = 0;
        
        dialog.unread_count = 0;
        dialog.lastMessage = nil;
        
        
        [dialog save];
        
        [MessagesManager updateUnreadBadge];
        
        [Notification perform:[Notification notificationNameByDialog:dialog action:@"message"] data:@{KEY_DIALOG:dialog,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:dialog]}];
        [[Storage manager] deleteMessagesInDialog:dialog completeHandler:block];
        
    };
    
    if(dialog.type != DialogTypeSecretChat) {
        [self _clearHistory:dialog justClear:YES completeHandler:^{
            blockSuccess();
        }];
    } else {
        
        FlushHistorySecretSenderItem *sender = [[FlushHistorySecretSenderItem alloc] initWithConversation:dialog];
        [sender send];
        
        blockSuccess();
    }
}

- (void)resort {
    [self->list sortUsingComparator:^NSComparisonResult(TL_conversation * obj1, TL_conversation * obj2) {
        
//        int date1 = MAX(obj1.draft.date ,obj1.last_message_date);
//        int date2 = MAX(obj2.draft.date ,obj2.last_message_date);
//        
//        if(date1 < date2)
//            return NSOrderedDescending;
//        else {
//            if (date1 > date2)
//                return NSOrderedAscending;
//            else if(obj1.top_message < obj2.top_message)
//                return NSOrderedDescending;
//            else
//                return NSOrderedAscending;
//        }
//        
        
        return (obj1.last_message_date < obj2.last_message_date ? NSOrderedDescending : (obj1.last_message_date > obj2.last_message_date ? NSOrderedAscending : (obj1.top_message < obj2.top_message ? NSOrderedDescending : NSOrderedAscending)));
    }];
    
}

- (void)setTopMessageToDialog:(NSNotification *)notify {
    TL_localMessage *message = [notify.userInfo objectForKey:KEY_MESSAGE];
    
    
    BOOL update_real_date = [[notify.userInfo objectForKey:@"update_real_date"] boolValue];
    
    [self.queue dispatchOnQueue:^{
        if([message.media isKindOfClass:[TL_messageMediaPhoto class]] || [message.media isKindOfClass:[TL_messageMediaVideo class]]) {
            
            PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:message.n_id media:message peer_id:message.peer_id];
            
            [Notification perform:MEDIA_RECEIVE data:@{KEY_PREVIEW_OBJECT:previewObject}];
        }
        
        [self checkAndProccessGifMessage:message];
        
        if(message.isN_out && message.media.document.isSticker) {
            [MessageSender addRecentSticker:message.media.document];
        }
        
        [self updateTop:message needUpdate:YES update_real_date:update_real_date];
        
        
        
        [Notification performOnStageQueue:MESSAGE_RECEIVE_EVENT data:@{KEY_MESSAGE:message}];
    }];
}


-(BOOL)checkAndProccessGifMessage:(TL_localMessage *)message {
    
    if(message.isN_out && message.media.document.isGif) {
        
        [[Storage yap] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
            
            NSMutableArray *items = [transaction objectForKey:@"gifs" inCollection:RECENT_GIFS];
            
            TL_document *item = [[items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",message.media.document.n_id]] firstObject];
            
            if(item) {
                [items removeObjectAtIndex:[items indexOfObject:item]];
            } else {
                
            }
            [items insertObject:message.media.document atIndex:0];

            
            [transaction setObject:items forKey:@"gifs" inCollection:RECENT_GIFS];
        }];
        
        
        
        return YES;
    }
    
    return NO;
    
}


- (void)updateTop:(TL_localMessage *)message needUpdate:(BOOL)needUpdate update_real_date:(BOOL)update_real_date {
    
    [self.queue dispatchOnQueue:^{
        
        
        if([message.to_id isKindOfClass:[TL_peerChannel class]] && message.chat.isLeft) {
            return;
        }
        
        NSArray *unloaded = [self unloadedConversationsWithMessages:@[message]];
        
        [[Storage manager] conversationsWithPeerIds:unloaded completeHandler:^(NSArray *result) {
            
            [self add:result];
            
            TL_conversation *dialog = message.conversation;
            
            [self updateConversation:dialog withLastMessage:message update_real_date:update_real_date];
            
            [dialog save];
            
            [MessagesManager updateUnreadBadge];
            
            [self add:@[dialog]];
            
            [self checkBotKeyboard:dialog forMessage:message notify:YES];
            
            if(needUpdate) {
                
                NSUInteger position = [self positionForConversation:dialog];
                
                if(dialog != nil) {
                    [Notification perform:DIALOG_MOVE_POSITION data:@{KEY_DIALOG:dialog, KEY_POSITION:@(position)}];
                    [Notification perform:[Notification notificationNameByDialog:dialog action:@"message"] data:@{KEY_DIALOG:dialog,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:dialog]}];
                }
                
            }
            
        }];
        
    }];
    
}

- (void)markAllMessagesAsRead:(TL_conversation *)dialog {
    
    [[Storage manager] markAllInConversation:dialog.peer_id max_id:dialog.top_message out:NO completeHandler:^(NSArray *ids,NSArray *messages, int unread_count) {
        
    }];
}

- (void) markAllMessagesAsRead:(TLPeer *)peer max_id:(int)max_id out:(BOOL)n_out {
    
    [self.queue dispatchOnQueue:^{
        
        TL_conversation *c = [self find:peer.peer_id];
        
        NSArray *unloaded = @[];
        
        if(!c)
            unloaded = @[@(peer.peer_id)];
        
        [[Storage manager] conversationsWithPeerIds:unloaded completeHandler:^(NSArray *result) {
            
            [self add:result];
            
            [[Storage manager] markAllInConversation:peer.peer_id max_id:max_id out:n_out completeHandler:^(NSArray *ids,NSArray *messages, int unread_count) {
                
                
                TL_conversation *conversation = [self find:peer.peer_id];
                
                if(conversation)
                {
                    conversation.last_marked_message = max_id;
                    
                    if(!n_out) {
                        conversation.read_inbox_max_id = max_id;
                        conversation.unread_count = unread_count;
                    } else {
                        conversation.read_outbox_max_id = max_id;
                    }
                    
                    [conversation save];
                    
                    [SelfDestructionController addMessages:messages];
                    
                    
                    [Notification perform:[Notification notificationNameByDialog:conversation action:@"unread_count"] data:@{KEY_DIALOG:conversation,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:conversation]}];
                    [Notification perform:MESSAGE_READ_EVENT data:@{KEY_MESSAGE_ID_LIST:ids}];
                    
                    
                    
                    [MessagesManager updateUnreadBadge];
                    
                    [MessagesManager clearNotifies:conversation max_id:max_id];

                }
                
                
            }];
            
            
        }];

        
    }];
    
    
    
    
}



-(void)markChannelMessagesAsRead:(int)channel_id max_id:(int)max_id n_out:(BOOL)n_out completionHandler:(dispatch_block_t)completionHandler {
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    
    [self.queue dispatchOnQueue:^{
        
        if(!n_out) {
            [[Storage manager] markChannelMessagesAsRead:channel_id max_id:max_id callback:^(int unread_count) {
                
                TL_conversation *conversation = [self find:-channel_id];
                
                if(conversation) {
                    

                    conversation.unread_count= unread_count;
                    conversation.last_marked_message = max_id;
                    conversation.read_inbox_max_id = max_id;
                    [conversation save];
                    
                    [Notification perform:[Notification notificationNameByDialog:conversation action:@"unread_count"] data:@{KEY_DIALOG:conversation,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:conversation]}];
                    
                    
                    if(conversation.unread_count > 0) {
                        [RPCRequest sendRequest:[TLAPI_messages_getPeerDialogs createWithPeers:[@[conversation.inputPeer] mutableCopy]] successHandler:^(id request, TL_messages_peerDialogs *response) {
                            
                            [response.messages removeAllObjects];
                            
                            [SharedManager proccessGlobalResponse:response];
                            
                            
                            
                            if(response.dialogs.count == 1) {
                                TL_dialog *c = response.dialogs[0];
                                
                                
                                if(c.unread_count != conversation.unread_count) {
                                    conversation.unread_count = c.unread_count;
                                    conversation.read_inbox_max_id = c.read_inbox_max_id;
                                    conversation.read_outbox_max_id = c.read_outbox_max_id;
                                    [conversation save];
                                    [Notification perform:[Notification notificationNameByDialog:conversation action:@"unread_count"] data:@{KEY_DIALOG:conversation,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:conversation]}];
                                }
                                
                            }
                            
                        } errorHandler:^(id request, RpcError *error) {
                            
                        }];
                    }
                    
                }
                
                if(completionHandler) {
                    dispatch_async(dqueue, completionHandler);
                }
                
                
            }];

        } else {
            [[Storage manager] markChannelOutMessagesAsRead:channel_id max_id:max_id callback:^(NSArray * messages) {
                
                TL_conversation *conversation = [self find:-channel_id];
                
                if(conversation) {
                    
                    conversation.read_outbox_max_id = max_id;
                    [conversation save];
                    
                    [Notification perform:MESSAGE_READ_EVENT data:@{KEY_MESSAGE_ID_LIST:messages}];
                    [Notification perform:[Notification notificationNameByDialog:conversation action:@"unread_count"] data:@{KEY_DIALOG:conversation,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:conversation]}];
                }

            }];
        }
        
        
    }];
    
}

- (void)insertDialog:(TL_conversation *)dialog {
    [self add:[NSArray arrayWithObject:dialog]];
    [dialog save];
}

-(void)updateTopMessagesWithMessages:(NSArray *)messages {
    
    
    [self.queue dispatchOnQueue:^{
        
        NSMutableDictionary *topMessages = [NSMutableDictionary dictionary];
        NSMutableDictionary *topImportantMessages = [NSMutableDictionary dictionary];

        [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            
            if(obj.isChannelMessage && (obj.isImportantMessage || obj.chat.isMegagroup)) {
                
                TL_localMessage *top_message = topImportantMessages[@(obj.peer_id)];
                
                if(top_message.n_id < obj.peer_id) {
                    topImportantMessages[@(obj.peer_id)] = obj;
                }
                
            } else {
                TL_localMessage *top_message = topMessages[@(obj.peer_id)];
                
                if(top_message.n_id < obj.peer_id) {
                    topMessages[@(obj.peer_id)] = obj;
                }
            }
            
        }];
        
        [[Storage manager] updateTopMessagesWithMessages:topMessages topImportantMessages:topImportantMessages];
        
    }];
}

-(BOOL)updateConversation:(TL_conversation *)dialog withLastMessage:(TL_localMessage *)message update_real_date:(BOOL)update_real_date {
    
    
    int topMessageId = dialog.top_message;
    
    if(topMessageId != 0 && topMessageId != -1 && ((topMessageId > message.n_id && topMessageId < TGMINFAKEID)))
        return NO;
    
    if(message.n_id > TGMINFAKEID && dialog.last_message_date > message.date)
        return NO;
    
    
    if(message.unread && !message.n_out && (message.conversation.read_inbox_max_id < message.n_id)) {
        
        
        dialog.unread_count++;
    }
    
    if([message.action isKindOfClass:[TL_messageActionChatMigrateTo class]]) {
        dialog.unread_count = 0;
    }
    
    dialog.top_message = message.n_id;
    

    dialog.lastMessage = message;
    
    if(message.n_out) {
        dialog.last_marked_message = message.n_id;
        dialog.last_marked_date = message.date + 1;
    }
    if(dialog.last_marked_message == 0) {
        dialog.last_marked_message = dialog.top_message;
        dialog.last_marked_date = dialog.last_message_date;
    }
    
    
    if((message.n_out|| !message.unread) && dialog.last_marked_message < message.n_id) {
        dialog.last_marked_message = message.n_id;
        dialog.last_marked_date = message.date;
    }
    
    int last_real_date = dialog.last_real_message_date;
  
    dialog.last_message_date = message.date;
    
    if(update_real_date) {
        dialog.last_real_message_date = last_real_date;
    }
    
    if(message.isN_out) {
        
        if(message.via_bot_id != 0) {
            [MessageSender addRatingForPeer:[TL_peerUser createWithUser_id:message.via_bot_id]];
        } else {
            if([message.peer isKindOfClass:[TL_peerUser class]]) {
                [MessageSender addRatingForPeer:message.peer];
            }
        } 
    }
    
    dialog.fake = NO;
    
    return YES;
    
}


- (void)setTopMessagesToDialogs:(NSNotification *)notify {
    NSArray *messages = [notify.userInfo objectForKey:KEY_MESSAGE_LIST];
    BOOL update_real_date = [[notify.userInfo objectForKey:@"update_real_date"] boolValue];
    NSMutableDictionary *last = [[NSMutableDictionary alloc] init];
    
    [self.queue dispatchOnQueue:^{
        
        NSArray *unloaded = [self unloadedConversationsWithMessages:messages];
        
        [[Storage manager] conversationsWithPeerIds:unloaded completeHandler:^(NSArray *conversations) {
           
            [self add:conversations];
            
            [messages enumerateObjectsUsingBlock:^(TL_localMessage *message, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [self checkAndProccessGifMessage:message];
                
                if(message.isN_out && message.media.document.isSticker) {
                    [MessageSender addRecentSticker:message.media.document];
                }
             
                TL_conversation *dialog = message.conversation;
                
                BOOL res = [self updateConversation:dialog withLastMessage:message update_real_date:update_real_date];
                
                if(dialog && res) {
                    [last setObject:dialog forKey:@(dialog.peer_id)];
                }
                
                
                if([message.media isKindOfClass:[TL_messageMediaPhoto class]]) {
                    
                    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:message.n_id media:message peer_id:message.peer_id];
                    
                    [Notification perform:MEDIA_RECEIVE data:@{KEY_PREVIEW_OBJECT:previewObject}];
                }
                
                BOOL needNotify = [self checkBotKeyboard:dialog forMessage:dialog.lastMessage notify:NO];
                
                if(needNotify) {
                    [Notification perform:[Notification notificationNameByDialog:dialog action:@"botKeyboard"] data:@{KEY_DIALOG:dialog}];
                }

            }];
            
            [[Storage manager] insertDialogs:last.allValues];
            
            [self add:last.allValues];
            
            [MessagesManager updateUnreadBadge];
            
            [self resort];
            
            [last.allValues enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSUInteger position = [self->list indexOfObject:obj];
                
                [Notification perform:DIALOG_MOVE_POSITION data:@{KEY_DIALOG:obj, KEY_POSITION:@(position)}];
                [Notification perform:[Notification notificationNameByDialog:obj action:@"message"] data:@{KEY_DIALOG:obj,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:obj]}];

            }];
            
            [Notification perform:MESSAGE_LIST_RECEIVE object:messages];
            
        }];
        
    }];
    
}


-(BOOL)resortAndCheck {
    NSArray *current = [self->list copy];
    
    [self resort];
    
    __block BOOL success = YES;
    
    [current enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL *stop) {
        if(self->list[idx] != obj) {
            success = NO;
            *stop = YES;
        }
    }];
    
    return success;
}

- (SSignal *)add:(NSArray *)all {
    
    return [self add:all updateCurrent:YES autoStart:YES];
}

- (SSignal *)add:(NSArray *)all autoStart:(BOOL)autoStart {
    
    return [self add:all updateCurrent:YES autoStart:autoStart];
}

- (SSignal *)add:(NSArray *)all updateCurrent:(BOOL)updateCurrent {
    return [self add:all updateCurrent:YES autoStart:YES];
}


- (SSignal *)add:(NSArray *)all updateCurrent:(BOOL)updateCurrent autoStart:(BOOL)autoStart {
    
    
    SSignal *signal = [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber * subscriber) {
        
        __block BOOL dispose = NO;
        
        [all enumerateObjectsUsingBlock:^(TL_conversation * dialog, NSUInteger idx, BOOL *stop) {
            TL_conversation *current = [keys objectForKey:@(dialog.peer_id)];
            if(current) {
                if(updateCurrent) {
                    current.unread_count = dialog.unread_count;
                    current.top_message = dialog.top_message;
                    current.last_message_date = dialog.last_message_date;
                    current.notify_settings = dialog.notify_settings;
                    current.fake = dialog.fake;
                    current.last_marked_message = dialog.last_marked_message;
                    current.top_message_fake = dialog.top_message_fake;
                    current.last_marked_date = dialog.last_marked_date;
                    current.last_real_message_date = dialog.last_real_message_date;
                    current.dstate = dialog.dstate;
                    current.read_inbox_max_id = dialog.read_inbox_max_id;
                    current.read_outbox_max_id = dialog.read_outbox_max_id;
                    current.pts = dialog.pts;
                    current.invisibleChannel = dialog.invisibleChannel;
                    current.lastMessage = dialog.lastMessage;
                }
                
            } else {
                [self->list addObject:dialog];
                [self->keys setObject:dialog forKey:@(dialog.peer_id)];
                current = dialog;
            }
            
            if(!current.notify_settings) {
                current.notify_settings = [TL_peerNotifySettingsEmpty create];
                [current save];
            }
            
            
            *stop = dispose;
            
        }];
        
        [self resort];
        
        [subscriber putNext:nil];
        
        
        return [[SBlockDisposable alloc] initWithBlock:^
                {
                    dispose = YES;
                }];
    }] startOn:self.queue];
    
    
    if(autoStart)
        [signal startWithNext:^(id next) {
            
        }];
    
    
    return signal;

}

- (TL_conversation *)findByUserId:(int)user_id {
    
    __block TL_conversation *dialog;
    
    [self.queue dispatchOnQueue:^{
        dialog = [self->keys objectForKey:@(user_id)];
    } synchronous:YES];
    
    return dialog;
}

-(id)find:(NSInteger)_id {
    __block TL_conversation *dialog;
    
    [self.queue dispatchOnQueue:^{
        dialog = [self->keys objectForKey:@(_id)];
    } synchronous:YES];
    
    return dialog;
}

- (TL_conversation *)findByChatId:(int)chat_id {
    
    __block TL_conversation *dialog;
    
    [self.queue dispatchOnQueue:^{
        dialog = [self->keys objectForKey:@(-ABS(chat_id))];
    } synchronous:YES];
    
    return dialog;
}

- (TL_conversation *)findBySecretId:(int)chat_id {
    __block TL_conversation *dialog;
    
    [self.queue dispatchOnQueue:^{
        dialog = [self->keys objectForKey:@(chat_id)];
    } synchronous:YES];
    
    return dialog;
}



+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}


@end
