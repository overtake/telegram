//
//  MessageTableCellUnreadMarkView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellUnreadMarkView.h"
#import "SpacemanBlocks.h"
@interface MessageTableCellUnreadMarkView ()
@property (nonatomic,strong) TMTextField *textField;
@property (nonatomic,strong) SMDelayedBlockHandle internalId;
@end

@implementation MessageTableCellUnreadMarkView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textField = [[TMTextField alloc] initWithFrame:NSMakeRect(0, -1, self.bounds.size.width, 26)];
        [self.textField setBordered:NO];
        [self.textField setEnabled:NO];
        [self.textField setEditable:NO];
        [self.textField setStringValue:@"2 unread messages"];
        [self.textField setFont:TGSystemFont(13)];
        [self.textField setTextColor:NSColorFromRGB(0x9b9b9b)];
        [self.textField setDrawsBackground:NO];
        [self.textField setAlignment:NSCenterTextAlignment];

        
         [self addSubview:self.textField];
    }
    return self;
}

- (void)setItem:(MessageTableItemUnreadMark *)item {
    [super setItem:item];
    
    [self.textField setStringValue:item.text];
    
    [self.textField sizeToFit];
    
    
    if(item.removeType == RemoveUnreadMarkAfterSecondsType) {
        
        cancel_delayed_block(_internalId);
        
        _internalId = perform_block_after_delay(5,  ^{
            [self.messagesViewController deleteItem:self.item];
        });
        
    }
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.textField setFrameOrigin:NSMakePoint(roundf((NSWidth(self.messagesViewController.view.frame) - NSWidth(_textField.frame))/2), roundf((self.item.viewSize.height - NSHeight(_textField.frame))/2))];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xf4f4f4) set];
    NSRectFill(NSMakeRect(0, 1, NSWidth(self.bounds), NSHeight(self.bounds) - 2));
}

@end
