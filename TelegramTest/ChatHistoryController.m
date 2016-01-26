

//
//  ChatHistoryController.m
//  Messenger for Telegram
//
//  Created by keepcoder on 16.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ChatHistoryController.h"
#import "TLPeer+Extensions.h"
#import "MessageTableItem.h"
#import "SelfDestructionController.h"
#import "NSArray+BlockFiltering.h"
#import "ASQueue.h"
#import "PreviewObject.h"
#import "PhotoVideoHistoryFilter.h"
#import "PhotoHistoryFilter.h"
#import "VideoHistoryFilter.h"
#import "SharedLinksHistoryFilter.h"
#import "DocumentHistoryFilter.h"
#import "AudioHistoryFilter.h"
#import "MP3HistoryFilter.h"
#import "TGTimer.h"
#import "TGProccessUpdates.h"
#import "ChannelFilter.h"
#import "TGChannelsPolling.h"
#import "ChannelImportantFilter.h"
#import "WeakReference.h"
#import "MegagroupChatFilter.h"
@interface ChatHistoryController ()


@property (atomic)  dispatch_semaphore_t semaphore;
@property (atomic,assign) int requestCounter;
@property (atomic,assign) BOOL proccessing;

@property (nonatomic,strong) TL_conversation *conversation;

@property (nonatomic,strong) NSString *internalId;

@property (nonatomic,strong) NSMutableArray *filters;

@property (nonatomic,assign) BOOL isNeedSwapFilters;

@end

@implementation ChatHistoryController



static ASQueue *queue;
static NSMutableArray *listeners;


static ChatHistoryController *observer;

-(id)initWithController:(id<MessagesDelegate>)controller historyFilter:(Class)historyFilter {
    if(self = [super init]) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            queue = [ASQueue globalQueue];
            
            listeners = [[NSMutableArray alloc] init];
            
            observer = [[ChatHistoryController alloc] init];
            
            [Notification addObserver:observer selector:@selector(notificationReceiveMessages:) name:MESSAGE_LIST_RECEIVE];
            
            [Notification addObserver:observer selector:@selector(notificationReceiveMessage:) name:MESSAGE_RECEIVE_EVENT];
            
            [Notification addObserver:observer selector:@selector(notificationDeleteMessage:) name:MESSAGE_DELETE_EVENT];
            
            [Notification addObserver:observer selector:@selector(notificationFlushHistory:) name: MESSAGE_FLUSH_HISTORY];
                        
            [Notification addObserver:observer selector:@selector(notificationUpdateMessageId:) name:MESSAGE_UPDATE_MESSAGE_ID];
            
        });
        
        _internalId = [NSString stringWithFormat:@"%ld",rand_long()];
        
        _conversation = [controller conversation];
        
        [listeners addObject:[WeakReference weakReferenceWithObject:self]];
        
        
        _filters = [NSMutableArray array];
        
        _controller = controller;
        
        
        self.semaphore = dispatch_semaphore_create(1);
        
        self.selectLimit = 100;
        
        [self addFilter:[[historyFilter alloc] initWithController:self peer:_conversation.peer]];
        
        if(_conversation.type == DialogTypeChannel) {
            
            __block BOOL requestNext = NO;
            
            dispatch_block_t block = ^{
                
                if( _conversation.chat.chatFull.migrated_from_chat_id != 0) {
                    
                    HistoryFilter *filter = [[historyFilter == [ChannelFilter class] ? [MegagroupChatFilter class] : historyFilter alloc] initWithController:self peer:[TL_peerChat createWithChat_id:_conversation.chat.chatFull.migrated_from_chat_id]];
                    
                    [self addFilter:filter];
                    
                    if(requestNext && [controller respondsToSelector:@selector(requestNextHistory)]) {
                        [controller requestNextHistory];
                    }
                }
            };
            
            if(_conversation.chat.chatFull != nil) {
                block();
            } else {
                [[FullChatManager sharedManager] performLoad:_conversation.chat.n_id callback:^(TLChatFull *fullChat) {
                    
                    requestNext = YES;
                    block();
                    
                }];
            }
            
        }

        
        
    }
    
    return self;
}


-(ASQueue *)queue {
    return queue;
}

