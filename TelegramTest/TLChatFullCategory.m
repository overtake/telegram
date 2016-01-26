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
DYNAMIC_PROPERTY(LASTLAYERUPDATED);

DYNAMIC_PROPERTY(Conversation);

- (int)lastUpdateTime {
    return [[self getLASTUPDATETIME] intValue];
}

- (void)setLastUpdateTime:(int)lastUpdateTime {
    [self setLASTUPDATETIME:@(lastUpdateTime)];
}


-(BOOL)isLastLayerUpdated {
    return [[self getLASTLAYERUPDATED] boolValue];
}

-(void)setLastLayerUpdated:(BOOL)value {
    [self setLASTLAYERUPDATED:@(value)];
}

- (TL_conversation *)conversation {
    
    if(![self getConversation]) {
        [self setConversation:[[DialogsManager sharedManager]findByChatId:self.n_id]];
    }
    return [self getConversation];
}

DYNAMIC_PROPERTY(Chat);

-(TLChat *)chat {
    if(![self getChat]) {
        [self setChat:[[ChatsManager sharedManager] find:self.n_id]];
    }
    return [self getChat];
}

@end
