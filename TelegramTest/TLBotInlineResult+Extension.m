//
//  TLBotInlineResult+Extension.m
//  Telegram
//
//  Created by keepcoder on 31/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TLBotInlineResult+Extension.h"

@implementation TLBotInlineResult (Extension)


DYNAMIC_PROPERTY(Query_id);

-(long)queryId {
    return [[self getQuery_id] longValue];
}

-(void)setQueryId:(long)queryId {
    [self setQuery_id:@(queryId)];
}



@end
