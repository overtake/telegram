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
        
        [Notification addObserver:self selector:@selector(didChangeNotifySettings:) name:[Notification notificationNameByDialog:object action:@"notification"]];

    }
    
    return self;
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(void)didChangeNotifySettings:(NSNotification *)notify
{
    _conversation.notify_settings = notify.userInfo[@"notify_settings"];
    [self redrawRow];
}

-(NSUInteger)hash {
    return _conversation.peer_id;
}

@end
