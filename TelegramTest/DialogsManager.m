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
#import "MessagesBottomView.h"
#import "MessagesUtils.h"
@interface DialogsManager ()
@property (nonatomic,strong) NSMutableArray *dialogs;
@property (nonatomic,assign) NSInteger maxCount;
@end

@implementation DialogsManager


-(id)initWithQueue:(ASQueue *)queue {
    if(self = [super initWithQueue:queue]) {
        [Notification addObserver:self selector:@selector(setTopMessageToDialog:) name:MESSAGE_UPDATE_TOP_MESSAGE];
        [Notification addObserver:self selector:@selector(setTopMessagesToDialogs:) name:MESSAGE_LIST_UPDATE_TOP];
        [Notification addObserver:self selector:@selector(updateReadList:) name:MESSAGE_READ_EVENT];
    }
    return self;
}

- (void)dealloc {
    [Notification removeObserver:self];
}



- (void)updateReadList:(NSNotification *)notify {
    NSArray *copy = [notify.userInfo objectForKey:KEY_MESSAGE_ID_LIST];
   
    [[Storage manager] messages:^(NSArray *messages) {
        
        NSMutableDictionary *updateDialogs = [[NSMutableDictionary alloc] init];
        int total = 0;
        for (TL_localMessage *message in messages) {
            if(message.conversation) {
                if(!message.n_out) {
                    if(message.conversation.unread_count != 0)
                        ++total;
                    message.conversation.unread_count--;
                    
                }
                
                if(message.n_id > message.conversation.last_marked_message) {
                    message.conversation.last_marked_message = message.n_id;
                    message.conversation.last_marked_date = message.date;
                }
                
                [updateDialogs setObject:message.conversation forKey:@(message.conversation.peer.peer_id)];
            }
            
        }
        
        for (TL_conversation *dialog in updateDialogs.allValues) {
            [dialog save];
            [Notification perform:DIALOG_UPDATE data:@{KEY_DIALOG:dialog}];
            [Notification perform:[Notification notificationNameByDialog:dialog action:@"unread_count"] data:@{KEY_DIALOG:dialog,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:dialog]}];
        }
        
        
        
        [[Storage manager] markMessagesAsRead:copy useRandomIds:@[]];
        
        
        [MessagesManager updateUnreadBadge];
        

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
        dialog = [TL_conversation createWithPeer:[TL_peerUser createWithUser_id:user.n_id] top_message:0 unread_count:0 last_message_date:0 notify_settings:nil last_marked_message:0 top_message_fake:0 last_marked_date:0 sync_message_id:0 read_inbox_max_id:0 unread_important_count:0 lastMessage:nil];
   
    
        dialog.fake = YES;
        [self add:@[dialog]];
        
    } synchronous:YES];
   
    return dialog;
}

- (TL_conversation *)createDialogForChat:(TLChat *)chat {
    
    
    __block TL_conversation *dialog;
    
    [ASQueue dispatchOnStageQueue:^{
        
        if([chat isKindOfClass:[TL_channel class]]) {
            dialog = [self createDialogForChannel:chat];
        } else
            dialog = [TL_conversation createWithPeer:[TL_peerChat createWithChat_id:chat.n_id] top_message:0 unread_count:0 last_message_date:0 notify_settings:nil last_marked_message:0 top_message_fake:0 last_marked_date:0 sync_message_id:0 read_inbox_max_id:0 unread_important_count:0 lastMessage:nil];
        
        
        dialog.fake = YES;
        [self add:@[dialog]];
        
    } synchronous:YES];
    
    return dialog;

}

- (TL_conversation *)createDialogForChannel:(TLChat *)chat {
    
    
    __block TL_conversation *dialog;
    
    [ASQueue dispatchOnStageQueue:^{
        dialog = [TL_conversation createWithPeer:[TL_peerChannel createWithChannel_id:chat.n_id] top_message:0 unread_count:0 last_message_date:0 notify_settings:nil last_marked_message:0 top_message_fake:0 last_marked_date:0 sync_message_id:0 read_inbox_max_id:0 unread_important_count:0 lastMessage:nil pts:0 isInvisibleChannel:YES];
        
        
        dialog.fake = YES;
        [self add:@[dialog]];
        
    } synchronous:YES];
    
    return dialog;
    
}

- (TL_conversation *)createDialogEncryptedChat:(TLEncryptedChat *)chat {
    
    __block TL_conversation *dialog;
    
    [ASQueue dispatchOnStageQueue:^{
        dialog = [TL_conversation createWithPeer:[TL_peerSecret createWithChat_id:chat.n_id] top_message:0 unread_count:0 last_message_date:0 notify_settings:nil last_marked_message:0 top_message_fake:0 last_marked_date:0 sync_message_id:0 read_inbox_max_id:0 unread_important_count:0 lastMessage:nil];
        
        
        dialog.fake = YES;
        [self add:@[dialog]];
        
    } synchronous:YES];
    
    return dialog;

}

