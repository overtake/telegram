//
//  ConservationHistoryController.m
//  Telegram P-Edition
//
//  Created by keepcoder on 10.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ConversationHistoryController.h"
#import "TGPeer+Extensions.h"
#import "TGDialog+Extensions.h"
#import "TGMessage+Extensions.h"
#import "SelfDestructionController.h"
#import "MessageTableItem.h"
#import "PreviewObject.h"
#import "MessageTableItemUnreadMark.h"
@interface ConversationHistoryController ()



@property (nonatomic,strong) TL_conversation *dialog;
@property (nonatomic,strong) NSMutableDictionary *cache;
@property (nonatomic,assign) int position;
@property (nonatomic,assign) NSUInteger hash;
@property (nonatomic,strong) RPCRequest *request;
@property (nonatomic,strong) MessagesViewController *viewController;
@end



@implementation ConversationHistoryController



-(id)initWithController:(MessagesViewController *)controller {
    if(self = [super init]) {
        self.viewController = controller;
        self.cache = [[NSMutableDictionary alloc] init];
        [Notification addObserver:self selector:@selector(notificationReceiveMessages:) name:MESSAGE_LIST_RECEIVE];
        
        [Notification addObserver:self selector:@selector(notificationReceiveMessage:) name:MESSAGE_RECEIVE_EVENT];
        
        [Notification addObserver:self selector:@selector(notificationDeleteMessage:) name:MESSAGE_DELETE_EVENT];
        
        [Notification addObserver:self selector:@selector(notificationDeleteObjectMessage:) name:DELETE_MESSAGE];

    }
    return self;
}

-(void)clear:(TL_conversation *)dialog {
    NSMutableArray *cached = [self cacheForKey:dialog.peer.peer_id];
    [cached removeAllObjects];
}


-(void)notificationReceiveMessages:(NSNotification *)notify {
    [self insertMessages:notify.object];
}

