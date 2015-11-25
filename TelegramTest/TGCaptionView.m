//
//  TGCaptionView.m
//  Telegram
//
//  Created by keepcoder on 29.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGCaptionView.h"
#import "TGCTextView.h"
@interface TGCaptionView ()

@end





@implementation TGCaptionTextView

-(void)open_link:(NSString *)link itsReal:(BOOL)itsReal {
    if(_item.message.peer_id < 0 && _item.message.fromUser.isBot && [link hasPrefix:TLBotCommandPrefix]) {
        link = [NSString stringWithFormat:@"%@@%@",link,_item.message.fromUser.username];
    }
    
    open_link(link);
}

@end

@implementation TGCaptionView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _textView = [[TGCaptionTextView alloc] initWithFrame:NSZeroRect];
        [_textView setFrameOrigin:NSMakePoint(0, 0)];
        [_textView setEditable:YES];
        [self addSubview:_textView];
                
    }
    
    return self;
}

-(void)setAttributedString:(NSAttributedString *)string fieldSize:(NSSize)size {
    
    [_textView setFrameSize:size];
    [_textView setAttributedString:string];
    
}

-(void)setItem:(MessageTableItem *)item {
    _item = item;
    _textView.item = item;
}

@end
