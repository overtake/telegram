//
//  TGBotCommandsPopup.m
//  Telegram
//
//  Created by keepcoder on 28.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGBotCommandsPopup.h"

@implementation TGBotCommandsPopup



+(void)show:(NSString *)string botInfo:(TLBotInfo *)botInfo view:(NSView *)view  ofRect:(NSRect)rect callback:(void (^)(NSString *command))callback  {
    
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
    
    
    NSArray *commands = string.length > 0 ? [botInfo.commands filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.command BEGINSWITH[c] %@",string]] : botInfo.commands;
    
    
    __block NSMutableArray *allCommands;
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
        allCommands = [transaction objectForKey:@"commands" inCollection:BOT_COMMANDS];
        
        if(!allCommands) {
            allCommands = [[NSMutableArray alloc] init];
        }
    }];
    
    
    NSMutableArray *localCommands = [[allCommands subarrayWithRange:NSMakeRange(0, MIN(allCommands.count,20))] mutableCopy];
    
    
    [commands enumerateObjectsUsingBlock:^(TL_botCommand *obj, NSUInteger idx, BOOL *stop) {
        
        [localCommands removeObject:obj.command];
        
        NSMenuItem *item = [NSMenuItem menuItemWithTitle:[NSString stringWithFormat:@"/%@",obj.command] withBlock:^(id sender) {
            
            callback([obj command]);
            
            
            [self close];
            
        }];
        
        [item setSubtitle:obj.n_description];
        
        [menu addItem:item];
        
    }];
    
    
    [localCommands enumerateObjectsUsingBlock:^(NSString*lc, NSUInteger idx, BOOL *stop) {
        
        NSMenuItem *item = [NSMenuItem menuItemWithTitle:[NSString stringWithFormat:@"/%@",lc] withBlock:^(id sender) {
            
            callback(lc);
            
            [self close];
            
        }];
        
        
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
