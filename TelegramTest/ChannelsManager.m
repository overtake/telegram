//
//  ChannelsManager.m
//  Telegram
//
//  Created by keepcoder on 09.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelsManager.h"

@implementation ChannelsManager

- (void)add:(NSArray *)all {
    
    [self.queue dispatchOnQueue:^{
        [all enumerateObjectsUsingBlock:^(TL_conversation * dialog, NSUInteger idx, BOOL *stop) {
            TL_conversation *current = [keys objectForKey:@(dialog.peer_id)];
            if(current) {
                current.unread_count = dialog.unread_count;
                current.top_message = dialog.top_message;
                current.last_message_date = dialog.last_message_date;
                current.notify_settings = dialog.notify_settings;
                current.fake = dialog.fake;
                current.last_marked_message = dialog.last_marked_message;
                current.top_message_fake = dialog.top_message_fake;
                current.last_marked_date = dialog.last_marked_date;
                current.last_real_message_date = dialog.last_real_message_date;
                current.dstate = dialog.dstate;
                current.read_inbox_max_id = dialog.read_inbox_max_id;
                current.top_important_message = dialog.top_important_message;
                current.unread_important_count = dialog.unread_important_count;
                current.invisibleChannel = dialog.invisibleChannel;
                current.lastMessage = dialog.lastMessage;
            } else {
                [self->list addObject:dialog];
                [self->keys setObject:dialog forKey:@(dialog.peer_id)];
                current = dialog;
            }
            
            if(!current.notify_settings) {
                current.notify_settings = [TL_peerNotifySettingsEmpty create];
                [current save];
            }
            
            [self resort];
            
        }];
    }];
}

+(id)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] initWithQueue:[ASQueue globalQueue]];
    });
    return instance;
}


-(void)resort {
}


@end
