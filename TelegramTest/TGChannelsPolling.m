//
//  TGChannelsPolling.m
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGChannelsPolling.h"
#import "TGTimer.h"

@interface TGChannelsPolling ()
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,assign) int pts;
@property (nonatomic,assign) int limit;
@property (nonatomic,strong) TGTimer *timer;
@end

@implementation TGChannelsPolling


-(id)initWithDelegate:(id <TGChannelPollingDelegate>)delegate withUpdatesLimit:(int)limit {
    if(self = [super init]) {
        _deleagte = delegate;
        _limit = limit;
    }
    
    return self;
}


-(void)setCurrentConversation:(TL_conversation *)conversation {
    
    [ASQueue dispatchOnStageQueue:^{
        
         _conversation = conversation;
        
        
        
        [self start];
        
    }];
   
}

-(void)stop {
    
    [self stop];
}

-(void)start {
    
}


@end
