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
#import "DocumentHistoryFilter.h"
#import "AudioHistoryFilter.h"
#import "TGTimer.h"
#import "TGProccessUpdates.h"
@interface ChatHistoryController ()


@property (nonatomic,strong) NSMutableArray * messageItems;
@property (nonatomic,strong) NSMutableDictionary * messageKeys;

@property (atomic)  dispatch_semaphore_t semaphore;
@property (atomic,assign) int requestCounter;


@end

@implementation ChatHistoryController

@synthesize messageItems = messageItems;
@synthesize messageKeys = messageKeys;


static NSMutableArray *filters;
static ASQueue *queue;
static NSMutableArray *listeners;

-(id)initWithController:(id<MessagesDelegate>)controller {
    if(self = [self initWithController:controller historyFilter:[HistoryFilter class]]) {
        
    }
    
    return self;
}



-(id)initWithController:(id<MessagesDelegate>)controller historyFilter:(Class)historyFilter {
    if(self = [super init]) {
        
        
        assert([NSThread isMainThread]);
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            queue = [[ASQueue alloc] initWithName:[NSStringFromClass([self class]) UTF8String]];
            
            filters = [[NSMutableArray alloc] init];
            [filters addObject:[HistoryFilter class]];
            [filters addObject:[PhotoHistoryFilter class]];
            [filters addObject:[PhotoVideoHistoryFilter class]];
            [filters addObject:[DocumentHistoryFilter class]];
            [filters addObject:[VideoHistoryFilter class]];
            [filters addObject:[AudioHistoryFilter class]];
            
            listeners = [[NSMutableArray alloc] init];
        });
        
        
        [queue dispatchOnQueue:^{
            
            [listeners addObject:self];
            
        } synchronous:YES];
        
        

        
       // self.controller.conversation = conversation;
        _controller = controller;
        
        
        self.semaphore = dispatch_semaphore_create(1);
        
        _selectLimit = 50;
        self.filter = [[historyFilter alloc] initWithController:self];
        _need_save_to_db = YES;
        
        
        
        [Notification addObserver:self selector:@selector(notificationReceiveMessages:) name:MESSAGE_LIST_RECEIVE];
        
        [Notification addObserver:self selector:@selector(notificationReceiveMessage:) name:MESSAGE_RECEIVE_EVENT];
        
        [Notification addObserver:self selector:@selector(notificationDeleteMessage:) name:MESSAGE_DELETE_EVENT];
        
        [Notification addObserver:self selector:@selector(notificationFlushHistory:) name: MESSAGE_FLUSH_HISTORY];
        
        [Notification addObserver:self selector:@selector(notificationDeleteObjectMessage:) name:DELETE_MESSAGE];
        

    }
    
    return self;
}


-(void)notificationReceiveMessages:(NSNotification *)notify {
    
    [queue dispatchOnQueue:^{
        
       
            
            NSArray *list = notify.object;
            
        
            
            list = [[self filterAndAdd:[self.controller messageTableItemsFromMessages:list] isLates:YES] mutableCopy];
        
        
            [listeners enumerateObjectsUsingBlock:^(ChatHistoryController *controller, NSUInteger idx, BOOL *stop) {
                
                NSMutableArray *accepted = [[NSMutableArray alloc] init];
                NSMutableArray *ignored = [[NSMutableArray alloc] init];
            
                [list enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
                    if(controller.controller.conversation.peer.peer_id == obj.message.peer_id) {
                        [accepted addObject:obj];
                    } else {
                        [ignored addObject:obj];
                    }
                }];
                
                
                if(accepted.count == 0) {
                    
                    [ASQueue dispatchOnMainQueue:^{
                        [controller.controller didAddIgnoredMessages:ignored];
                    }];
                    return;
                }
                
                NSArray *items = [controller selectAllItems];
                
                int pos = (int) [items indexOfObject:accepted[0]];
                
                
                NSRange range = NSMakeRange(pos, accepted.count);
                
                
                accepted = [accepted mutableCopy];
                [SelfDestructionController addMessages:accepted];
                
                [[ASQueue mainQueue] dispatchOnQueue:^{
                    [controller.controller receivedMessageList:accepted inRange:range itsSelf:NO];
                }];
                
                
            }];
    }];
    
}


