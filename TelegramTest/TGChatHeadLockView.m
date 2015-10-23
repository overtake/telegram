//
//  TGChatHeadLockView.m
//  Telegram
//
//  Created by keepcoder on 23.10.15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGChatHeadLockView.h"

@interface TGChatHeadLockView ()
@property (nonatomic,strong) TMTextField *textField;
@end

@implementation TGChatHeadLockView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textField = [TMTextField defaultTextField];
        
        [_textField setStringValue:NSLocalizedString(@"LockedChatHead.Description", nil)];
        [_textField setFont:TGSystemBoldFont(13)];
        [[_textField cell] setLineBreakMode:NSLineBreakByWordWrapping];
        [_textField setTextColor:GRAY_TEXT_COLOR];
        
        [self addSubview:_textField];
        
        [_textField setAlignment:NSCenterTextAlignment];
        
        self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        self.backgroundColor = [NSColor whiteColor];
        
        [self setFrameSize:self.frame.size];
    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_textField setFrameSize:[_textField.attributedStringValue sizeForTextFieldForWidth:newSize.width - 20]];
    
    [_textField setCenterByView:_textField.superview];
}

@end
