//
//  MessageTableCellUnreadMarkView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 14.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellUnreadMarkView.h"

@interface MessageTableCellUnreadMarkView ()
@property (nonatomic,strong) TMTextField *textField;
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
        [self.textField setFont:[NSFont fontWithName:@"HelveticaNeue" size:13]];
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
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.messagesViewController deleteItem:self.item];
    });
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.textField setFrameSize:NSMakeSize(newSize.width, 26)];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xf4f4f4) set];
    NSRectFill(self.bounds);    
}

@end
