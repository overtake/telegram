//
//  PhotoHistoryFilter.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhotoHistoryFilter.h"
#import "ChatHistoryController.h"
@implementation PhotoHistoryFilter


-(int)type {
    return HistoryFilterPhoto;
}

+(int)type {
    return HistoryFilterPhoto;
}

-(TLMessagesFilter *)messagesFilter {
    return [TL_inputMessagesFilterPhotos create];
}

-(NSString *)description {
    return NSLocalizedString(@"Conversation.Filter.Photos", nil);
}

@end
