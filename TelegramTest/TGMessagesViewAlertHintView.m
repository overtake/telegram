//
//  TGMessagesViewAlertHintView.m
//  Telegram
//
//  Created by keepcoder on 26/03/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGMessagesViewAlertHintView.h"
#import "TGTextLabel.h"

@interface TGMessagesViewAlertHintView ()
@property (nonatomic,strong) TGTextLabel *textLabel;
@property (nonatomic,strong) NSMutableAttributedString *attr;
@property (nonatomic,assign) NSSize textSize;
@end

@implementation TGMessagesViewAlertHintView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
}

-(void)setBackgroundColor:(NSColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _textLabel.backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textLabel = [[TGTextLabel alloc] init];
        [self addSubview:_textLabel];
        self.autoresizingMask = NSViewWidthSizable;
        
    }
    
    return self;
}

-(void)setText:(NSString *)text backgroundColor:(NSColor *)backgroundColor {
    
    self.backgroundColor = backgroundColor;
    
    _attr = [[NSMutableAttributedString alloc] init];
    
    [_attr appendString:[text fixEmoji] withColor:[NSColor whiteColor]];
    [_attr setFont:TGSystemFont(13) forRange:_attr.range];
    [_attr addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:_attr
     .range];
    
    _textSize = [_attr coreTextSizeOneLineForWidth:INT32_MAX];
    
    [_textLabel setText:_attr maxWidth:_textSize.width];
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_textLabel setText:_attr maxWidth:MIN(_textSize.width,newSize.width - 20) height:_textSize.height];
    
    [_textLabel setCenterByView:self];
    
}

@end