- (BOOL)isFiltredAccepted:(int)filterType {
    return  (self.filter.class == HistoryFilter.class || (filterType & [self.filter type]) > 0);
}


-(void)setMin_id:(int)min_id {
    self->_min_id = min_id;
    _server_min_id = min_id;
}

-(void)setMax_id:(int)max_id {
    _max_id = max_id;
    _server_max_id = max_id;
}

-(void)setStart_min:(int)start_min {
    _start_min = start_min;
    _server_start_min = start_min;
}

-(void)notificationDeleteMessage:(NSNotification *)notification {
    
    self.isProccessing = YES;
    
    [queue dispatchOnQueue:^{
        
        NSArray *msgs = [notification.userInfo objectForKey:KEY_MESSAGE_ID_LIST];
        
        if(msgs.count == 0)
            return;
        
        for (Class filterClass in filters) {
            [filterClass removeItems:msgs];
        }
        
        [listeners enumerateObjectsUsingBlock:^(ChatHistoryController *obj, NSUInteger idx, BOOL *stop) {
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                [obj.controller deleteMessages:msgs];
                
            }];

        }];
        
        
        
        self.isProccessing = NO;
    }];
    
}

-(void)setIsProccessing:(BOOL)isProccessing {
    self->_isProccessing = isProccessing;
    
    [self.controller updateLoading];
}

-(void)notificationFlushHistory:(NSNotification *)notification {
    
    self.isProccessing = YES;
    
    [queue dispatchOnQueue:^{
        
        
        TL_conversation *conversation = [notification.userInfo objectForKey:KEY_DIALOG];
        
        for (Class filterClass in filters) {
            [filterClass removeAllItems:conversation.peer.peer_id];
        }
        
        
        [listeners enumerateObjectsUsingBlock:^(ChatHistoryController *controller, NSUInteger idx, BOOL *stop) {
       
            if(controller.controller.conversation == conversation) {
                
                [[ASQueue mainQueue] dispatchOnQueue:^{
                    [controller.controller flushMessages];
                }];
                
            }
            
        }];
        
        self.isProccessing = NO;
    }];
    
}

-(void)notificationDeleteObjectMessage:(NSNotification *)notification {
    
    [queue dispatchOnQueue:^{
        TLMessage *msg = [notification.userInfo objectForKey:KEY_MESSAGE];
        
        [messageItems enumerateObjectsUsingBlock:^(MessageTableItem * obj, NSUInteger idx, BOOL *stop) {
            if(obj.message == msg) {
                [messageItems removeObject:obj];
                *stop = YES;
            }
        }];
    }];
    
}


-(void)notificationReceiveMessage:(NSNotification *)notification {
    
    [queue dispatchOnQueue:^{
        
        
        TL_localMessage *message = [notification.userInfo objectForKey:KEY_MESSAGE];
        
        // [self markAsReceived:[message n_id]];
        
        if(!message || self.prevState != ChatHistoryStateFull)
            return;
        
        MessageTableItem *tableItem = (MessageTableItem *) [[self.controller messageTableItemsFromMessages:@[message]] lastObject];
        
        NSArray *res = [self filterAndAdd:@[tableItem] isLates:YES];
        
        [listeners enumerateObjectsUsingBlock:^(ChatHistoryController *obj, NSUInteger idx, BOOL *stop) {
            
             if(message.peer_id == obj.controller.conversation.peer.peer_id) {
                
                NSArray *items = [obj selectAllItems];
                
                int position = (int) [items indexOfObject:tableItem];
                
                if(res.count == 1) {
                    
                    [SelfDestructionController addMessages:@[message]];
                    
                    [[ASQueue mainQueue] dispatchOnQueue:^{
                        
                        if([obj isFiltredAccepted:message.filterType]) {
                            [obj.controller receivedMessage:tableItem position:position itsSelf:NO];
                        }
                    
                    }];
                }
            } else {
                [ASQueue dispatchOnMainQueue:^{
                    [obj.controller didAddIgnoredMessages:@[tableItem]];
                }];
            }
            
        }];
        
    }];
    
}


