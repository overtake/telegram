

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
@interface ChatHistoryController () <TGChannelPollingDelegate>


@property (nonatomic,strong) NSMutableArray * messageItems;
@property (nonatomic,strong) NSMutableDictionary * messageKeys;

@property (atomic)  dispatch_semaphore_t semaphore;
@property (atomic,assign) int requestCounter;
@property (nonatomic,strong) HistoryFilter *h_filter;
@property (atomic,assign) BOOL proccessing;

@property (nonatomic,strong) TL_conversation *conversation;

@end

@implementation ChatHistoryController

@synthesize messageItems = messageItems;
@synthesize messageKeys = messageKeys;


static NSMutableArray *filters;
static ASQueue *queue;
static NSMutableArray *listeners;





-(id)initWithController:(id<MessagesDelegate>)controller historyFilter:(Class)historyFilter {
    if(self = [super init]) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            queue = [ASQueue globalQueue];
            
            filters = [[NSMutableArray alloc] init];
            [filters addObject:[HistoryFilter class]];
            [filters addObject:[PhotoHistoryFilter class]];
            [filters addObject:[PhotoVideoHistoryFilter class]];
            [filters addObject:[DocumentHistoryFilter class]];
            [filters addObject:[VideoHistoryFilter class]];
            [filters addObject:[AudioHistoryFilter class]];
            [filters addObject:[MP3HistoryFilter class]];
            [filters addObject:[SharedLinksHistoryFilter class]];
            [filters addObject:[ChannelFilter class]];
            [filters addObject:[ChannelImportantFilter class]];
            listeners = [[NSMutableArray alloc] init];
            
            
        });
        
        _conversation = [controller conversation];
        
        
        [queue dispatchOnQueue:^{
            
            [listeners addObject:[WeakReference weakReferenceWithObject:self]];
            
       
            // self.conversation = conversation;
            _controller = controller;
            
            
            self.semaphore = dispatch_semaphore_create(1);
            
            self.selectLimit = 50;
            
            [self setFilter:[[historyFilter alloc] initWithController:self]];
            _need_save_to_db = YES;
        

         } synchronous:YES];
        
        [Notification addObserver:self selector:@selector(notificationReceiveMessages:) name:MESSAGE_LIST_RECEIVE];
        
        [Notification addObserver:self selector:@selector(notificationReceiveMessage:) name:MESSAGE_RECEIVE_EVENT];
        
        [Notification addObserver:self selector:@selector(notificationDeleteMessage:) name:MESSAGE_DELETE_EVENT];
        
        [Notification addObserver:self selector:@selector(notificationFlushHistory:) name: MESSAGE_FLUSH_HISTORY];
        
        [Notification addObserver:self selector:@selector(notificationDeleteObjectMessage:) name:DELETE_MESSAGE];
        
        [Notification addObserver:self selector:@selector(notificationUpdateMessageId:) name:MESSAGE_UPDATE_MESSAGE_ID];
        
    }
    
    return self;
}


-(ASQueue *)queue {
    return queue;
}

-(NSUInteger)selectLimit {
    return 20;
}





-(void)addItemWithoutSavingState:(MessageTableItem *)item {
    
    [queue dispatchOnQueue:^{
        
        [self filterAndAdd:@[item] isLates:NO];

    
    }];
}

-(void)notificationReceiveMessages:(NSNotification *)notify {
    
    [queue dispatchOnQueue:^{
        
            NSArray *list = notify.object;
        
            list = [[self filterAndAdd:[self.controller messageTableItemsFromMessages:list] isLates:YES] mutableCopy];
        
        
            [listeners enumerateObjectsUsingBlock:^(WeakReference *weak, NSUInteger idx, BOOL *stop) {
                
                ChatHistoryController *controller = [weak nonretainedObjectValue];
                
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
                
                
                NSRange range = NSMakeRange(pos+1, accepted.count);
                
                
                accepted = [accepted mutableCopy];
                [SelfDestructionController addMessages:accepted];
                
                [[ASQueue mainQueue] dispatchOnQueue:^{
                    [controller.controller receivedMessageList:accepted inRange:range itsSelf:NO];
                }];
                
                
            }];
    }];
    
}


- (BOOL)isFiltredAccepted:(int)filterType {
    return  (filterType & [self.filter type]) > 0;
}


