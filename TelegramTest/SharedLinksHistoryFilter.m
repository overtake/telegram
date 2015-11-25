//
//  SharedLinksHistoryFilter.m
//  Telegram
//
//  Created by keepcoder on 24.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SharedLinksHistoryFilter.h"
#import "ChatHistoryController.h"

@implementation SharedLinksHistoryFilter


-(int)type {
    return HistoryFilterSharedLink;
}

+(int)type {
    return HistoryFilterSharedLink;
}

-(TLMessagesFilter *)messagesFilter {
    return [TL_inputMessagesFilterUrl create];
}

-(NSString *)description {
    return NSLocalizedString(@"Conversation.Filter.SharedLinks", nil);
}
@end
