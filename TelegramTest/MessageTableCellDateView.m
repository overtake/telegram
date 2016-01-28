//
//  MessageTableCellDateView.m
//  Telegram
//
//  Created by keepcoder on 28/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "MessageTableCellDateView.h"
#import "TGCTextView.h"
@interface MessageTableCellDateView ()
@property (nonatomic,strong) TGCTextView *textView;
@end

@implementation MessageTableCellDateView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textView = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        
        [self addSubview:_textView];
        
        
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(void)setItem:(MessageTableItemDate *)item {
    [super setItem:item];
    

    
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
