//
//  VideoHistoryFilter.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "VideoHistoryFilter.h"
#import "ChatHistoryController.h"
@implementation VideoHistoryFilter


-(int)type {
    return HistoryFilterVideo;
}

+(int)type {
    return HistoryFilterVideo;
}

-(TLMessagesFilter *)messagesFilter {
    return [TL_inputMessagesFilterVideo create];
}

-(NSString *)description {
    return NSLocalizedString(@"Conversation.Filter.Video", nil);
}

@end
