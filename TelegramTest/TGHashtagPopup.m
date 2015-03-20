//
//  TGHashtagPopup.m
//  Telegram
//
//  Created by keepcoder on 20.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGHashtagPopup.h"

@implementation TGHashtagPopup


static TMMenuPopover *popover;

+(void)show:(NSString *)string view:(NSView *)view ofRect:(NSRect)rect callback:(void (^)(NSString *userName))callback;  {
    
    
    __block NSArray *list;
    
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        list = [transaction objectForKey:@"tags" inCollection:@"hashtags"];
        
    }];
    
    if(string.length > 0)
    {
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@",string]];
    }
    
    
    
    list = [list subarrayWithRange:NSMakeRange(0, MIN(20,list.count))];
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
    
    [list enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        
        NSMenuItem *item = [NSMenuItem menuItemWithTitle:[NSString stringWithFormat:@"#%@",obj] withBlock:^(id sender) {
            
            callback(obj);
            
            [popover close];
            popover = nil;
            
        }];
        
        
        [menu addItem:item];
        
    }];
    
    if(menu.itemArray.count > 0) {
        [popover close];
        
        popover = [[TMMenuPopover alloc] initWithMenu:menu];
        
        [popover setAutoHighlight:NO];
        
        [popover showRelativeToRect:rect ofView:view preferredEdge:CGRectMinYEdge];
        
        [popover.contentViewController selectNext];
    } else {
        [popover close];
        popover = nil;
    }
    
}


+(BOOL)isVisibility {
    return [popover isShown];
    
}

+(void)performSelected {
    [popover.contentViewController performSelected];
}

+(void)selectNext {
    [popover.contentViewController selectNext];
}

+(void)selectPrev {
    [popover.contentViewController selectPrev];
}

+(void)close {
    [popover close];
}




@end