-(NSArray *)filterAndAdd:(NSArray *)items isLates:(BOOL)isLatest {
    
    __block  NSMutableArray *filtred;
    
    filtred = [[NSMutableArray alloc] init];
    
    for (Class filterClass in filters) {
        
        NSMutableArray *filterItems = [filterClass messageItems];
        NSMutableDictionary *filterKeys = [filterClass messageKeys];
        
        [items enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
            
            BOOL needAdd = [filterItems indexOfObject:obj] == NSNotFound;
            
            //  здесь лучше бы подумать над условием, мб что нибудь в голову придет, пока так.
          
            if( ((filterClass == HistoryFilter.class && self.filter.class == HistoryFilter.class) ||
                 (filterClass == HistoryFilter.class && isLatest)) ||
               (filterClass != HistoryFilter.class && obj.message.filterType & [filterClass type]) > 0) {
                
                
                if(obj.message.n_id != 0) {
                    id saved = filterKeys[@(obj.message.n_id)];
                    if(!saved) {
                        filterKeys[@(obj.message.n_id)] = obj;
                    } else {
                        needAdd = NO;
                    }
                }
                
                if(needAdd) {
                    [filterItems addObject:obj];
                    
                    if(self.filter.class == filterClass) {
                        [filtred addObject:obj];
                    }
                }
            }
        }];
        
    }
    
    
   return filtred;
    
}


-(void)performCallback:(selectHandler)selectHandler result:(NSArray *)result range:(NSRange )range {
   
   [[ASQueue mainQueue] dispatchOnQueue:^{
        
       long fwd_group_random = 0;
        
        NSMutableArray *fwd = [[NSMutableArray alloc] init];
        
        dispatch_block_t fwd_block = ^ {
            ForwardSenterItem *sender = [[ForwardSenterItem alloc] init];
            MessageTableItem *msg = fwd[0];
            sender.conversation = msg.message.conversation;
            
            NSMutableArray *fakes = [[NSMutableArray alloc] init];
            NSMutableArray *ids = [[NSMutableArray alloc] init];
            [fwd enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
                [ids addObject:@([(TL_localMessageForwarded *)obj.message fwd_n_id])];
                [fakes insertObject:obj.message atIndex:0];
            }];
            
            sender.msg_ids = ids;
            
            sender.fakes = fakes;
            
            
           
            
            sender.state = msg.message.dstate == DeliveryStateError ? MessageSendingStateError : MessageStateWaitSend;
            
            [sender setTableItems:fwd];
            
            if(msg.message.dstate == DeliveryStatePending) {
                [msg.messageSender send];
            }
            
            [fwd removeAllObjects];
            
        };
        

        for (int i = (int) result.count - 1; i >= 0; i --) {
            
            
            MessageTableItem *item = result[i];
            
             if((item.message.dstate == DeliveryStateError || item.message.dstate == DeliveryStatePending) && !item.messageSender) {
                
                
                if(item.message.dstate == DeliveryStatePending && [item.message isKindOfClass:[TL_localMessageForwarded class]]) {
                
                    if(fwd_group_random != 0 && fwd_group_random != item.message.randomId)
                        fwd_block();
                    
                    [fwd addObject:item];
                    
                    fwd_group_random = item.message.randomId;
                    
                    continue;
                }
                
                if(fwd.count > 0) {
                    fwd_block();
                }
                
                
                
                item.messageSender = [SenderItem senderForMessage:item.message];
                item.messageSender.state = item.message.dstate == DeliveryStateError ? MessageSendingStateError : MessageStateWaitSend;
                item.messageSender.tableItem = item;
                
                if(item.message.dstate == DeliveryStatePending) {
                    [item.messageSender send];
                }
            }
        }

        
        if(fwd.count > 0)
            fwd_block();
        
        self.isProccessing = NO;
        if(selectHandler)
            selectHandler(result,range);
    }];
    
    for (MessageTableItem *item in result) {
        [SelfDestructionController addMessages:@[item.message]];
    }
}


