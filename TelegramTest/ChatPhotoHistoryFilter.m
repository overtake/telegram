//
//  ChatPhotoHistoryFilter.m
//  Telegram
//
//  Created by keepcoder on 18/05/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "ChatPhotoHistoryFilter.h"

@implementation ChatPhotoHistoryFilter

-(int)type {
    return HistoryFilterChatPhoto;
}

+(int)type {
    return HistoryFilterChatPhoto;
}

-(TLMessagesFilter *)messagesFilter {
    return [TL_inputMessagesFilterChatPhotos create];
}

-(NSString *)description {
    return NSLocalizedString(@"Conversation.Filter.ChatPhotos", nil);
}

@end
