
//
//  TGMentionPopup.m
//  Telegram
//
//  Created by keepcoder on 02.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGMentionPopup.h"
#import "TMMenuPopover.h"
#import "TGMenuItemPhoto.h"


@interface TGMentionPopup ()

@end

@implementation TGMentionPopup




+(void)show:(NSString *)string chat:(TLChat *)chat view:(NSView *)view ofRect:(NSRect)rect callback:(void (^)(NSString *userName))callback {
    
    
    TLChatFull *fullChat = [[FullChatManager sharedManager] find:chat.n_id];
    
    NSMutableArray *uids = [[NSMutableArray alloc] init];
    
    if([chat isKindOfClass:[TL_chat class]]) {
        [fullChat.participants.participants enumerateObjectsUsingBlock:^(TLChatParticipant * obj, NSUInteger idx, BOOL *stop) {
            [uids addObject:@(obj.user_id)];
            
        }];
    } else {
        
        NSArray *contacts = [[NewContactsManager sharedManager] all];
        
        [contacts enumerateObjectsUsingBlock:^(TLContact *obj, NSUInteger idx, BOOL *stop) {
            
             [uids addObject:@(obj.user_id)];
            
        }];
    }
    
    
    
    NSArray *users = [UsersManager findUsersByMention:string withUids:uids];
    
        
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
    
    [users enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
        
        NSMenuItem *item = [NSMenuItem menuItemWithTitle:obj.fullName withBlock:^(id sender) {
            
            callback(obj.username);
            
            [self close];
            
        }];
        
        [item setSubtitle:[NSString stringWithFormat:@"@%@",obj.username]];
        
        item.representedObject = [[TGMenuItemPhoto alloc] initWithUser:obj menuItem:item];
        
        
        [menu addItem:item];
        
    }];
    
    if(menu.itemArray.count > 0) {
        [self close];
        
        [self setPopover:[[TMMenuPopover alloc] initWithMenu:menu]];
        
        [[self popover] setAutoHighlight:NO];
        
        [[self popover] showRelativeToRect:rect ofView:view preferredEdge:CGRectMinYEdge];
        
        [[self popover].contentViewController selectNext];
    } else {
        [self close];
    }
    
}





@end
