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
@interface TGUpdateChannels ()
@property (nonatomic,strong) ASQueue *queue;
@property (nonatomic,strong) NSMutableDictionary *channelWaitingUpdates;
@property (nonatomic,strong) NSMutableDictionary *channelWaitingTimers;

@end

@implementation TGUpdateChannels

-(id)initWithQueue:(ASQueue *)queue {
    if(self = [super init]) {
        _queue = queue;
        _channelWaitingUpdates = [[NSMutableDictionary alloc] init];
        _channelWaitingTimers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(int)ptsWithChannelId:(int)channel_id {
    
    return MAX(1,1);
}



-(int)channelIdWithUpdate:(id)update {
    
    if([update isKindOfClass:[TL_updateNewChannelMessage class]]) {
        return ((TL_updateNewChannelMessage *)update).message.to_id.channel_id;
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
            statefullUpdates = @[NSStringFromClass([TL_updateNewChannelMessage class])];
            statelessUpdates = @[NSStringFromClass([TL_updateReadChannelInbox class])];
        });
        
        if([statefullUpdates indexOfObject:[update className]] != NSNotFound)
        {
            [self addStatefullUpdate:[[TGUpdateChannelContainer alloc] initWithPts:[update pts] pts_count:[update pts_count] channel_id:[self channelIdWithUpdate:update] update:update]];
        }  else if([statelessUpdates indexOfObject:[update className]] != NSNotFound) {
            [self proccessStatelessUpdate:update];
        }
        
        
        
    }];

}

-(void)addStatefullUpdate:(TGUpdateChannelContainer *)statefulMessage {
    
    if(statefulMessage.pts > 0 && [self ptsWithChannelId:statefulMessage.pts] + statefulMessage.pts_count == statefulMessage.pts )
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
            
            [self failUpdateWithChannelId:[timer.reservedObject intValue]];
            
        } queue:_queue.nativeQueue reservedObject:@(statefullMessage.channel_id)];
        
        [timer start];
    }
    
}



-(void)proccessStatefullUpdate:(TGUpdateChannelContainer *)statefulMessage {
    
    if([statefulMessage.update isKindOfClass:[TL_updateNewChannelMessage class]])
    {
        TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[(TL_updateNewChannelMessage *)[statefulMessage update] message]];
        
        [MessagesManager addAndUpdateMessage:msg];
        
    }
    
    
}


-(void)proccessStatelessUpdate:(id)update {
    
    if([update isKindOfClass:[TL_updateReadChannelInbox class]]) {
        
    }
    
}


-(void)failUpdateWithChannelId:(int)channel_id
{
    
    TL_channel *channel = [[ChatsManager sharedManager] find:channel_id];
    
//    [RPCRequest sendRequest:[TLAPI_updates_getChannelDifference createWithPeer:[TL_inputPeerChannel createWithChannel_id:channel_id access_hash:channel.access_hash] pts:[self ptsWithChannelId:channel_id] limit:100] successHandler:^(id request, id response) {
//        
//        int bp = 0;
//        
//    } errorHandler:^(id request, RpcError *error) {
//        
//        int err = 0;
//        
//    } timeout:0 queue:_queue.nativeQueue];
}

@end
