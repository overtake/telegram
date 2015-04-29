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

@implementation TGCaptionView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _textView = [[TGCTextView alloc] initWithFrame:NSZeroRect];
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

@end
