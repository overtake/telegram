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
#import "TGPopoverHint.h"
@implementation NSTextView (EmojiExtension)


DYNAMIC_PROPERTY(EmojiPopover)


-(void)showEmoji {
    TGModernESGViewController *emojiViewController = [TGModernESGViewController controller];
    
    [emojiViewController setMessagesViewController:nil];
    
    RBLPopover *popover = [self getEmojiPopover];
    
    if(!popover) {
        popover = [[RBLPopover alloc] initWithContentViewController:(NSViewController *)emojiViewController];
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

-(void)tryShowHintView:(TL_conversation *)conversation {
    NSRect rect = [self firstRectForCharacterRange:[self selectedRange]];
    
    NSRect textViewBounds = [self convertRectToBase:[self bounds]];
    textViewBounds.origin = [[self window] convertBaseToScreen:textViewBounds.origin];
    
    rect.origin.x -= textViewBounds.origin.x;
    rect.origin.y-= (textViewBounds.origin.y + 10);
    
    rect.origin.x += 144;
    
    
    NSString *search = nil;
    NSString *string = self.string;
    NSRange selectedRange = self.selectedRange;
    TGHintViewShowType type = [TGMessagesHintView needShowHint:string selectedRange:selectedRange completeString:&string searchString:&search];
    
    if(type == TGHintViewShowMentionType && search != nil && ![string hasPrefix:@" "]) {
        
        [TGPopoverHint close];
        
        [[TGPopoverHint hintView] showMentionPopupWithQuery:search conversation:conversation chat:conversation.chat allowInlineBot:NO allowUsernameless:NO choiceHandler:^(NSString *result) {
            [self insertText:[result stringByAppendingString:@" "] replacementRange:NSMakeRange(selectedRange.location - search.length, search.length)];
            
            [TGPopoverHint close];
            
            
            [self setSelectedRange:NSMakeRange(self.string.length, 0)];
            
        }];
        
        
        if(![TGPopoverHint hintView].isHidden) {
            [TGPopoverHint showHintViewForView:self.window.contentView ofRect:rect];
        } else {
            
        }
        
    } else {
        [TGPopoverHint close];
    }

}



@end
