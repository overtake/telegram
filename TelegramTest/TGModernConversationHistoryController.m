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

@property (nonatomic,strong) NSArray *channels;


@end


@implementation TGChannelsLoader

-(void)loadChannelsOnQueue:(ASQueue *)queue {
    
    [self loadNext:0 result:@[] onQueue:queue];
    
}

-(instancetype)initWithQueue:(ASQueue *)queue {
    if(self = [super init]) {
        
        __block BOOL isNeedRemoteLoading;
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
            
            isNeedRemoteLoading = ![[transaction objectForKey:kYapChannelKey inCollection:kYapChannelCollection] boolValue];
            
        }];
        
        if(isNeedRemoteLoading)
            [self loadChannelsOnQueue:queue];
        else
            [[Storage manager] allChannels:^(NSArray *channels, NSArray *messages) {
                
                _channels = channels;
                
                [self notifyListenersWithObject:_channels];
                
            } deliveryOnQueue:queue];
        
    }
    
    return self;
}

static const int limit = 1000;

-(void)loadNext:(int)offset result:(NSArray *)result onQueue:(ASQueue *)queue{
    
    [RPCRequest sendRequest:[TLAPI_messages_getChannelDialogs createWithOffset:offset limit:limit] successHandler:^(id request, TL_messages_dialogs *response) {
        
         [SharedManager proccessGlobalResponse:response];
        
        
        NSMutableArray *converted = [[NSMutableArray alloc] initWithCapacity:response.dialogs.count];
        
        
   //     assert(response.dialogs.count == response.messages.count);
        
        
        [response.dialogs enumerateObjectsUsingBlock:^(TL_dialogChannel *channel, NSUInteger idx, BOOL *stop) {
            
            NSArray *f = [response.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %d and self.peer_id == %d",channel.top_message, channel.peer.peer_id]];
            
            
            
            TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[f lastObject]];
            
            
            
            assert(msg != nil);
            
            [converted addObject:[TL_conversation createWithPeer:channel.peer top_message:channel.top_message unread_count:channel.unread_count last_message_date:msg.date notify_settings:channel.notify_settings last_marked_message:channel.top_message top_message_fake:channel.top_message last_marked_date:msg.date sync_message_id:msg.n_id read_inbox_max_id:channel.read_inbox_max_id unread_important_count:channel.unread_important_count lastMessage:msg pts:channel.pts]];
            
        }];
        
        
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
        
        
        _channels = channels;
        
        [self notifyListenersWithObject:channels];
        
        [[Storage manager] insertChannels:channels completionHandler:^{
            
            [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
                [transaction setObject:@(YES) forKey:kYapChannelKey inCollection:kYapChannelCollection];
            }];
            
        } deliveryOnQueue:queue];
        
        
    }];
    
}

@end

@interface TGModernConversationHistoryController () <TGObservableDelegate>
@property (nonatomic,strong) ASQueue *queue;
@property (nonatomic,weak) id<TGModernConversationHistoryControllerDelegate> delegate;
@property (nonatomic,assign) BOOL loadNextAfterLoadChannels;
@property (nonatomic,assign) int channelsOffset;
@end

@implementation TGModernConversationHistoryController




static TGChannelsLoader *channelsLoader;
static BOOL isStorageLoaded;

-(id)initWithQueue:(ASQueue *)queue delegate:(id<TGModernConversationHistoryControllerDelegate>)deleagte {
    
    if(self = [super init]) {
        _queue = queue;
        
        [queue dispatchOnQueue:^{
            
            _delegate = deleagte;
            
           
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                channelsLoader = [[TGChannelsLoader alloc] initWithQueue:queue];
            });
            
            
            [channelsLoader addWeakEventListener:self];
            
            
            _state = isStorageLoaded ? TGModernCHStateCache : TGModernCHStateLocal;
            
        } synchronous:YES];
        

         
        
    }
    
    return self;
}
         
-(void)dealloc {
    [channelsLoader removeEventListener:self];
}


-(void)didChangedEventStateWithObject:(id)object {
   
    if(_loadNextAfterLoadChannels)
        [self performLoadNext];
    
}

-(void)requestNextConversation {
    
    [_queue dispatchOnQueue:^{
        
        if(_isLoading)
            return;
        
        _isLoading = YES;
        
        if(channelsLoader.channels == nil)
            _loadNextAfterLoadChannels = YES;
        else
            [self performLoadNext];
            
        
    }];
    

}

