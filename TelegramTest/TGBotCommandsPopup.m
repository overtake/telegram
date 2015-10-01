//
//  TGBotCommandsPopup.m
//  Telegram
//
//  Created by keepcoder on 28.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGBotCommandsPopup.h"
#import "TGMenuItemPhoto.h"


@implementation TGBotCommandsPopup



+(void)show:(NSString *)string botInfo:(NSArray *)botInfo view:(NSView *)view  ofRect:(NSRect)rect callback:(void (^)(NSString *command))callback  {
    
//    
//    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
//    
//    
//    NSMutableArray *commands = [[NSMutableArray alloc] init];
//    
//    [botInfo enumerateObjectsUsingBlock:^(TLBotInfo *obj, NSUInteger idx, BOOL *stop) {
//        
//         TLUser *user = [[UsersManager sharedManager] find:obj.user_id];
//        
//        [obj.commands enumerateObjectsUsingBlock:^(TL_botCommand *command, NSUInteger idx, BOOL *stop) {
//            
//            NSString *cmd = command.command;
//            
//            if([Telegram conversation].type == DialogTypeChat && (user.flags & TGUSERFLAGREADHISTORY) != TGUSERFLAGREADHISTORY) {
//                cmd = [cmd stringByAppendingString:[NSString stringWithFormat:@"@%@",user.username]];
//            }
//            
//            TL_botCommand *c = [TL_botCommand createWithCommand:cmd n_description:command.n_description];
//            
//            [c setUser:user];
//            
//            [commands addObject:c];
//            
//        }];
//        
//    }];
//    
//    
//    commands = string.length > 0 ? [[commands filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.command BEGINSWITH[c] %@",string]] mutableCopy] : commands;
//    
//    
//    [commands enumerateObjectsUsingBlock:^(TL_botCommand *obj, NSUInteger idx, BOOL *stop) {
//        
//        
//        NSMenuItem *item = [NSMenuItem menuItemWithTitle:[NSString stringWithFormat:@"/%@",obj.command] withBlock:^(id sender) {
//            
//            callback([obj command]);
//            
//            
//            [self close];
//            
//        }];
//        
//        if(obj.n_description.length > 0)
//            [item setSubtitle:obj.n_description];
//        
//         item.representedObject = [[TGMenuItemPhoto alloc] initWithUser:obj.user menuItem:item];
//        
//        [menu addItem:item];
//        
//    }];
//    
//    
//    if(menu.itemArray.count > 0) {
//        [self close];
//        
//        [self setPopover:[[TMMenuPopover alloc] initWithMenu:menu]];
//        
//        [[self popover] setAutoHighlight:NO];
//        
//        [[self popover] showRelativeToRect:rect ofView:view preferredEdge:CGRectMinYEdge];
//        
//        [[self popover].contentViewController selectNext];
//    } else {
//        [self close];
//    }
    
}



@end