-(HistoryFilter *)filterWithNext:(BOOL)next {
    
    __block HistoryFilter *filter;
    
    
    [ASQueue dispatchOnStageQueue:^{
       
        filter = [_filters lastObject];
        
        if(!next && !_isNeedSwapFilters)
        {
            filter = [_filters firstObject];
        } else {
            [_filters enumerateObjectsWithOptions: _isNeedSwapFilters ? NSEnumerationReverse : 0 usingBlock:^(HistoryFilter *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![obj checkState:ChatHistoryStateFull next:next])
                {
                    *stop = YES;
                    filter = obj;
                }
                
            }];
        }
        
        
        
        
    } synchronous:YES];
    
    return filter;
}


-(void)swapFiltersBeforePrevLoaded {
    [self.queue dispatchOnQueue:^{
        _isNeedSwapFilters = YES;
    }];
}

-(BOOL)isNeedSwapFilters {
    __block BOOL needSwap = NO;
    
    [self.queue dispatchOnQueue:^{
        needSwap = _isNeedSwapFilters;
    } synchronous:YES];
    
    return needSwap;
}

-(HistoryFilter *)filterAtIndex:(int)index
{
    __block HistoryFilter *filter;
    
    [ASQueue dispatchOnStageQueue:^{
        filter = _filters[index];
    } synchronous:YES];
    
   return filter;

}

-(HistoryFilter *)filterWithPeerId:(int)peer_id {
    __block HistoryFilter *filter;
    
    [ASQueue dispatchOnStageQueue:^{
        [_filters enumerateObjectsUsingBlock:^(HistoryFilter *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(obj.peer_id == peer_id)
            {
                *stop = YES;
                filter = obj;
            }
            
        }];
    } synchronous:YES];
    
    
    
    
    return filter;

}

-(HistoryFilter *)filter {
    
    __block HistoryFilter *filter;
    
    [self.queue dispatchOnQueue:^{
        
        if(_isNeedSwapFilters) {
            filter = [_filters lastObject];
            
            if([filter checkState:ChatHistoryStateFull next:NO]) {
                filter = [_filters firstObject];
            }
        } else {
            filter = [_filters firstObject];
        }
        
        
    } synchronous:YES];
    
    return filter;
}

-(void)setFilter:(HistoryFilter *)filter {
    [self.queue dispatchOnQueue:^{
        
        [_filters replaceObjectAtIndex:0 withObject:filter];
        
    }];
}


-(void)addFilter:(HistoryFilter *)filter {
    
    assert([self filterWithPeerId:filter.peer_id] == nil);
    
    [_filters addObject:filter];
    
}

-(ChatHistoryState)prevState {
    HistoryFilter *filter = self.filter;
    return filter.prevState;
}


-(void)prevStateAsync:(void (^)(ChatHistoryState state))block {
    
    [ASQueue dispatchOnStageQueue:^{
        
        ChatHistoryState state = self.prevState;
        
        [ASQueue dispatchOnMainQueue:^{
            
            block(state);
            
        }];
        
    }];
    
}
-(void)nextStateAsync:(void (^)(ChatHistoryState state))block {
    [ASQueue dispatchOnStageQueue:^{
        
        ChatHistoryState state = self.nextState;
        
        [ASQueue dispatchOnMainQueue:^{
            
            block(state);
            
        }];
        
    }];
}

-(ChatHistoryState)nextState {
    HistoryFilter *filter = self.filter;
    return filter.nextState;
}


-(void)addMessageWithoutSavingState:(TL_localMessage *)message {
    
    [queue dispatchOnQueue:^{
        
        [[self filterWithPeerId:message.peer_id] filterAndAdd:@[message] latest:NO];
        
        if(message.peer_id != self.filter.peer_id) {
            [self swapFiltersBeforePrevLoaded];
        }
        
    }];
}