-(void)setFilter:(HistoryFilter *)filter {
    self->_filter = filter;
    messageKeys = [filter messageKeys];
    messageItems = [filter messageItems];
    self.requestCounter = 0;
    
    _start_min = _min_id = self.controller.conversation.last_marked_message == 0 ? self.controller.conversation.top_message : self.controller.conversation.last_marked_message;
    _max_id =  0;
    
    _maxDate = [[MTNetwork instance] getTime];
    _minDate = self.controller.conversation.last_marked_date;
    
    [queue dispatchOnQueue:^{
        NSArray *items = [self selectAllItems];
        
        if(items.count > 0) {
            MessageTableItem *item = items[0];
            
            if(self.filter.class == HistoryFilter.class && item.message.n_id != self.controller.conversation.top_message) {
                [[self.filter class] removeAllItems:self.controller.conversation.peer.peer_id];
            }
        }
        
    } synchronous:YES];
    
    _nextState = ChatHistoryStateCache;
    _prevState = ChatHistoryStateCache;

}



-(void)request:(BOOL)next anotherSource:(BOOL)anotherSource sync:(BOOL)sync selectHandler:(selectHandler)selectHandler {
    
    [queue dispatchOnQueue:^{
        
        if([self checkState:ChatHistoryStateFull next:next] || self.isProccessing) {
            return;
        }
        
        
        self.isProccessing = YES;
        
        
        BOOL notify = NO;
    
        
        NSArray *allItems;
        
        
        if( [self checkState:ChatHistoryStateCache next:next]) {
            
            
            allItems = [self selectAllItems];
            
            
            
            NSMutableArray *memory = [[NSMutableArray alloc] init];
            
            [allItems enumerateObjectsUsingBlock:^(MessageTableItem * obj, NSUInteger idx, BOOL *stop) {
                
                if((self.filter.type & obj.message.filterType) > 0) {
                    
                    int source_date = next ? _maxDate : _minDate;
                    
                    if(next) {
                        
                        if(obj.message.date <= source_date)
                            [memory addObject:obj];
                    } else {
                        if(obj.message.date >= source_date )
                            [memory addObject:obj];
                    }
                    
                    
                }
            }];
            
            
            if(memory.count >= _selectLimit) {
                NSUInteger location = next ? 0 : (memory.count-_selectLimit);
                memory = [[memory subarrayWithRange:NSMakeRange(location, _selectLimit)] mutableCopy];
                
                MessageTableItem *lastItem = [memory lastObject];
            
                NSArray *merge = [[allItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.message.date == %d",lastItem.message.date]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self IN %@)",memory]];
                
                [memory addObjectsFromArray:merge];
                
            } else {
                
                ChatHistoryState state;
                
                if(!next) {
                    state = self.filter.class == HistoryFilter.class && ( _max_id == 0 || (_min_id >= self.controller.conversation.sync_message_id && self.controller.conversation.sync_message_id != 0) || self.controller.conversation.type == DialogTypeSecretChat || self.controller.conversation.type == DialogTypeBroadcast) ? ChatHistoryStateLocal : ChatHistoryStateRemote;
                } else {
                    state = self.filter.class == HistoryFilter.class || self.controller.conversation.type == DialogTypeSecretChat || self.controller.conversation.type == DialogTypeBroadcast ? ChatHistoryStateLocal : ChatHistoryStateRemote;
                }
                
                [self setState:state next:next];
            }
            
            if(memory.count > 0)
                notify = YES;
            
            
            [self saveId:memory next:next];
            
            if((!next && _min_id == self.controller.conversation.top_message)) {
                [self setState:ChatHistoryStateFull next:next];
                
                notify = YES;
            }
            
            
            if(notify)
                [self performCallback:selectHandler result:memory range:NSMakeRange(0, memory.count)];
            
        }
        
        
        
        if(anotherSource && !notify) {
            
            if([self checkState:ChatHistoryStateLocal next:next]) {
                
                
                [_filter storageRequest:next callback:^(NSArray *result) {
                    [[MessagesManager sharedManager] add:result];
                    
                    
                    NSArray *converted = [self filterAndAdd:[self.controller messageTableItemsFromMessages:result] isLates:NO];
                        
                    converted = [self sortItems:converted];
                    
                    [self saveId:converted next:next];
                    
                    
                    if(result.count < _selectLimit) {
                        [self setState: self.controller.conversation.type != DialogTypeSecretChat && self.controller.conversation.type != DialogTypeBroadcast ? ChatHistoryStateRemote : ChatHistoryStateFull next:next];
                        
                        if(!next && (_min_id) == self.controller.conversation.top_message) {
                            [self setState:ChatHistoryStateFull next:NO];
                        }
                    }
                    
                    [self performCallback:selectHandler result:converted range:NSMakeRange(0, converted.count)];
                    
                    
                    
                }];
                
                
                
            } else if([self checkState:ChatHistoryStateRemote next:next]) {
                
                [_filter remoteRequest:next callback:^(id response) {
                    
                    [TL_localMessage convertReceivedMessages:[response messages]];
                    
                    [TGProccessUpdates checkAndLoadIfNeededSupportMessages:[response messages] asyncCompletionHandler:^{
                        
                        [queue dispatchOnQueue:^{
                            
                            if(!self.controller.conversation)
                                return;
                            
                            
                            NSArray *messages = [[response messages] copy];
                            
                            if(_filter.class != HistoryFilter.class || !_need_save_to_db) {
                                [[response messages] removeAllObjects];
                            }
                            
                            
                            TL_localMessage *sync_message = [[response messages] lastObject];
                            
                            if(sync_message) {
                                self.controller.conversation.sync_message_id = sync_message.n_id;
                                [self.controller.conversation save];
                            }
                            
                            
                            if(!next) {
                                
                                TL_localMessage *last;
                                if(messages.count > 0)
                                    last = messages[0];
                                
                                ChatHistoryState old_state = _prevState;
                                ChatHistoryState new_state = self.filter.class == HistoryFilter.class && (last && (last.n_id >= self.controller.conversation.sync_message_id && self.controller.conversation.sync_message_id != 0) ) ? ChatHistoryStateLocal : ChatHistoryStateRemote;
                                [self setState:new_state next:next];
                                
                                if(old_state != new_state && new_state == ChatHistoryStateLocal) {
                                    NSMutableArray *copy = [messages mutableCopy];
                                    
                                    [messages enumerateObjectsUsingBlock:^(TL_localMessage  *obj, NSUInteger idx, BOOL *stop) {
                                        if(obj.n_id <= self.controller.conversation.sync_message_id)
                                            [copy removeObject:obj];
                                    }];
                                    
                                    messages = copy;
                                }
                                
                            }
                            
                            
                            
                            [SharedManager proccessGlobalResponse:response];
                            
                            for (TL_localMessage *message in messages) {
                                if([message.media isKindOfClass:[TL_messageMediaPhoto class]] || [message.media isKindOfClass:[TL_messageMediaVideo class]]) {
                                    [[Storage manager] insertMedia:message];
                                    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:message.n_id media:message peer_id:message.peer_id];
                                    [Notification perform:MEDIA_RECEIVE data:@{KEY_PREVIEW_OBJECT:previewObject}];
                                }
                            }
                            
                            NSArray *converted = [self filterAndAdd:[self.controller messageTableItemsFromMessages:messages] isLates:NO];
                            
                            converted = [self sortItems:converted];
                            
                            [self saveId:converted next:next];
                            
                            
                            
                            
                            if(next && converted.count <  (_selectLimit-1)) {
                                [self setState:ChatHistoryStateFull next:next];
                            }
                            
                            if(!next && (_min_id) == self.controller.conversation.top_message) {
                                [self setState:ChatHistoryStateFull next:next];
                            }
                            
                            self.filter.request = nil;
                            
                            [self performCallback:selectHandler result:converted range:NSMakeRange(0, converted.count)];
                        }];
                        
                    }];
                    
                    
                    
                }];
                
            }
            
        }

    } synchronous:sync];
    
}

