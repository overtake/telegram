//
//  DialogRedButtonView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/31/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGSwipeRedView.h"

@implementation TGSwipeRedView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        self.attributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Delete", nil) attributes:@{NSFontAttributeName: TGSystemFont(13), NSForegroundColorAttributeName: [NSColor whiteColor]}];
        self.size = [self.attributedString size];
        
        [self setFrameSize:NSMakeSize(self.size.width + 36, self.bounds.size.height)];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xec6f6f) set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height));
    
    [self.attributedString drawAtPoint:NSMakePoint(roundf((self.bounds.size.width - self.size.width) / 2.0), roundf((self.bounds.size.height - self.size.height) / 2.0))];
}

- (void)mouseDown:(NSEvent *)theEvent {
    //    MTLog(@"");
    [super mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
    //    MTLog(@"");
    if(theEvent.clickCount != 1) {
        [super mouseUp:theEvent];
    } else {
        if(!self.disable) {
            TGConversationTableItem *item = (TGConversationTableItem *)[self.itemView rowItem];
            [[[Telegram rightViewController] messagesViewController] deleteDialog:item.conversation];
        } else {
            [super mouseUp:theEvent];
        }
    }
}

@end