-(void)notificationReceiveMessages:(NSNotification *)notify {
    
    [queue dispatchOnQueue:^{
        
        NSArray *messages = [notify.object copy];
        
        [listeners enumerateObjectsUsingBlock:^(WeakReference *weak, NSUInteger idx, BOOL *stop) {
            
            ChatHistoryController *controller = [weak nonretainedObjectValue];
            
            NSArray *accepted = [controller.filter sortItems:[controller.filter filterAndAdd:messages latest:YES]];
            
            if(accepted.count == 0) {
                return;
            }
            
            NSArray *items = [controller.filter selectAllItems];
            
            int pos = (int) [items indexOfObject:[accepted firstObject]];
            
            NSRange range = NSMakeRange(pos+1, accepted.count);
            
            [SelfDestructionController addMessages:accepted];
            
            NSArray *converted = [controller.controller messageTableItemsFromMessages:accepted];
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                [controller.controller receivedMessageList:converted inRange:range itsSelf:NO];
            }];
            
            
        }];
    }];
    
}


-(void)notificationDeleteMessage:(NSNotification *)notification {
    
    
    [queue dispatchOnQueue:^{
        
        self.proccessing = YES;
        
        NSArray *updateData = [notification.userInfo objectForKey:KEY_DATA];
        
        if(updateData.count == 0)
            return;
        
        
        [updateData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            
            
            [listeners enumerateObjectsUsingBlock:^(WeakReference *weak, NSUInteger idx, BOOL *stop) {
                
                ChatHistoryController *controller = [weak nonretainedObjectValue];
                
                int peer_id = [obj[KEY_PEER_ID] intValue];
                
                [controller.filters enumerateObjectsUsingBlock:^(HistoryFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if(filter.peer_id == peer_id) {
                        
                        TL_localMessage *message = filter.messageKeys[obj[KEY_MESSAGE_ID]];
                        
                        [filter.messageItems removeObject:message];
                        [filter.messageKeys removeObjectForKey:obj[KEY_MESSAGE_ID]];
                        
                        if(message != nil) {
                            
                            [[ASQueue mainQueue] dispatchOnQueue:^{
                                [controller.controller deleteItems:@[message] orMessageIds:@[@(message.n_id)]];
                            }];
                        }
                        
                    }
                    
                }];
                
                

                
            }];
            
        }];
        
       self.proccessing = NO;
        
    }];
    
}

-(void)setProccessing:(BOOL)isProccessing {
    
    
    [ASQueue dispatchOnStageQueue:^{
        _proccessing = isProccessing;
    }];
    
    
    [ASQueue dispatchOnMainQueue:^{
        [self.controller updateLoading];
    }];
}

-(BOOL)isProccessing {
    
    
    __block BOOL isProccessing = YES;
    
    
    isProccessing = _proccessing;
        
    
    return isProccessing;
}

-(void)notificationFlushHistory:(NSNotification *)notification {
    
    
    
    [queue dispatchOnQueue:^{
        
        self.proccessing = YES;
        
        TL_conversation *conversation = [notification.userInfo objectForKey:KEY_DIALOG];
        
        
        [listeners enumerateObjectsUsingBlock:^(WeakReference *weak, NSUInteger idx, BOOL *stop) {
            
            ChatHistoryController *controller = [weak nonretainedObjectValue];
       
            [controller.filters enumerateObjectsUsingBlock:^(HistoryFilter *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(obj.peer_id == conversation.peer_id) {
                    
                    [obj clear];
                    
                    [[ASQueue mainQueue] dispatchOnQueue:^{
                        [controller.controller flushMessages];
                    }];
                }
                
            }];
            
            
        }];
        
         self.proccessing = NO;
        
    }];
    
}


-(void)notificationReceiveMessage:(NSNotification *)notification {
    
    [queue dispatchOnQueue:^{
        
        
        TL_localMessage *message = [notification.userInfo objectForKey:KEY_MESSAGE];
        
        
        if(!message)
            return;
        
        
        [listeners enumerateObjectsUsingBlock:^(WeakReference *weak, NSUInteger idx, BOOL *stop) {
            
            ChatHistoryController *obj = [weak nonretainedObjectValue];
            
            
            NSArray *items = [obj.filter filterAndAdd:@[message] latest:YES];
            
            if(items.count != 1)
                return;
            
            if(obj.filter.peer_id == message.peer_id) {
                
                NSArray *items = [obj.filter selectAllItems];
                
                int position = (int) [items indexOfObject:message];
                
                [SelfDestructionController addMessages:@[message]];
                
                NSArray *converted = [obj.controller messageTableItemsFromMessages:@[message]];
                    
                [[ASQueue mainQueue] dispatchOnQueue:^{
                        
                    [obj.controller receivedMessageList:converted inRange:NSMakeRange(position+1, converted.count) itsSelf:NO];
                    
                }];
                 
            }
            
        }];
        
    }];
    
}

