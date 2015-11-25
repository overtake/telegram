//
//  AllMediaHistoryFilter.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhotoVideoHistoryFilter.h"
#import "ChatHistoryController.h"
@implementation PhotoVideoHistoryFilter

-(int)type {
    return HistoryFilterPhoto | HistoryFilterVideo;
}

+(int)type {
    return HistoryFilterPhoto | HistoryFilterVideo;
}

-(TLMessagesFilter *)messagesFilter {
    return [TL_inputMessagesFilterPhotoVideo create];
}

-(NSString *)description {
    return NSLocalizedString(@"Conversation.Filter.PhotoVideo", nil);
}

@end
