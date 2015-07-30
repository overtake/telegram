//
//  NotificationConversationRowItem.m
//  Telegram
//
//  Created by keepcoder on 29.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "NotificationConversationRowItem.h"

@implementation NotificationConversationRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _conversation = object;

        
    }
    
    return self;
}

-(NSUInteger)hash {
    return _conversation.peer_id;
}

@end