-(BOOL)checkState:(ChatHistoryState)state next:(BOOL)next {
    return next ? _nextState == state : _prevState == state;
}

-(void)setState:(ChatHistoryState)state next:(BOOL)next {
    if(next)
        _nextState = state;
    else
        _prevState = state;
}


-(void)saveId:(NSArray *)source next:(BOOL)next {
   
   
    if(source.count > 0)  {
        
        if(next || _start_min == _min_id) {
            BOOL localSaved = NO;
            BOOL serverSaved = NO;
            for (int i = (int) source.count-1; i >= 0; i--) {
                if(!localSaved) {
                    _max_id = [[(MessageTableItem *)source[i] message] n_id];
                    _maxDate = [[(MessageTableItem *)source[i] message] date]-1;
                    localSaved = YES;
                }
                
                if(!serverSaved && [[(MessageTableItem *)source[i] message] n_id] != 0 && [[(MessageTableItem *)source[i] message] n_id] < TGMINFAKEID) {
                    _server_max_id = [[(MessageTableItem *)source[i] message] n_id];
                    serverSaved = YES;
                }
                
                if(localSaved && serverSaved)
                    break;
                
            }
            
        }
        
        if(!next) {
            BOOL localSaved = NO;
            BOOL serverSaved = NO;
            
            for (MessageTableItem *item in source) {
                if(!localSaved) {
                    _min_id = [item.message n_id];
                    _minDate = [item.message date]+1;
                    localSaved = YES;
                }
                
                if(!serverSaved && item.message.n_id != 0 && item.message.n_id < TGMINFAKEID) {
                    _server_min_id = [item.message n_id];
                    serverSaved = YES;
                }
                
                
            }
        }
        
    }

}





