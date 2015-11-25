//
//  MP3HistoryFilter.m
//  Telegram
//
//  Created by keepcoder on 24.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "MP3HistoryFilter.h"
#import "ChatHistoryController.h"
@implementation MP3HistoryFilter


-(int)type {
    return HistoryFilterAudioDocument;
}

+(int)type {
    return HistoryFilterAudioDocument;
}

-(TLMessagesFilter *)messagesFilter {
    return [TL_inputMessagesFilterAudioDocuments create];
}

-(NSString *)description {
    return NSLocalizedString(@"Conversation.Filter.MP3", nil);
}

@end
