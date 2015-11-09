//
//  DocumentHistoryFilter.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DocumentHistoryFilter.h"
#import "ChatHistoryController.h"
@implementation DocumentHistoryFilter

-(int)type {
    return HistoryFilterDocuments;
}

+(int)type {
    return HistoryFilterDocuments;
}

-(TLMessagesFilter *)messagesFilter {
    return [TL_inputMessagesFilterDocument create];
}

-(NSString *)description {
    return NSLocalizedString(@"Conversation.Filter.Files", nil);
}

@end
