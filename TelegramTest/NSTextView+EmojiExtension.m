//
//  NSTextView+EmojiExtension.m
//  Telegram
//
//  Created by keepcoder on 02.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSTextView+EmojiExtension.h"
#import "RBLPopover.h"
#import "TGMentionPopup.h"
#import "TGModernESGViewController.h"
@implementation NSTextView (EmojiExtension)


DYNAMIC_PROPERTY(EmojiPopover)


-(void)showEmoji {
    TGModernESGViewController *emojiViewController = [TGModernESGViewController controller];
    
    
    
    RBLPopover *popover = [self getEmojiPopover];
    
    if(!popover) {
        popover = [[RBLPopover alloc] initWithContentViewController:emojiViewController];
    }
    
    [emojiViewController.emojiViewController setInsertEmoji:^(NSString *emoji) {
        [self insertText:emoji];
    }];
    
    [self setEmojiPopover:popover];
    
    
    NSRect rect = [self firstRectForCharacterRange:[self selectedRange]];
    
    NSRect textViewBounds = [self convertRectToBase:[self bounds]];
    textViewBounds.origin = [[self window] convertBaseToScreen:textViewBounds.origin];
    
    rect.origin.x -= textViewBounds.origin.x;
    rect.origin.y-= textViewBounds.origin.y;
    

    if(!popover.isShown) {
        [popover showRelativeToRect:rect ofView:self.window.contentView preferredEdge:CGRectMinYEdge];
        [emojiViewController show];
    }

}





@end