-(void)insertMessages:(NSArray *)list {
    
    NSMutableDictionary *last = [[NSMutableDictionary alloc] init];
    
    for (int i = (int)list.count-1; i >= 0; i--) {
        TGMessage *message = list[i];
        NSMutableArray *messages = [last objectForKey:@([message peer_id])];
        if(!messages) {
            messages = [[NSMutableArray alloc] init];
            [last setObject:messages forKey:@([message peer_id])];
        }
        [messages addObject:message];
    }
    
    for (NSNumber *key in last.allKeys) {
        NSArray *insert = [last objectForKey:key];
        NSMutableArray *cache = [self cacheForKey:[key intValue]];
        if(insert.count > 0) {
            NSMutableArray *filtred = [[NSMutableArray alloc] init];
            
            for (TGMessage *nmsg in insert) {
                BOOL toadd = YES;
                for (MessageTableItem *item in cache) {
                    if(item.message.n_id == nmsg.n_id)
                        toadd = NO;
                }
                if(toadd)
                    [filtred addObject:nmsg];
            }
            
            insert = filtred;
            if(insert.count == 0)
                continue;
            
            int pos = 0;
            TGMessage *lastMessage = insert[0];
            
            if(cache.count > 0 && lastMessage.n_id != 0) {
                NSArray *copy = [cache copy];
               pos = [self posInArray:copy n_id:lastMessage.n_id];
            }
            
            insert = [self.viewController messageTableItemsFromMessages:insert];
            
            
            NSRange range = NSMakeRange(pos, insert.count);
            [cache insertObjects:insert atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
            
            
            if(self.dialog.peer.peer_id == [key intValue]) {
                if(self.dialog.type == DialogTypeSecretChat)
                    [SelfDestructionController addMessages:insert];
                
                if([self.delegate respondsToSelector:@selector(receivedMessageList:inRange:)])
                    [self.delegate receivedMessageList:insert inRange:range itsSelf:NO];
            }
            
            
        }
    }
}


-(void)notificationReceiveMessage:(NSNotification *)notification {
    TGMessage *message = [notification.userInfo objectForKey:KEY_MESSAGE];
    
    
    if(!message) 
        return;
    
    
    MessageTableItem *tableItem;
    
    
    
    int position = [self insertMessage:message tableItem:&tableItem];
    
    if(message.peer_id == self.dialog.peer.peer_id) {
        
      //  if(self.dialog.type == DialogTypeSecretChat)
          //  [SelfDestructionController addMessage:message];
       
        [self.delegate receivedMessage:tableItem position:position itsSelf:NO];
        
    }
}

-(int)insertMessage:(TGMessage *)message tableItem:(MessageTableItem **)tableItem {
    
    NSMutableArray *cache = [self cacheForKey:message.peer_id];
    
    
    if(*tableItem == nil)
        *tableItem = (MessageTableItem *) [[self.viewController messageTableItemsFromMessages:@[message]] lastObject];
    
    for (MessageTableItem *item in cache) {
        if(message.n_id != 0 && item.message.n_id == message.n_id)
            return 0;
    }
    
    int pos = 0;
    if(cache.count > 0 && message.n_id != 0) {
        NSArray *copy = [cache copy];
        pos = [self posInArray:copy n_id:message.n_id];
    }
    
    [cache insertObject:*tableItem atIndex:pos];
    
    return pos;
}


-(int)posInArray:(NSArray *)list n_id:(int)n_id {
    int pos = 0;
    
    while (pos+1 < list.count && ([((MessageTableItem *)list[pos]).message n_id] > n_id || [((MessageTableItem *)list[pos]).message n_id] == 0))
        pos++;
    
    return pos;
}


-(void)notificationDeleteObjectMessage:(NSNotification *)notification {
    TGMessage *msg = [notification.userInfo objectForKey:KEY_MESSAGE];
    NSMutableArray *cache = [self cacheForKey:msg.peer_id];
    [cache enumerateObjectsUsingBlock:^(MessageTableItem * obj, NSUInteger idx, BOOL *stop) {
        if(obj.message == msg) {
            [cache removeObject:obj];
            *stop = YES;
        }
    }];
}

-(void)notificationDeleteMessage:(NSNotification *)notification {
    NSArray *msgs = [notification.userInfo objectForKey:KEY_MESSAGE_ID_LIST];
    
    if(msgs.count == 0)
        return;
    
    self.isLoading = YES;
    
    
    for(NSNumber *msg_id in msgs) {
        TGMessage *msg = [[MessagesManager sharedManager] find:[msg_id intValue]];
        if(msg) {
            NSMutableArray *cache = [self cacheForKey:msg.peer_id];
            NSArray *filtred = [cache filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.message.n_id == %d",[msg_id intValue]]];
            if(filtred.count == 1) {
                [cache removeObject:[filtred lastObject]];
                if(self.dialog.peer.peer_id == msg.peer_id) {
                    --self.position;
                    if(self.position < 0) self.position = 0;
                }
            }
        }
        if(self.dialog.peer.peer_id == self.dialog.peer.peer_id)
            [self.delegate deleteMessages:msgs];
    }
    self.isLoading = NO;
}


-(void)dealloc {
    [Notification removeObserver:self];
    [self.cache removeAllObjects];
}

-(NSMutableArray *)cacheForKey:(int)key {
    
    NSMutableArray *cache = [self.cache objectForKey:@(key)];
    if(!cache) {
        cache = [[NSMutableArray alloc] init];
        [self.cache setObject:cache forKey:@(key)];
    }
    return cache;
}



-(void)next:(int)max_id count:(int)count callback:(void (^)(NSArray *))callback {
    if(self.isLoading) return;
    
    self.isLoading = YES;
    
    NSMutableArray *cache = [self cacheForKey:self.dialog.peer.peer_id];
    int max = count;
    if(max > (cache.count - self.position) )
        max = (int)cache.count - self.position;
        
    DLog(@"count:%d ^ range: %@",(int)cache.count,NSStringFromRange(NSMakeRange(self.position, max)));
    
    NSArray *result = @[];
    if(cache.count > self.position && cache.count >= (self.position+max)) {
        result = [cache subarrayWithRange:NSMakeRange(self.position, max)];
    }
   
        
    self.position+= (int) result.count;
        
    if(result.count > 0) {
        self.isLoading = NO;
        [self callback:result call:callback];
        if(result.count < count/3)
        {
            int nmax = result.count > 0 ? [((MessageTableItem *)[result lastObject]).message n_id] : max_id;
            [self local:nmax dialog:self.dialog count:count cache:cache prev:NO next:YES callback:callback];
        }
        return;
    }
    
    if(self.state == HistoryStateNeedLocal) {
        [self local:max_id dialog:self.dialog count:count cache:cache prev:NO next:YES callback:callback];
    }
    
    if(self.state == HistoryStateNeedRemote) {
        [self remote:max_id dialog:self.dialog count:count cache:cache callback:callback];
    }
    
}

-(void)local:(int)max_id dialog:(TL_conversation *)dialog count:(int)count cache:(NSMutableArray *)cache prev:(BOOL)prev next:(BOOL)next callback:(void (^)(NSArray *))callback {
    self.isLoading = YES;
    
    if(max_id == 0)
        max_id = dialog.top_message;
    
    [[Storage manager] messages:self.dialog.peer max_id:max_id limit:count next:!prev filterMask:0 completeHandler:^(NSArray *result) {
        
        [[MessagesManager sharedManager] add:result];

        
        if(self.hash != [dialog cacheHash]) {
            self.isLoading = NO;
            return;
        }
        
        
        NSArray *inserted = [self insertObjects:cache from:result];
        
        if(inserted.count < count && !prev) {
             self.state = self.dialog.type == DialogTypeSecretChat ? HistoryStateEnd : HistoryStateNeedRemote;
        }
        
        
        [self callback:inserted call:callback];
       
        
        int nmax = inserted.count > 0 ? [((MessageTableItem *)[inserted lastObject]).message n_id] : max_id;
        
        if(inserted.count < count/3 && self.state == HistoryStateNeedRemote) {
           
            [self remote:nmax dialog:self.dialog count:count-(int)inserted.count cache:cache callback:callback];
        }
        
      
        
    }];
}

-(void)remote:(int)max_id dialog:(TL_conversation *)dialog count:(int)count cache:(NSMutableArray *)cache callback:(void (^)(NSArray *))callback {
    self.isLoading = YES;
    self.request = [RPCRequest sendRequest:[TLAPI_messages_getHistory createWithPeer:[self.dialog inputPeer] offset:0 max_id:max_id limit:count] successHandler:^(RPCRequest *request, id response) {
        
        [[MessagesManager sharedManager] add:[response messages]];
        
        //hm for future may be
        for (TGMessage *message in [response messages]) {
            if([message.media isKindOfClass:[TL_messageMediaPhoto class]]) {
                
                [[Storage manager] insertMedia:message];
                
                PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:message.n_id media:message.media peer_id:message.peer_id];
                
                [Notification perform:MEDIA_RECEIVE data:@{KEY_PREVIEW_OBJECT:previewObject}];
            }
        }
        
        [[UsersManager sharedManager] add:[response users]];
        
        [[ChatsManager sharedManager] add:[response chats]];
        [[Storage manager] insertChats:[response chats] completeHandler:nil];
        [[Storage manager] insertMessages:[response messages] completeHandler:nil];
        
        if(self.hash != [dialog cacheHash]) {
            self.isLoading = NO;
            return;
        }
        
        NSArray *inserted = [self insertObjects:cache from:[response messages]];
        
       
        if([response messages].count <  count) {
            self.state = HistoryStateEnd;
        }
        [self callback:inserted call:callback];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        [self callback:@[] call:callback];
    } timeout:10];

}

-(void)callback:(NSArray *)result call:(void (^)(NSArray *))callback {
    if(callback)
        callback(result);
    self.isLoading = NO;
}

-(void)prev:(int)max_id count:(int)count mark:(BOOL)mark callback:(void (^)(NSArray *))callback {
    
    
  //  NSMutableArray *convertedResult = [[NSMutableArray alloc] init];
    
    NSMutableArray *cache = [self cacheForKey:self.dialog.peer.peer_id];

    [cache removeAllObjects];
    
    if(mark)
    {
        max_id = self.dialog.last_marked_message;
        
        self.dialog.last_marked_message = self.dialog.top_message;
        self.dialog.last_marked_date = self.dialog.last_message_date;
        
        [self.dialog save];
    }
    
    [self local:max_id dialog:self.dialog count:count cache:cache prev:YES next:!mark callback:callback];
    
}

-(NSArray *)insertObjects:(NSMutableArray *)to from:(NSArray *)from {
    
    NSMutableArray *filtred = [[NSMutableArray alloc] init];
    for (TGMessage *msg in from) {
        BOOL needAdd = YES;
        for (MessageTableItem *item in to) {
            if(msg.n_id != 0 && msg.n_id == item.message.n_id) {
                needAdd = NO;
                break;
            }
            
        }
        if(needAdd) {
            [filtred addObject:msg];
        }
    }
    
    filtred = [[self.viewController messageTableItemsFromMessages:filtred] mutableCopy];
    
    
    [to insertObjects:filtred atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(to.count, filtred.count)]];
    
    self.position+= (int) filtred.count;
    
    return filtred;
}