-(void)notificationUpdateMessageId:(NSNotification *)notification {
    
    [queue dispatchOnQueue:^{
        
        int n_id = [notification.userInfo[KEY_MESSAGE_ID] intValue];
        long random_id = [notification.userInfo[KEY_RANDOM_ID] longValue];
        
        [self updateItemId:random_id withId:n_id];
            

    }];
    
}


-(void)performCallback:(selectHandler)selectHandler result:(NSArray *)result range:(NSRange )range controller:(id)controller {
   
    self.proccessing = NO;
    
   [[ASQueue mainQueue] dispatchOnQueue:^{
        
       if(selectHandler)
            selectHandler(result,range,controller);
    }];

}



-(void)request:(BOOL)next anotherSource:(BOOL)anotherSource sync:(BOOL)sync selectHandler:(selectHandler)selectHandler {
    
    [queue dispatchOnQueue:^{
        
        HistoryFilter *filter = [self filterWithNext:next];
        
        if([filter checkState:ChatHistoryStateFull next:next] || self.isProccessing) {
            [self performCallback:selectHandler result:@[] range:NSMakeRange(0, 0) controller:self];
            return;
        }
        
        self.proccessing = YES;
        
        
        [filter request:next callback:^(NSArray *result, ChatHistoryState state) {
            
            
            if([filter checkState:ChatHistoryStateLocal next:next] && result.count == 0) {
                
                [filter proccessResponse:result state:state next:next];
                
                self.proccessing = NO;
                
                [self request:next anotherSource:anotherSource sync:sync selectHandler:selectHandler];
                
                return ;
            }
            
            NSArray *converted = [self.controller messageTableItemsFromMessages:[filter proccessResponse:result state:state next:next]];
            
            [self performCallback:selectHandler result:converted range:NSMakeRange(0, converted.count) controller:self];
            
        }];
        
        
    } synchronous:sync];
    
}


-(void)loadAroundMessagesWithMessage:(TL_localMessage *)message prevLimit:(int)prevLimit nextLimit:(int)nextLimit selectHandler:(selectHandler)selectHandler {
    
    
    [self.queue dispatchOnQueue:^{
        
        [self addMessageWithoutSavingState:message];
        
        [[Storage manager] addHolesAroundMessage:message];
        
        [[Storage manager] insertMessages:@[message]];
        
        
        NSMutableArray *prevResult = [NSMutableArray array];
        NSMutableArray *nextResult = [NSMutableArray array];
        
        self.proccessing = YES;
        [self loadAroundMessagesWithSelectHandler:selectHandler prevLimit:(int)prevLimit nextLimit:(int)nextLimit prevResult:prevResult nextResult:nextResult];
        
        
    } synchronous:YES];
    
    
}

-(void)loadAroundMessagesWithSelectHandler:(selectHandler)selectHandler prevLimit:(int)prevLimit nextLimit:(int)nextLimit prevResult:(NSMutableArray *)prevResult nextResult:(NSMutableArray *)nextResult {
    
    
    BOOL nextLoaded = nextResult.count >= nextLimit || self.nextState == ChatHistoryStateFull;
    BOOL prevLoaded = prevResult.count >= prevLimit || self.prevState == ChatHistoryStateFull;
    
    
    if((nextLoaded && prevLoaded) || (prevLoaded && self.nextState == ChatHistoryStateRemote && nextLimit == 1)) {
        
        NSArray *result = [self.filter selectAllItems];
        
        [self performCallback:selectHandler result:[self.controller messageTableItemsFromMessages:result] range:NSMakeRange(0, result.count) controller:self];
        
        self.proccessing = NO;
        return;
    }
    
    BOOL nextRequest = prevLoaded;
    
    
    [self.filter request:nextRequest callback:^(NSArray *result, ChatHistoryState state) {
        
        NSArray *converted = [self.filter proccessResponse:result state:state next:nextRequest];
        
        if(nextRequest) {
            [nextResult addObjectsFromArray:converted];
        } else {
            [prevResult addObjectsFromArray:converted];
        }
        
        
        [self loadAroundMessagesWithSelectHandler:selectHandler prevLimit:(int)prevLimit nextLimit:(int)nextLimit prevResult:prevResult nextResult:nextResult];
        
    }];
    
}