-(void)notificationDeleteMessage:(NSNotification *)notification {
    
    
    [queue dispatchOnQueue:^{
        
        self.proccessing = YES;
        
        NSArray *updateData = [notification.userInfo objectForKey:KEY_DATA];
        
        if(updateData.count == 0)
            return;
        
        NSMutableDictionary *dItems = [[NSMutableDictionary alloc] init];
        
        
        [updateData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            
            for (Class filterClass in filters) {
                
                id item = [filterClass removeItemWithMessageId:[obj[KEY_MESSAGE_ID] intValue] withPeer_id:[obj[KEY_PEER_ID] intValue]];
                
                if(item) {
                    NSMutableArray *items = dItems[NSStringFromClass(filterClass)];
                    
                    if(!items)
                    {
                        items = [NSMutableArray array];
                        dItems[NSStringFromClass(filterClass)] = items;
                    }
                    
                    [items addObject:item];
                }
                
            
                
            }
            
        }];
        
        
        
        [listeners enumerateObjectsUsingBlock:^(WeakReference *weak, NSUInteger idx, BOOL *stop) {
            
            ChatHistoryController *obj = [weak nonretainedObjectValue];
            
            NSArray * td = dItems[obj.filter.className];
            
            td = [td filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.message.peer_id == %d", obj.conversation.peer_id]];
            
            NSMutableArray *msgIds = [[NSMutableArray alloc] init];
            
            [td enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
                [msgIds addObject:@(obj.message.n_id)];
            }];
            
            if(td.count > 0) {
                [[ASQueue mainQueue] dispatchOnQueue:^{
                    [obj.controller deleteItems:td orMessageIds:msgIds];
                }];
            }

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
        
        for (Class filterClass in filters) {
            [filterClass removeAllItems:conversation.peer.peer_id];
        }
        
        
        [listeners enumerateObjectsUsingBlock:^(WeakReference *weak, NSUInteger idx, BOOL *stop) {
            
            ChatHistoryController *controller = [weak nonretainedObjectValue];
       
            if(controller.controller.conversation == conversation) {
                
                [[ASQueue mainQueue] dispatchOnQueue:^{
                    [controller.controller flushMessages];
                }];
                
            }
            
        }];
        
         self.proccessing = NO;
        
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
        
        if(!tableItem)
            return;
        
        NSArray *res = [self filterAndAdd:@[tableItem] isLates:YES];
        
        [listeners enumerateObjectsUsingBlock:^(WeakReference *weak, NSUInteger idx, BOOL *stop) {
            
            ChatHistoryController *obj = [weak nonretainedObjectValue];
            
             if(message.peer_id == obj.controller.conversation.peer_id) {
                
                NSArray *items = [obj selectAllItems];
                
                int position = (int) [items indexOfObject:tableItem];
                
                if(res.count == 1) {
                    
                    [SelfDestructionController addMessages:@[message]];
                    
                    [[ASQueue mainQueue] dispatchOnQueue:^{
                        
                        if([obj isFiltredAccepted:message.filterType]) {
                            [obj.controller receivedMessage:tableItem position:position+1 itsSelf:NO];
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

-(void)notificationUpdateMessageId:(NSNotification *)notification {
    
    [queue dispatchOnQueue:^{
        
        [messageItems enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
            
            int n_id = [notification.userInfo[KEY_MESSAGE_ID] intValue];
            long random_id = [notification.userInfo[KEY_RANDOM_ID] longValue];
            
            if(obj.message.randomId == random_id) {
                
                [messageKeys removeObjectForKey:@(obj.message.n_id)];
                [messageKeys setObject:obj forKey:@(n_id)];
                
                obj.message.n_id = n_id;
                
            }
            
        }];
        
    }];
    
}


-(NSArray *)filterAndAdd:(NSArray *)items isLates:(BOOL)isLatest {
    
    __block  NSMutableArray *filtred;
    
    filtred = [[NSMutableArray alloc] init];
    
    for (Class filterClass in filters) {
        
       [items enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
            
            
            NSMutableArray *filterItems = [filterClass messageItems:obj.message.peer_id];
            NSMutableDictionary *filterKeys = [filterClass messageKeys:obj.message.peer_id];
            
            BOOL needAdd = [filterItems indexOfObject:obj] == NSNotFound;
            
            //  здесь лучше бы подумать над условием, мб что нибудь в голову придет, пока так.
          
            if( ((filterClass == HistoryFilter.class && (self.filter.class == HistoryFilter.class || self.filter.class == ChannelFilter.class || self.filter.class == ChannelImportantFilter.class)) ||
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
   
    
    self.proccessing = NO;
    
   [[ASQueue mainQueue] dispatchOnQueue:^{
        
       if(selectHandler)
            selectHandler(result,range);
    }];
    
    for (MessageTableItem *item in result) {
        [SelfDestructionController addMessages:@[item.message]];
    }
}

-(HistoryFilter *)filter {
    return _h_filter;
}

-(void)setFilter:(HistoryFilter *)filter {
    
    [queue dispatchOnQueue:^{
    
        _h_filter = filter;
        messageKeys = [filter messageKeys:self.conversation.peer_id];
        messageItems = [filter messageItems:self.conversation.peer_id];
        _requestCounter = 0;
        
        _start_min = _min_id = self.conversation.last_marked_message == 0 ? self.conversation.top_message : self.conversation.last_marked_message;
        _max_id =  0;
        
        _maxDate = [[MTNetwork instance] getTime];
        _minDate = self.conversation.last_marked_date+1;

        
        NSArray *items = [self selectAllItems];
        
        if(items.count > 0) {
            MessageTableItem *item = items[0];
            
            if(self.filter.class == HistoryFilter.class && (item.message.n_id != self.conversation.top_message && item.message.n_id < TGMINFAKEID)) {
                [[self.filter class] removeAllItems:self.conversation.peer.peer_id];
            }
        }
        
        _nextState = ChatHistoryStateCache;
        _prevState = ChatHistoryStateCache;
         
    } synchronous:YES];

}



-(void)request:(BOOL)next anotherSource:(BOOL)anotherSource sync:(BOOL)sync selectHandler:(selectHandler)selectHandler {
    
    [queue dispatchOnQueue:^{
        
        
        
        if([self checkState:ChatHistoryStateFull next:next] || self.isProccessing) {
            return;
        }
        
        
        self.proccessing = YES;
        
        
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
            
            
            if(memory.count >= self.selectLimit) {
                
                NSUInteger location = next ? 0 : (memory.count-self.selectLimit);
                memory = [[memory subarrayWithRange:NSMakeRange(location, self.selectLimit)] mutableCopy];
                
                MessageTableItem *lastItem = [memory lastObject];
                
                NSArray *merge = [[allItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.message.date == %d",lastItem.message.date]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self IN %@)",memory]];
                
                [memory addObjectsFromArray:merge];
                
            } else {
                
                ChatHistoryState state;
                
                if(!next) {
                    state = self.filter.class == HistoryFilter.class && ( _max_id == 0 || (_min_id >= self.conversation.sync_message_id && self.conversation.sync_message_id != 0) || self.conversation.type == DialogTypeSecretChat || self.conversation.type == DialogTypeBroadcast) ? ChatHistoryStateLocal : ChatHistoryStateRemote;
                    
                } else {
                    state = (self.filter.class == HistoryFilter.class && (_max_id == 0 ? _min_id >= _controller.conversation.sync_message_id : _max_id > self.conversation.sync_message_id) ) || self.conversation.type == DialogTypeSecretChat || self.conversation.type == DialogTypeBroadcast ? ChatHistoryStateLocal : ChatHistoryStateRemote;
                    
                }
                
                [self setState:state next:next];
            }
            
            if(memory.count > 0)
                notify = YES;
            
            
            [self saveId:memory next:next];
            
            if((!next && _min_id == self.conversation.top_message)) {
                [self setState:ChatHistoryStateFull next:next];
                
                notify = YES;
            }
            
            
            if(notify)
                [self performCallback:selectHandler result:memory range:NSMakeRange(0, memory.count)];
            
        }
        
        
        
        if(anotherSource && !notify) {
            
            if([self checkState:ChatHistoryStateLocal next:next]) {
                
                
                NSArray *result = [self.filter storageRequest:next];
                
                NSArray *items = [self.controller messageTableItemsFromMessages:result];
                
                
                NSArray *converted = [self filterAndAdd:items isLates:NO];
                
                
                converted = [self sortItems:converted];
                
                
                [self saveId:converted next:next];
                
                
                if(!next && (_min_id >= self.conversation.top_message)) {
                    [self setState:ChatHistoryStateFull next:next];
                } else {
                    if(converted.count < self.selectLimit) {
                        [self setState: self.conversation.type != DialogTypeSecretChat && self.conversation.type != DialogTypeBroadcast ? ChatHistoryStateRemote : ChatHistoryStateFull next:next];
                    }
                }
                
                
                [self performCallback:selectHandler result:converted range:NSMakeRange(0, converted.count)];
                
                
            } else if([self checkState:ChatHistoryStateRemote next:next]) {
                
                [self.filter remoteRequest:next peer_id:self.conversation.peer_id callback:^(id response) {
                    
                    [TL_localMessage convertReceivedMessages:[response messages]];
                    
                    [queue dispatchOnQueue:^{
                        
                        
                        NSArray *messages = [[response messages] copy];
                        
                        if(self.filter.class != HistoryFilter.class || !_need_save_to_db) {
                            [[response messages] removeAllObjects];
                        }
                        
                        
                        TL_localMessage *sync_message = [[response messages] lastObject];
                        
                        if(sync_message) {
                            self.conversation.sync_message_id = sync_message.n_id;
                            [self.conversation save];
                        }
                        
                        
                        [SharedManager proccessGlobalResponse:response];
                        
                        
                        NSArray *converted = [self filterAndAdd:[self.controller messageTableItemsFromMessages:messages] isLates:NO];
                        
                        converted = [self sortItems:converted];
                        
                        [self saveId:converted next:next];
                        
                        
                        
                        
                        if(next && converted.count <  (self.selectLimit-1)) {
                            [self setState:ChatHistoryStateFull next:next];
                        }
                        
                        if(!next && (_min_id) == self.conversation.top_message) {
                            [self setState:ChatHistoryStateFull next:next];
                        }
                        
                        self.filter.request = nil;
                        
                        [self performCallback:selectHandler result:converted range:NSMakeRange(0, converted.count)];
                    }];
                    
                    
                }];
                
            }
            
        }
        
    } synchronous:sync];
    
}


-(void)loadAroundMessagesWithMessage:(MessageTableItem *)item selectHandler:(selectHandler)selectHandler {
    @throw [NSException exceptionWithName:@"ChatHistoryController not support loading around messages" reason:@";(" userInfo:nil];
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


-(BOOL)checkState:(ChatHistoryState)state next:(BOOL)next {
    return next ? _nextState == state : _prevState == state;
}

-(void)setState:(ChatHistoryState)state next:(BOOL)next {
    if(next)
        _nextState = state;
    else
         _prevState = state;
    
    
}

-(NSArray *)selectAllItems {

    
    NSArray *memory = [self sortItems:messageItems];
   
    
    return memory;
}


/*
 return (obj1.message.date < obj2.message.date && ((obj1.message.n_id < TGMINFAKEID && obj2.message.n_id < TGMINFAKEID) || (obj1.message.dstate == DeliveryStateNormal && obj2.message.dstate == DeliveryStateNormal)) ? NSOrderedDescending : (obj1.message.date > obj2.message.date && ((obj1.message.n_id < TGMINFAKEID && obj2.message.n_id < TGMINFAKEID) || (obj1.message.dstate == DeliveryStateNormal && obj2.message.dstate == DeliveryStateNormal)) ? NSOrderedAscending : (obj1.message.n_id < obj2.message.n_id ? NSOrderedDescending : NSOrderedAscending)));

 */

-(NSArray *)sortItems:(NSArray *)sort {

    return [sort sortedArrayUsingComparator:^NSComparisonResult(MessageTableItem *obj1, MessageTableItem *obj2) {
        
        return (obj1.message.date < obj2.message.date ? NSOrderedDescending : (obj1.message.date > obj2.message.date ? NSOrderedAscending : (obj1.message.n_id < obj2.message.n_id ? NSOrderedDescending : NSOrderedAscending)));
    }];
}

-(void)removeAllItems {
    for (Class filterClass in filters) {
        [filterClass removeAllItems:self.conversation.peer_id];
    }
}

-(void)removeAllItemsWithPeerId:(int)peer_id {
    for (Class filterClass in filters) {
        [filterClass removeAllItems:peer_id];
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
            
            NSArray *added = [self filterAndAdd:@[item] isLates:YES];
            
            [listeners enumerateObjectsUsingBlock:^(WeakReference *weak, NSUInteger idx, BOOL *stop) {
                
                
                ChatHistoryController *controller = weak.nonretainedObjectValue;
                
                if(added.count == 1 && (item.message.filterType & controller.filter.type) > 0 && item.message.peer_id == controller.conversation.peer_id) {
                    
                    [[ASQueue mainQueue] dispatchOnQueue:^{
                        
                        
                        [controller.controller receivedMessage:item position:0 itsSelf:YES];
                        
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
            
            [LoopingUtils runOnMainQueueAsync:^{
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
            
            NSArray *filtred =  [self filterAndAdd:items isLates:YES];
            
            MessageTableItem *item = [items lastObject];
            
            NSRange range = NSMakeRange(0, filtred.count);
            if(filtred.count == items.count && item.message.peer_id == self.conversation.peer_id) {
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
                
                if(self.conversation.last_marked_message > TGMINFAKEID || self.conversation.last_marked_message < checkItem.message.n_id) {
                    
                    checkItem.messageSender.conversation.last_marked_message = checkItem.message.n_id;
                    checkItem.messageSender.conversation.last_marked_date = checkItem.message.date;
                    
                    [self.conversation save];
                    
               }
                
                if(![checkItem.message isKindOfClass:[TL_destructMessage class]]) {
                    [messageItems removeObject:checkItem];
                    [messageKeys removeObjectForKey:@(checkItem.message.fakeId)];
                    
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
    
    [queue dispatchOnQueue:^{
        _h_filter.controller = nil;
        [_h_filter.request cancelRequest];
        _h_filter = nil;
        _controller = nil;
        
    } synchronous:YES];
    
    
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
        [self drop:NO];
    } synchronous:YES];
}

+(void)drop {
    [HistoryFilter drop];
}

@end
