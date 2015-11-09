//
//  AudioHistoryFilter.m
//  Messenger for Telegram
//
//  Created by keepcoder on 30.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "AudioHistoryFilter.h"
#import "ChatHistoryController.h"
@implementation AudioHistoryFilter


-(int)type {
    return HistoryFilterAudio;
}

+(int)type {
    return HistoryFilterAudio;
}

-(TLMessagesFilter *)messagesFilter {
    return [TL_inputMessagesFilterAudio create];
}

-(NSString *)description {
    return NSLocalizedString(@"Conversation.Filter.Audio", nil);
}

@end