-(void)performLoadNext {
    
    if(_state == TGModernCHStateLocal)
    {
        [[Storage manager] dialogsWithOffset:0 limit:10000 completeHandler:^(NSArray *d, NSArray *m) {
            
            [[DialogsManager sharedManager] add:d];
            
            [_queue dispatchOnQueue:^{
                
                isStorageLoaded = YES;
                
                _state = TGModernCHStateCache;
                
                [self performLoadNext];
                
            }];
            
        }];
    } else if(_state == TGModernCHStateCache) {
        NSArray *all = [[DialogsManager sharedManager] all];
        
        
        if(_offset >= all.count) {
            _state = TGModernCHStateRemote;
            [self performLoadNext];
            return;
        }
        
        [self dispatchWithFullList:all];
        
    } else if(_state == TGModernCHStateRemote) {
        
        int remoteOffset = (int) [[[[DialogsManager sharedManager] all] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type != 4 && self.type != 3 && self.type != 2"]] count];
        
        [RPCRequest sendRequest:[TLAPI_messages_getDialogs createWithOffset:remoteOffset limit:[_delegate conversationsLoadingLimit]] successHandler:^(id request, TL_messages_dialogs *response) {
            
            
            if([response isKindOfClass:[TL_messages_dialogsSlice class]] && remoteOffset == response.n_count)
                return;
            
            [SharedManager proccessGlobalResponse:response];
            
            
            NSMutableArray *converted = [[NSMutableArray alloc] init];
           
            [response.dialogs enumerateObjectsUsingBlock:^(TL_dialogChannel *channel, NSUInteger idx, BOOL *stop) {
                
                TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[response.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %d",channel.top_message]] lastObject]];
                
                [converted addObject:[TL_conversation createWithPeer:channel.peer top_message:channel.top_message unread_count:channel.unread_count last_message_date:msg.date notify_settings:channel.notify_settings last_marked_message:channel.top_message top_message_fake:channel.top_message last_marked_date:msg.date sync_message_id:msg.n_id read_inbox_max_id:channel.read_inbox_max_id unread_important_count:channel.unread_important_count lastMessage:msg pts:channel.pts]];
                
            }];
            
            
            [[DialogsManager sharedManager] add:converted];
            [[Storage manager] insertDialogs:converted completeHandler:nil];
            
            [MessagesManager updateUnreadBadge];
            
            if(converted.count < [_delegate conversationsLoadingLimit])
                _state = TGModernCHStateFull;
            
            
            [self dispatchWithFullList:[[DialogsManager sharedManager] all]];
            
            
            
        } errorHandler:^(id request, RpcError *error) {
            
            
            
        } timeout:0 queue:_queue.nativeQueue];
        
    }

}

- (NSArray *)mixChannelsWithConversations:(NSArray *)channels conversations:(NSArray *)conversations {
    
    NSArray *join = [channels arrayByAddingObjectsFromArray:conversations];
    
    return [join sortedArrayUsingComparator:^NSComparisonResult(TL_conversation * obj1, TL_conversation * obj2) {
        return (obj1.last_real_message_date < obj2.last_real_message_date ? NSOrderedDescending : (obj1.last_real_message_date > obj2.last_real_message_date ? NSOrderedAscending : (obj1.top_message < obj2.top_message ? NSOrderedDescending : NSOrderedAscending)));
    }];
    
}

-(void)dispatchWithFullList:(NSArray *)all {
    
    
    
    NSArray *mixed = [self mixChannelsWithConversations:[channelsLoader.channels subarrayWithRange:NSMakeRange(_channelsOffset, channelsLoader.channels.count - _channelsOffset)] conversations:all];
    
    
    __block NSUInteger lastIndex = mixed.count;
    
    [mixed enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.type != DialogTypeChannel) {
            lastIndex = idx+1;
            *stop = YES;
        }
        
    }];
    
    
    
    mixed = [mixed subarrayWithRange:NSMakeRange(0, MIN(lastIndex,[self.delegate conversationsLoadingLimit]))];
    
    NSArray *channels = [mixed filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type == 4"]];
    
    NSUInteger channelsOffsetCount = [channels count];
    
    [[DialogsManager sharedManager] add:channels];
   
    NSRange range = NSMakeRange(_offset+_channelsOffset, mixed.count);
    
    [_delegate didLoadedConversations:mixed withRange:range];
    
    _channelsOffset+=channelsOffsetCount;
    _offset+= mixed.count;
    
    _isLoading = NO;

}


@end
