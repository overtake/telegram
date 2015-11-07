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
@implementation ChannelCommonFilter

-(NSArray *)proccessResponse:(NSArray *)result state:(ChatHistoryState)state next:(BOOL)next {
    
    NSArray *converted = [self filterAndAdd:result latest:NO];
    
    converted = [self sortItems:converted];
    
    state = !next && state != ChatHistoryStateFull && ([self isKindOfClass:[ChannelFilter class]] ? self.conversation.top_message <= self.server_max_id : self.conversation.top_important_message <= self.server_max_id) ? ChatHistoryStateFull : state;
    
    
    [self setState:state next:next];
    
    return converted;
}

@end