- (TL_conversation *)createDialogForMessage:(TL_localMessage *)message {
    
    __block TL_conversation *dialog;
    
    [ASQueue dispatchOnStageQueue:^{
        dialog = [TL_conversation createWithPeer:[message peer] top_message:0 unread_count:0  last_message_date:message.date notify_settings:nil last_marked_message:message.n_id top_message_fake:0 last_marked_date:message.date sync_message_id:message.n_id read_inbox_max_id:0 unread_important_count:0 lastMessage:message];
        
        
        dialog.fake = YES;
        [self add:@[dialog]];
        
    } synchronous:YES];
    
    return dialog;
    
}

- (void)deleteMessagesWithMessageIds:(NSArray *)ids {
    
    
    [self.queue dispatchOnQueue:^{
        
        [[Storage manager] deleteMessages:ids completeHandler:^(NSArray *peer_update) {
            
            [peer_update enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                TL_conversation *conversation = [[DialogsManager sharedManager] find:[obj[KEY_PEER_ID] intValue]];
                
                [self updateLastMessageForDialog:conversation];
                
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
    [self.queue dispatchOnQueue:^{
        
        [[Storage manager] deleteChannelMessagesMessages:messageIds completeHandler:^(NSArray *peer_update) {
            
            [peer_update enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                TL_conversation *conversation = [[DialogsManager sharedManager] find:[obj[KEY_PEER_ID] intValue]];
                
                [self updateLastMessageForDialog:conversation];
                
            }];
            
            [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_DATA:peer_update}];
            
        }];
        
    }];

}

-(void)updateLastMessageForDialog:(TL_conversation *)dialog {
    
    [[Storage manager] lastMessageForPeer:dialog.peer completeHandler:^(TL_localMessage *lastMessage) {
        
        [self.queue dispatchOnQueue:^{
            
            if(lastMessage) {
                
                dialog.top_message = lastMessage.n_id;
                dialog.last_message_date = lastMessage ? lastMessage.date : dialog.last_message_date;
                dialog.last_marked_message = lastMessage.n_id;
                dialog.last_marked_date = lastMessage.date;
                
                [self checkBotKeyboard:dialog forMessage:lastMessage notify:YES];
                
            } else {
                dialog.last_marked_message = dialog.top_message = dialog.last_marked_date = 0;
            }
            
            dialog.lastMessage = lastMessage;
            
            [dialog save];
            
            
            [self notifyAfterUpdateConversation:dialog];
            
        }];
        
    }];
    
}


-(void)notifyAfterUpdateConversation:(TL_conversation *)conversation {
    [Notification perform:[Notification notificationNameByDialog:conversation action:@"message"] data:@{KEY_DIALOG:conversation,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:conversation]}];
    
    NSUInteger position = [self positionForConversation:conversation];
    
    [Notification perform:DIALOG_MOVE_POSITION data:@{KEY_DIALOG:conversation, KEY_POSITION:@(position)}];
    
    [MessagesManager updateUnreadBadge];
}


-(BOOL)checkBotKeyboard:(TL_conversation *)conversation forMessage:(TL_localMessage *)message notify:(BOOL)notify {
    
    __block BOOL needNotify = NO;
    
    if(message.fromUser.isBot || ([message.action isKindOfClass:[TL_messageActionChatDeleteUser class]])) {
        if(message.reply_markup != nil && !message.n_out) {
            
            __block TL_localMessage *currentKeyboard;
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
                
                currentKeyboard = [transaction objectForKey:conversation.cacheKey inCollection:BOT_COMMANDS];
                
                
                if([message.reply_markup isKindOfClass:[TL_replyKeyboardHide class]]) {
                    if((message.reply_markup.flags & (1 << 2)) == 0 || [message isMentioned])
                        if(currentKeyboard.from_id == message.from_id) {
                            [transaction removeObjectForKey:conversation.cacheKey inCollection:BOT_COMMANDS];
                            needNotify = YES;
                        }
                } else if([message.reply_markup isKindOfClass:[TL_replyKeyboardMarkup class]]) {
                    if((message.reply_markup.flags & (1 << 2)) == 0 || [message isMentioned])
                        [transaction setObject:message forKey:conversation.cacheKey inCollection:BOT_COMMANDS];
                    needNotify = YES;
                }
                
            }];
            
            if([message.reply_markup isKindOfClass:[TL_replyKeyboardForceReply class]]) {
                
                if(message.replyMessage && message.replyMessage.from_id == [UsersManager currentUserId]) {
                    
                    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                        
                        [transaction setObject:message forKey:conversation.cacheKey inCollection:REPLAY_COLLECTION];
                        
                    }];
                    
                    if(conversation.peer_id == [Telegram conversation].peer_id) {
                        [ASQueue dispatchOnMainQueue:^{
                            [[Telegram rightViewController].messagesViewController.bottomView updateReplayMessage:YES animated:YES];
                        }];
                        
                    }
                    
                    notify = NO;
                }
                
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

- (void)deleteDialog:(TL_conversation *)dialog completeHandler:(dispatch_block_t)completeHandler {
    if(dialog == nil) {
        ELog(@"dialog is nil, check this");
        return;
    }
    
    dispatch_block_t newBlock = ^{
        
        dispatch_block_t block = ^{
            [[Storage manager] deleteDialog:dialog completeHandler:^{
                [self.queue dispatchOnQueue:^{
                    
                    [Notification perform:DIALOG_DELETE data:@{KEY_DIALOG:dialog}];
                    
                    [self->list removeObject:dialog];
                    [self->keys removeObjectForKey:@(dialog.peer.peer_id)];
                    
                    [MessagesManager updateUnreadBadge];
                    
                    
                    
                }];
               
                if(completeHandler)
                    completeHandler();
            }];
        };
        
        if(dialog.type != DialogTypeSecretChat && dialog.type != DialogTypeBroadcast)
            [self _clearHistory:dialog offset:0 completeHandler:^{
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
    
    if(dialog.type == DialogTypeChat && !dialog.chat.left && dialog.chat.type == TLChatTypeNormal) {
        [RPCRequest sendRequest:[TLAPI_messages_deleteChatUser createWithChat_id:dialog.chat.input user_id:[[UsersManager currentUser] inputUser]] successHandler:^(RPCRequest *request, id response) {
            newBlock();
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            newBlock();
        }];
        return;
    }
    
    
    newBlock();
}

- (void)_clearHistory:(TL_conversation *)dialog offset:(int)offset completeHandler:(dispatch_block_t)block {
    [RPCRequest sendRequest:[TLAPI_messages_deleteHistory createWithPeer:[dialog inputPeer] offset:offset] successHandler:^(RPCRequest *request, TL_messages_affectedHistory *response) {
        if([response offset] != 0)
            [self _clearHistory:dialog offset:[response offset] completeHandler:(dispatch_block_t)block];
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
        [self _clearHistory:dialog offset:0 completeHandler:^{
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
        return (obj1.last_real_message_date < obj2.last_real_message_date ? NSOrderedDescending : (obj1.last_real_message_date > obj2.last_real_message_date ? NSOrderedAscending : (obj1.top_message < obj2.top_message ? NSOrderedDescending : NSOrderedAscending)));
    }];
    
}

- (void)setTopMessageToDialog:(NSNotification *)notify {
    TL_localMessage *message = [notify.userInfo objectForKey:KEY_MESSAGE];
    
    
    BOOL update_real_date = [[notify.userInfo objectForKey:@"update_real_date"] boolValue];
    
    [self.queue dispatchOnQueue:^{
        if([message.media isKindOfClass:[TL_messageMediaPhoto class]] || [message.media isKindOfClass:[TL_messageMediaVideo class]]) {
            [[Storage manager] insertMedia:message];
            
            PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:message.n_id media:message peer_id:message.peer_id];
            
            [Notification perform:MEDIA_RECEIVE data:@{KEY_PREVIEW_OBJECT:previewObject}];
        }
        
        
        [self updateTop:message needUpdate:YES update_real_date:update_real_date];
        [Notification perform:MESSAGE_RECEIVE_EVENT data:@{KEY_MESSAGE:message}];
    }];
}

- (void)updateTop:(TL_localMessage *)message needUpdate:(BOOL)needUpdate update_real_date:(BOOL)update_real_date {
    
    [self.queue dispatchOnQueue:^{
        TL_conversation *dialog = message.conversation;
        if(dialog.top_message != 0 && dialog.top_message != -1 && ((dialog.top_message > message.n_id && dialog.top_message < TGMINFAKEID)))
            return;
        
        
        if(message.unread && !message.n_out) {
            dialog.unread_count++;
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
        
        [dialog save];
        
        [MessagesManager updateUnreadBadge];
        
        [self add:@[dialog]];
        
        
        [self checkBotKeyboard:dialog forMessage:message notify:YES];
        
        
        
        if(needUpdate) {
            
            NSUInteger position = [self positionForConversation:dialog];
            
           
            
            [Notification perform:DIALOG_MOVE_POSITION data:@{KEY_DIALOG:dialog, KEY_POSITION:@(position)}];
            [Notification perform:[Notification notificationNameByDialog:dialog action:@"message"] data:@{KEY_DIALOG:dialog,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:dialog]}];
        }
        
    }];
    
}

- (void)markAllMessagesAsRead:(TL_conversation *)dialog {
     [(MessagesManager *)[MessagesManager sharedManager] markAllInDialog:dialog callback:^(NSArray *ids) {
         
         if(ids.count > 0) {
             
             
             [self.queue dispatchOnQueue:^{
                 [Notification perform:MESSAGE_READ_EVENT data:@{KEY_MESSAGE_ID_LIST:ids}];
                 [Notification perform:[Notification notificationNameByDialog:dialog action:@"unread_count"] data:@{KEY_DIALOG:dialog,KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:dialog]}];
             }];
             
             
         }
         
         
         
     }];
    
}

- (void) markAllMessagesAsRead:(TLPeer *)peer max_id:(int)max_id out:(BOOL)n_out {
    
    TL_conversation *conversation = [[DialogsManager sharedManager] find:peer.peer_id];
    
    [(MessagesManager *)[MessagesManager sharedManager] markAllInConversation:conversation max_id:max_id out:n_out callback:^(NSArray *ids) {
        if(ids.count > 0) {
            [Notification perform:MESSAGE_READ_EVENT data:@{KEY_MESSAGE_ID_LIST:ids}];
        }
    }];
    
}

- (void)insertDialog:(TL_conversation *)dialog {
    [self add:[NSArray arrayWithObject:dialog]];
    [dialog save];
}

- (void)setTopMessagesToDialogs:(NSNotification *)notify {
    NSArray *messages = [notify.userInfo objectForKey:KEY_MESSAGE_LIST];
    BOOL update_real_date = [[notify.userInfo objectForKey:@"update_real_date"] boolValue];
    NSMutableDictionary *last = [[NSMutableDictionary alloc] init];
    
    [self.queue dispatchOnQueue:^{
        for (TL_localMessage *message in messages) {
            TL_conversation *dialog = message.conversation;
            
            if(dialog && (dialog.top_message > TGMINFAKEID || dialog.top_message < message.n_id)) {
                dialog.top_message = message.n_id;
                
                int last_real_date = dialog.last_real_message_date;
                
                dialog.last_message_date = message.date;
                
                if(update_real_date) {
                    dialog.last_real_message_date = last_real_date;
                }
                
                if(dialog.last_marked_message == 0) {
                    dialog.last_marked_message = dialog.top_message;
                    dialog.last_marked_date = dialog.last_message_date;
                }
                
                if((message.n_out|| !message.unread) && dialog.last_marked_message < message.n_id) {
                    dialog.last_marked_message = message.n_id;
                    dialog.last_marked_date = message.date;
                }
                
                if(!message.n_out && message.unread) {
                    dialog.unread_count++;
                }
                
                dialog.lastMessage = message;
                
                
                [dialog save];
                
            } else {
                [self updateTop:message needUpdate:NO update_real_date:NO];
                dialog = message.conversation;
            }
            
            if(dialog) {
                [last setObject:dialog forKey:@(dialog.peer.peer_id)];
            }
            
            [last enumerateKeysAndObjectsUsingBlock:^(id key, TL_conversation *obj, BOOL *stop) {
                
                BOOL needNotify = [self checkBotKeyboard:obj forMessage:obj.lastMessage notify:NO];
                
                if(needNotify) {
                     [Notification perform:[Notification notificationNameByDialog:obj action:@"botKeyboard"] data:@{KEY_DIALOG:obj}];
                }
                
            }];
            
            if([message.media isKindOfClass:[TL_messageMediaPhoto class]]) {
                [[Storage manager] insertMedia:message];
                
                PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:message.n_id media:message peer_id:message.peer_id];
                
                [Notification perform:MEDIA_RECEIVE data:@{KEY_PREVIEW_OBJECT:previewObject}];
            }
            
            
        }
        
        
        [self add:last.allValues];
        
        [MessagesManager updateUnreadBadge];

        [Notification perform:DIALOGS_NEED_FULL_RESORT data:@{KEY_DIALOGS:self->list}];
        [Notification perform:MESSAGE_LIST_RECEIVE object:messages];
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

- (void)add:(NSArray *)all {
    
    [self.queue dispatchOnQueue:^{
        [all enumerateObjectsUsingBlock:^(TL_conversation * dialog, NSUInteger idx, BOOL *stop) {
            TL_conversation *current = [keys objectForKey:@(dialog.peer.peer_id)];
            if(current) {
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
                current.top_important_message = dialog.top_important_message;
                current.unread_important_count = dialog.unread_important_count;
            } else {
                [self->list addObject:dialog];
                [self->keys setObject:dialog forKey:@(dialog.peer.peer_id)];
                current = dialog;
            }
            
            if(!current.notify_settings) {
                current.notify_settings = [TL_peerNotifySettingsEmpty create];
                [current save];
            }
            
            [self resort];
            
        }];
    }];
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
