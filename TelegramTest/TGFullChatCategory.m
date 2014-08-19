//
//  TGFullChatCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/28/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGFullChatCategory.h"

@implementation TGChatFull (Category)

DYNAMIC_PROPERTY(LASTUPDATETIME);
DYNAMIC_PROPERTY(CONVERSATION);

- (int)lastUpdateTime {
    return [[self getLASTUPDATETIME] intValue];
}

- (void)setLastUpdateTime:(int)lastUpdateTime {
    [self setLASTUPDATETIME:@(lastUpdateTime)];
}



- (TL_conversation *)conversation {
    
    if(![self getCONVERSATION]) {
        [self setCONVERSATION:[[DialogsManager sharedManager]find:self.n_id]];
    }
    return [self getCONVERSATION];
}

@end