-(void)remoteCancel {
    if(self.request)
    {
        [self.request cancelRequest];
        self.isLoading = NO;
    }
}


-(void)addItem:(MessageTableItem *)item {
    [item.messageSender send];
    int pos = [self insertMessage:item.message tableItem:&item];
    if(self.dialog.peer.peer_id == item.message.peer_id)
        [self.delegate receivedMessage:item position:pos itsSelf:NO];
}

-(void)addItems:(NSArray *)items peer_id:(int)peer_id {
    if(items.count > 0) {
        MessageTableItem *item = [items lastObject];
        [item.messageSender send];
    }
    
    NSMutableArray *cached = [self cacheForKey:peer_id];
    
    NSRange range = NSMakeRange(0, items.count);
    [cached insertObjects:items atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];

    
    if(self.dialog.peer.peer_id == peer_id)
        [self.delegate receivedMessageList:items inRange:range itsSelf:YES];
}

-(void)drop {
    self.cache = [[NSMutableDictionary alloc] init];
    self.state = HistoryStateNeedLocal;
}

-(void)setDialog:(TL_conversation *)dialog {
    self->_dialog = dialog;
    self.position = 0;
    [self remoteCancel];
    self.state = HistoryStateNeedLocal;
    self.hash = [dialog cacheHash];
}
@end