-(NSArray *)selectAllItems {

    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.message.peer_id == %d",self.controller.conversation.peer.peer_id]];
    
    NSArray *memory = [messageItems
                       filteredArrayUsingPredicate:predicate];
    
    memory = [self sortItems:memory];
    
    
   
    
    return memory;
}


-(NSArray *)sortItems:(NSArray *)sort {
    return [sort sortedArrayUsingComparator:^NSComparisonResult(MessageTableItem *obj1, MessageTableItem *obj2) {
        return (obj1.message.date < obj2.message.date ? NSOrderedDescending : (obj1.message.date > obj2.message.date ? NSOrderedAscending : (obj1.message.n_id < obj2.message.n_id ? NSOrderedDescending : NSOrderedAscending)));
    }];
}

-(void)removeAllItems {
    for (Class filterClass in filters) {
        [filterClass removeAllItems:self.controller.conversation.peer.peer_id];
    }
}


-(int)posAtMessage:(TLMessage *)message {
    
   
    NSArray *memoryItems = [self selectAllItems];
    
    
    int pos = 0;
    if(memoryItems.count > 0) {
        pos = [self posInArray:memoryItems date:message.date n_id:message.n_id];
    }
    
    return pos;
}


-(void)addItem:(MessageTableItem *)item {
    
    [self addItem:item conversation:self.controller.conversation callback:nil sentControllerCallback:nil];
}


-(void)addItems:(NSArray *)items  conversation:(TL_conversation *)conversation {
    [self addItems:items conversation:conversation callback:nil sentControllerCallback:nil];
}

-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation  sentControllerCallback:(dispatch_block_t)sentControllerCallback {
     [self addItems:items conversation:conversation callback:nil sentControllerCallback:sentControllerCallback];
}

