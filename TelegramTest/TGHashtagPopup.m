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

+(void)show:(NSString *)string peer_id:(int)peer_id view:(NSView *)view  ofRect:(NSRect)rect callback:(void (^)(NSString *userName))callback;  {
    
    
    __block NSMutableDictionary *tags;
    
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        tags = [[transaction objectForKey:@"htags" inCollection:@"hashtags"] mutableCopy];
        
        NSMutableDictionary *prs = [transaction objectForKey:[NSString stringWithFormat:@"htags_%d",peer_id] inCollection:@"hashtags"];
        
        [tags addEntriesFromDictionary:prs];
        
    }];
    
    
    NSArray *list = [[tags allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return obj1[@"count"] < obj2[@"count"];
        
    }];
    
    
    if(string.length > 0)
    {
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag BEGINSWITH[c] %@",string]];
    }
    
    
    
    list = [list subarrayWithRange:NSMakeRange(0, MIN(20,list.count))];
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
    
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSMenuItem *item = [NSMenuItem menuItemWithTitle:[NSString stringWithFormat:@"#%@",obj[@"tag"]] withBlock:^(id sender) {
            
            callback(obj[@"tag"]);
            
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