-(void)items:(NSArray *)msgIds complete:(void (^)(NSArray *list))complete {
    
    dispatch_queue_t dqueue = dispatch_get_current_queue();
    
    [queue dispatchOnQueue:^{
    
        NSMutableArray *items = [NSMutableArray array];
        
        [msgIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TL_localMessage *item = self.filter.messageKeys[obj];
            
            if(item != nil) {
                [items addObject:item];
            }
            
        }];
        
        dispatch_async(dqueue, ^{
            complete(items);
        });
        
    }];
}

-(void)updateItemId:(long)randomId withId:(int)n_id {
    [queue dispatchOnQueue:^{
        
        [listeners enumerateObjectsUsingBlock:^(WeakReference *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            ChatHistoryController *controller = obj.nonretainedObjectValue;
            
            NSArray *f = [controller.filter.messageItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.randomId = %ld",randomId]];
            TL_localMessage *message = [f firstObject];
            
            if(message) {
                [controller.filter.messageKeys removeObjectForKey:@(message.n_id)];
                message.n_id = n_id;
                controller.filter.messageKeys[@(message.n_id)] = message;
            }
            
        }];
        
       
        
    }];
}

-(void)updateMessageIds:(NSArray *)items {
    
    [items enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [_filters enumerateObjectsUsingBlock:^(HistoryFilter *filter, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(obj.peer_id == filter.peer_id) {
                TL_localMessage *message = filter.messageKeys[@(obj.n_id)];
                
                if(message != nil) {
                    [filter.messageItems removeObject:message];
                    [filter.messageItems addObject:obj];
                    filter.messageKeys[@(obj.n_id)] = obj;
                }
            }
            
        }];
        
        
        
    }];
}

-(int)itemsCount {
    __block int count = 0;
    
    [self.queue dispatchOnQueue:^{
        
        [_filters enumerateObjectsUsingBlock:^(HistoryFilter *obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            count+=obj.selectAllItems.count;
            
        }];
        
    } synchronous:YES];
    
    return count;
}


-(void)addItem:(MessageTableItem *)item {
    
    [self addItem:item conversation:self.conversation callback:nil sentControllerCallback:nil];
}


-(void)addItems:(NSArray *)items  conversation:(TL_conversation *)conversation {
    [self addItems:items conversation:conversation callback:nil sentControllerCallback:nil];
}

-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation  sentControllerCallback:(dispatch_block_t)sentControllerCallback {
     [self addItems:items conversation:conversation callback:nil sentControllerCallback:sentControllerCallback];
}

-(void)addItem:(MessageTableItem *)item sentControllerCallback:(dispatch_block_t)sentControllerCallback {
     [self addItem:item conversation:self.conversation callback:nil sentControllerCallback:sentControllerCallback];
}


-(void)addItem:(MessageTableItem *)item conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback sentControllerCallback:(dispatch_block_t)sentControllerCallback {
    
     dispatch_block_t block = ^ {
        [queue dispatchOnQueue:^{
            
            [item.messageSender addEventListener:self];
            
            
            [listeners enumerateObjectsUsingBlock:^(WeakReference *weak, NSUInteger idx, BOOL *stop) {
                
                ChatHistoryController *controller = weak.nonretainedObjectValue;
                
                NSArray *filtred =  [controller.filter filterAndAdd:@[item.message] latest:YES];;
                
                if(filtred.count > 0) {
                    
                    NSArray *copyItems = [controller.controller messageTableItemsFromMessages:filtred];
                    
                    [controller updateMessageIds:filtred];
                    
                    [[ASQueue mainQueue] dispatchOnQueue:^{
                        
                        [controller.controller receivedMessageList:copyItems inRange:NSMakeRange(0, filtred.count) itsSelf:YES];
                        
                        if(controller == self) {
                            if(sentControllerCallback)
                                sentControllerCallback();
                        }
                        
                    }];
                }
                
            }];
            
            item.messageSender.conversation.last_marked_message = item.message.n_id;
            item.messageSender.conversation.last_marked_date = item.message.date+1;
            
            [item.messageSender.conversation save];
            
            [item.messageSender send];
            
            [ASQueue dispatchOnMainQueue:^{
                if(callback != nil)
                    callback();
            }];
            
        }];
    };
    
    
    block();
}

