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

static NSString *kYapChannelCollection = @"channels_keys";
static NSString *kYapChannelKey = @"channels_is_loaded";
@interface TGChannelsLoader : TGObservableObject

@property (nonatomic,assign,readonly) BOOL channelsIsLoaded;
@property (nonatomic,assign) BOOL isNeedRemoteLoading;
@end


@implementation TGChannelsLoader

-(void)loadChannelsOnQueue:(ASQueue *)queue {
    
    [self loadNext:0 result:@[] onQueue:queue];
    
}

-(instancetype)initWithQueue:(ASQueue *)queue {
    if(self = [super init]) {
        
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
            
            _isNeedRemoteLoading = ![[transaction objectForKey:kYapChannelKey inCollection:kYapChannelCollection] boolValue];
            
        }];
        
        [Notification addObserver:self selector:@selector(logout:) name:LOGOUT_EVENT];
        
        _channelsIsLoaded = !_isNeedRemoteLoading;

    }
    
    return self;
}

-(void)logout:(NSNotification *)notification {
    _channelsIsLoaded = NO;
    
}

static const int limit = 1000;

-(void)loadNext:(int)offset result:(NSArray *)result onQueue:(ASQueue *)queue{
    
    test_start_group(@"test");

    
    [RPCRequest sendRequest:[TLAPI_channels_getDialogs createWithOffset:offset limit:limit] successHandler:^(id request, TL_messages_dialogs *response) {
        
         test_step_group(@"test");
        
         [SharedManager proccessGlobalResponse:response];
        
        NSMutableArray *converted = [[NSMutableArray alloc] initWithCapacity:response.dialogs.count];
        
        
        
        
   //     assert(response.dialogs.count == response.messages.count);
        
        
        [response.dialogs enumerateObjectsUsingBlock:^(TL_dialogChannel *channel, NSUInteger idx, BOOL *stop) {
            
            NSArray *f = [response.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.peer_id == %d", channel.peer.peer_id]];
            
            
            assert(f.count > 0);
            
            __block TL_localMessage *topMsg;
            __block TL_localMessage *minMsg;
            
            [f enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
                
                if(channel.top_message == obj.n_id)
                    topMsg = obj;
                
                if(!minMsg || obj.n_id < minMsg.n_id)
                    minMsg = obj;
                
            }];
            
           
            
            if(f.count == 2) {
                
                if(minMsg.n_id != topMsg.n_id) {
                    TGMessageHole *hole = [[TGMessageHole alloc] initWithUniqueId:-rand_int() peer_id:minMsg.peer_id min_id:minMsg.n_id max_id:topMsg.n_id date:minMsg.date count:0];
                    
                    [[Storage manager] insertMessagesHole:hole];
                }
                
                // hole
                
                
                // need create group hole
                
                TGMessageGroupHole *groupHole = [[TGMessageGroupHole alloc] initWithUniqueId:-rand_int() peer_id:topMsg.peer_id min_id:minMsg.n_id max_id:topMsg.n_id+1 date:topMsg.date count:0];
                
                [[Storage manager] insertMessagesHole:groupHole];
                
            }
            
            
            [converted addObject:[TL_conversation createWithPeer:channel.peer top_message:channel.top_message unread_count:channel.unread_important_count last_message_date:minMsg.date notify_settings:channel.notify_settings last_marked_message:channel.top_important_message top_message_fake:channel.top_important_message last_marked_date:minMsg.date sync_message_id:topMsg.n_id read_inbox_max_id:channel.read_inbox_max_id unread_important_count:channel.unread_important_count lastMessage:minMsg pts:channel.pts isInvisibleChannel:NO top_important_message:minMsg.n_id]];
            
            
           
        }];
        
         test_step_group(@"test");
        
        test_release_group(@"test");
        
        
        NSArray *join = [result arrayByAddingObjectsFromArray:converted];
        
        if(converted.count < limit) {
            [self saveResults:join onQueue:queue];
        }
        
        else
            [self loadNext:(int) join.count result:join onQueue:queue];
            
        
    } errorHandler:^(id request, RpcError *error) {
        
    } timeout:0 queue:queue.nativeQueue];
    
    
}

-(void)saveResults:(NSArray *)channels onQueue:(ASQueue *)queue {
    [queue dispatchOnQueue:^{
        
        [[ChannelsManager sharedManager] add:channels];
        
        [[Storage manager] insertChannels:channels completionHandler:^{
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
                [transaction setObject:@(YES) forKey:kYapChannelKey inCollection:kYapChannelCollection];
            }];
            
        } deliveryOnQueue:queue];
        
        _channelsIsLoaded = YES;
        [self notifyListenersWithObject:channels];
    }];
    
}

@end