-(void)addItem:(MessageTableItem *)item sentControllerCallback:(dispatch_block_t)sentControllerCallback {
     [self addItem:item conversation:self.controller.conversation callback:nil sentControllerCallback:sentControllerCallback];
}


-(void)addItem:(MessageTableItem *)item conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback sentControllerCallback:(dispatch_block_t)sentControllerCallback {
    
    
    dispatch_block_t block = ^ {
        [queue dispatchOnQueue:^{
            
            [item.messageSender addEventListener:self];
            
             NSArray *added =  [self filterAndAdd:@[item] isLates:YES];
             if(added.count == 1 && self.filter.class == [HistoryFilter class] && item.messageSender.conversation.peer.peer_id == self.controller.conversation.peer.peer_id) {
                
                 [[ASQueue mainQueue] dispatchOnQueue:^{
                    [self.controller receivedMessage:item position:0 itsSelf:YES];
               
                
                if(sentControllerCallback)
                    sentControllerCallback();
                    
                }];
             }
            
           
            
            item.messageSender.conversation.last_marked_message = item.message.n_id;
            item.messageSender.conversation.last_marked_date = item.message.date+1;
            
            [item.messageSender.conversation save];
            
            
            [LoopingUtils runOnMainQueueAsync:^{
                if(callback != nil)
                    callback();
            }];
            
            [item.messageSender send];
            
        }];
    };
    
    
    block();
}

-(void)addItems:(NSArray *)items conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback sentControllerCallback:(dispatch_block_t)sentControllerCallback {
    
    dispatch_block_t block = ^ {
        [queue dispatchOnQueue:^{
            
            NSArray *filtred =  [self filterAndAdd:items isLates:YES];
            
            MessageTableItem *item = [items lastObject];
            
            NSRange range = NSMakeRange(0, filtred.count);
            if(filtred.count == items.count && self.filter.class == [HistoryFilter class] && item.messageSender.conversation.peer.peer_id == self.controller.conversation.peer.peer_id) {
                [[ASQueue mainQueue] dispatchOnQueue:^{
                    
                    [self.controller receivedMessageList:filtred inRange:range itsSelf:YES];
                    
                    if(sentControllerCallback)
                        sentControllerCallback();
                    
                }];
            }
            
            
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
                
                if(self.controller.conversation.last_marked_message > TGMINFAKEID || self.controller.conversation.last_marked_message < checkItem.message.n_id) {
                    
                    checkItem.messageSender.conversation.last_marked_message = checkItem.message.n_id;
                    checkItem.messageSender.conversation.last_marked_date = checkItem.message.date;
                    
                    [self.controller.conversation save];
                    
                    [messageItems removeObject:checkItem];
                    [messageKeys removeObjectForKey:@(checkItem.message.n_id)];
                    
                    [self filterAndAdd:@[checkItem] isLates:YES];
                    
                    
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


-(int)posInArray:(NSArray *)list date:(int)date n_id:(int)n_id {
    int pos = 0;
    
    
    
    while (pos+1 < list.count &&
           ([((MessageTableItem *)list[pos]).message date] > date ||
            ([((MessageTableItem *)list[pos]).message date] == date && [((MessageTableItem *)list[pos]).message n_id] > n_id)))
        pos++;
    
    return pos;
}

-(void)drop:(BOOL)dropMemory {
    
    if(dropMemory) {
        [queue dispatchOnQueue:^{
            [self removeAllItems];
        } synchronous:YES];
    }
    
    self.filter.controller = nil;
    _filter = nil;
    _controller = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [Notification removeObserver:self];
    [listeners removeObject:self];
    
}

-(TL_conversation *)conversation {
    return _controller.conversation;
}

-(void)dealloc {
    
    [queue dispatchOnQueue:^{
        [self drop:NO];
    } synchronous:YES];
}

+(void)drop {
    [HistoryFilter drop];
}

@end
