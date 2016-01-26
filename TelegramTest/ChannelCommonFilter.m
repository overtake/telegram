//
//  ChannelCommonFilter.m
//  Telegram
//
//  Created by keepcoder on 06/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "ChannelCommonFilter.h"
#import "ChannelFilter.h"
#import "ChannelImportantFilter.h"
#import "ChatHistoryController.h"
@implementation ChannelCommonFilter

-(NSArray *)proccessResponse:(NSArray *)result state:(ChatHistoryState)state next:(BOOL)next {
    
    NSArray *converted = [self filterAndAdd:result latest:NO];
    
    converted = [self sortItems:converted];
    
    state = next && state != ChatHistoryStateFull && self.server_min_id <= 1 ? ChatHistoryStateFull : state;
    
    [self setState:state next:next];
    
    TL_conversation *conversation = [[DialogsManager sharedManager] find:self.peer_id];

    if(self.prevState != ChatHistoryStateFull && conversation.universalTopMessage > 0 && conversation.universalTopMessage <= self.server_max_id) {
        [self setState:ChatHistoryStateFull next:NO];
    }
    
    
    
    
    return converted;
}

@end