@interface TGModernConversationHistoryController () <TGObservableDelegate>
@property (nonatomic,strong) ASQueue *queue;
@property (nonatomic,weak) id<TGModernConversationHistoryControllerDelegate> delegate;
@property (nonatomic,assign) BOOL loadNextAfterLoadChannels;
@property (nonatomic,assign) int channelsOffset;

@property (nonatomic,assign) BOOL needMergeChannels;

@end

@implementation TGModernConversationHistoryController




static TGChannelsLoader *channelsLoader;
static BOOL isStorageLoaded;

-(id)initWithQueue:(ASQueue *)queue delegate:(id<TGModernConversationHistoryControllerDelegate>)deleagte {
    
    if(self = [super init]) {
        _queue = queue;
        
        
        _delegate = deleagte;
        
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            channelsLoader = [[TGChannelsLoader alloc] initWithQueue:queue];
        });
        
        
        [channelsLoader addEventListener:self];
        
        if(!channelsLoader.channelsIsLoaded) {
            [channelsLoader loadChannelsOnQueue:queue];
        }
        
        
        _state = TGModernCHStateLocal;
         
    }
    
    return self;
}
         
-(void)dealloc {
    [channelsLoader removeEventListener:self];
}


-(void)didChangedEventStateWithObject:(id)object {
   
    if(_loadNextAfterLoadChannels) {
        _isLoading = NO;
        _state = TGModernCHStateRemote;
        _needMergeChannels = YES;
        [self performLoadNext];
    }
    
    
}

-(void)requestNextConversation {
    
    [_queue dispatchOnQueue:^{
        
        if(_isLoading)
            return;
        
        _isLoading = YES;
        
        if(!channelsLoader.channelsIsLoaded)
            _loadNextAfterLoadChannels = YES;
        else
            [self performLoadNext];
            
        
    }];
    

}

-(void)performLoadNext {
    
    if(_state == TGModernCHStateLocal)
    {
        
        [[Storage manager] dialogsWithOffset:_offset limit:[self.delegate conversationsLoadingLimit] completeHandler:^(NSArray *d, NSArray *m, NSArray *c) {
            
            [[DialogsManager sharedManager] add:[d arrayByAddingObjectsFromArray:c]];
            
            [[ChannelsManager sharedManager] add:c];
            
            [_queue dispatchOnQueue:^{
                
                if(d.count < [self.delegate conversationsLoadingLimit]) {
                    isStorageLoaded = YES;
                    
                    _state = TGModernCHStateRemote;
                    
                    [self performLoadNext];
                }
                
                [self dispatchWithFullList:[self mixChannelsWithConversations:[d arrayByAddingObjectsFromArray:c]] offset:(int)d.count];
                
            }];
            
            
        }];
    }  else if(_state == TGModernCHStateRemote) {
        
        
        [RPCRequest sendRequest:[TLAPI_messages_getDialogs createWithOffset:_offset limit:100] successHandler:^(id request, TL_messages_dialogs *response) {
            
            
            
            if([response isKindOfClass:[TL_messages_dialogsSlice class]] && _offset == response.n_count) {
                _state = TGModernCHStateFull;
                return;
            }
            
            
            [SharedManager proccessGlobalResponse:response];
            
            
            NSMutableArray *converted = [[NSMutableArray alloc] init];
           
            [response.dialogs enumerateObjectsUsingBlock:^(TL_dialog *dialog, NSUInteger idx, BOOL *stop) {
                
                TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[response.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %d",dialog.top_message]] firstObject]];
                
                [converted addObject:[TL_conversation createWithPeer:dialog.peer top_message:dialog.top_message unread_count:dialog.unread_count last_message_date:msg.date notify_settings:dialog.notify_settings last_marked_message:dialog.top_message top_message_fake:dialog.top_message last_marked_date:msg.date sync_message_id:msg.n_id read_inbox_max_id:dialog.read_inbox_max_id unread_important_count:dialog.unread_important_count lastMessage:msg pts:dialog.pts isInvisibleChannel:NO top_important_message:dialog.top_important_message]];
                
            }];
            
            
            
            if(_needMergeChannels) {
                 converted = [[self mixChannelsWithConversations:[[[ChannelsManager sharedManager] all] arrayByAddingObjectsFromArray:converted]] mutableCopy];
                _needMergeChannels = NO;
            }
            
           
            
            [[DialogsManager sharedManager] add:converted];
            [[Storage manager] insertDialogs:converted completeHandler:nil];
            
            [MessagesManager updateUnreadBadge];
            
            if(converted.count < [_delegate conversationsLoadingLimit])
                _state = TGModernCHStateFull;
            
            
            [self dispatchWithFullList:converted offset:(int)converted.count];
            
            
            
        } errorHandler:^(id request, RpcError *error) {
            
            
            
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
    
    _isLoading = NO;

}

-(void)clear {
    _offset = 0;
    _isLoading = NO;
    _delegate = nil;
    [channelsLoader removeEventListener:self];
}


@end
