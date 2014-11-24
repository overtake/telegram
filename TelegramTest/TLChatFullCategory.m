//
//  TGFullChatCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/28/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLChatFullCategory.h"

@implementation TLChatFull (Category)

DYNAMIC_PROPERTY(LASTUPDATETIME);
DYNAMIC_PROPERTY(Conversation);

- (int)lastUpdateTime {
    return [[self getLASTUPDATETIME] intValue];
}

- (void)setLastUpdateTime:(int)lastUpdateTime {
    [self setLASTUPDATETIME:@(lastUpdateTime)];
}



- (TL_conversation *)conversation {
    
    if(![self getConversation]) {
        [self setConversation:[[DialogsManager sharedManager]findByChatId:self.n_id]];
    }
    return [self getConversation];
}

@end
