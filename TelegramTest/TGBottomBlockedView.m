//
//  TGBottomBlockedView.m
//  Telegram
//
//  Created by keepcoder on 19/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGBottomBlockedView.h"
#import "TGTextLabel.h"
@interface TGBottomBlockedView ()
@property (nonatomic,strong) TGTextLabel *textLabel;
@end

@implementation TGBottomBlockedView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textLabel = [[TGTextLabel alloc] init];
        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
        [self addSubview:_textLabel];
    }
    
    return self;
}

-(void)mouseUp:(NSEvent *)theEvent {
    
}

-(void)mouseMoved:(NSEvent *)theEvent {
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}




-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_textLabel setText:_textLabel.text maxWidth:newSize.width - 40];
    [_textLabel setCenterByView:self];
}

-(void)setBlockedText:(NSString *)text {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    [attr appendString:text withColor:BLUE_UI_COLOR];
    [attr setFont:TGSystemFont(14) forRange:attr.range];
    
    [_textLabel setText:attr maxWidth:NSWidth(self.frame) - 40];
    [_textLabel setCenterByView:self];
}

@end
