//
//  MessageTableCellHoleCellView.m
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "MessageTableCellHoleView.h"
#import "TGCTextView.h"
@interface MessageTableCellHoleView ()
@property (nonatomic,strong) TGCTextView *textView;
@end

@implementation MessageTableCellHoleView

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


-(void)setItem:(MessageTableItemHole *)item {
    [super setItem:item];
    
    
    [_textView setFrameSize:item.textSize];
    [_textView setAttributedString:item.text];
    
    
    
    [_textView setCenteredXByView:_textView.superview];
}

@end
