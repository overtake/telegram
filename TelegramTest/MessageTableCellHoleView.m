//
//  MessageTableCellHoleCellView.m
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "MessageTableCellHoleView.h"
#import "TGCTextView.h"

@interface TGCustomTextView : TGCTextView
@property (nonatomic,weak) MessageTableItemHole *holeItem;
@property (nonatomic,weak) MessagesViewController *controller;
@end


@implementation TGCustomTextView

-(void)open_link:(NSString *)link itsReal:(BOOL)itsReal {
    if([link isEqualToString:@"showNewMessages"])
        [_controller jumpToLastMessages:YES];
    else if([link isEqualToString:@"showComments"]) {
        
        [_controller showMessage:_holeItem.message fromMsg:nil switchDiscussion:YES];
    }
}

@end

@interface MessageTableCellHoleView ()
@property (nonatomic,strong) TGCustomTextView *textView;
@end

@implementation MessageTableCellHoleView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textView = [[TGCustomTextView alloc] initWithFrame:NSZeroRect];
        
        [self addSubview:_textView];
        
        
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(void)setItem:(MessageTableItemHole *)item {
    [super setItem:item];
    
    _textView.holeItem = item;
    
    _textView.controller = self.messagesViewController;
    
    [_textView setFrameSize:item.textSize];
    [_textView setAttributedString:item.text];
    
    
    
    [_textView setCenteredXByView:_textView.superview];
    
    [_textView setFrameOrigin:NSMakePoint(NSMinX(_textView.frame), roundf((item.viewSize.height - NSHeight(_textView.frame))/2))];
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(NSMenu *)contextMenu {
    return nil;
}

@end