-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback sentControllerCallback:(dispatch_block_t)sentControllerCallback {
    
    dispatch_block_t block = ^ {
        [queue dispatchOnQueue:^{
            
            MessageTableItem *item = [items lastObject];
            
            NSMutableArray *messages = [NSMutableArray array];
            
            [items enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [messages addObject:obj.message];
            }];
            
            [listeners enumerateObjectsUsingBlock:^(WeakReference *weak, NSUInteger idx, BOOL *stop) {
                
                ChatHistoryController *controller = weak.nonretainedObjectValue;
                
                NSArray *filtred = [controller.filter filterAndAdd:messages latest:YES];
                
                if(filtred.count > 0) {
                    
                    [controller updateMessageIds:filtred];

                    [[ASQueue mainQueue] dispatchOnQueue:^{
                        
                        [controller.controller receivedMessageList:[items reversedArray] inRange:NSMakeRange(0, items.count) itsSelf:YES];
                        
                        if(controller == self) {
                            if(sentControllerCallback)
                                sentControllerCallback();
                        }
                        
                    }];
                }
            }];
            
            conversation.last_marked_message = item.message.n_id;
            conversation.last_marked_date = item.message.date+1;
            
            [LoopingUtils runOnMainQueueAsync:^{
                if(callback != nil)
                    callback();
            }];
            
            
            if(items.count > 0) {
              //  MessageTableItem *item = [items lastObject];
                
                [items enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *item, NSUInteger idx, BOOL *stop) {
                    [item.messageSender addEventListener:self];
                    [item.messageSender send];
                }];
                
            }
            
        }];

    };
    
    block();
    
}

-(void)onStateChanged:(SenderItem *)sender {
    if(sender.state == MessageSendingStateSent) {
        
        void (^checkItem)(MessageTableItem *checkItem) = ^(MessageTableItem *checkItem) {
            
            
            
            [queue dispatchOnQueue:^{
                
                if(self.conversation.last_marked_message > TGMINFAKEID || self.conversation.last_marked_message < checkItem.message.n_id) {
                    
                    checkItem.messageSender.conversation.last_marked_message = checkItem.message.n_id;
                    checkItem.messageSender.conversation.last_marked_date = checkItem.message.date;
                    
                    [self.conversation save];
                    
               }
                
                if(![checkItem.message isKindOfClass:[TL_destructMessage class]]) {
                    
                    [listeners enumerateObjectsUsingBlock:^(WeakReference *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        ChatHistoryController *controller = obj.nonretainedObjectValue;
                        
                        [controller updateItemId:checkItem.message.randomId withId:checkItem.message.n_id];
                        
                    }];
                    
                }
                
                
            } synchronous:YES];
            
            
            [queue dispatchOnQueue:^{
                playSentMessage(YES);
            }];
            
        };
        
        
        if([sender isKindOfClass:[ForwardSenterItem class]]) {
            ForwardSenterItem *fSender = (ForwardSenterItem *) sender;
            
            [fSender.tableItems enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
                checkItem(obj);
            }];
            
        } else {
            checkItem(sender.tableItem);
        }
        
        
    }
}




-(void)drop:(BOOL)dropMemory {
    

    [queue dispatchOnQueue:^{
        [_filters removeAllObjects];
        _controller = nil;
        
    } synchronous:YES];
    
    _controller = nil;
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [Notification removeObserver:self];
   
    
}

-(TL_conversation *)conversation {
    return _conversation;
}

-(void)startChannelPolling {
    
}

-(void)startChannelPollingIfAlreadyStoped {
    
}

-(void)stopChannelPolling {
    
}

-(void)dealloc {
    
    __block NSUInteger index = NSNotFound;
    
    [listeners enumerateObjectsUsingBlock:^(WeakReference *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.originalObjectValue == (__bridge void *)(self)) {
            index = idx;
            *stop = YES;
        }
        
    }];
    
    assert(index != NSNotFound);
    
    [listeners removeObjectAtIndex:index];
    
    [queue dispatchOnQueue:^{
        [self drop:YES];
    } synchronous:YES];
}


@end
