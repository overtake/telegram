//
//  TGProfileParamView.m
//  Telegram
//
//  Created by keepcoder on 03/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGProfileParamView.h"

#import "NS(Attributed)String+Geometrics.h"
#import "TGCTextView.h"
#import "TGProfileParamItem.h"
@interface TGProfileParamView()
@property (nonatomic, strong) TGCTextView *textView;
@property (nonatomic,strong) TMTextField *headerField;
@end

@implementation TGProfileParamView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable];
        self.textView = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        [self.textView setEditable:YES];
        [self addSubview:self.textView];
        
        _headerField = [TMTextField defaultTextField];
                
        [_headerField setFont:TGSystemFont(13)];
        [_headerField setTextColor:BLUE_UI_COLOR];
        
        [self addSubview:_headerField];
        
    }
    return self;
}


-(TGProfileParamItem *)item {
    return (TGProfileParamItem *)[self rowItem];
}

-(void)redrawRow {
    [super redrawRow];
    
    [self setHeader:self.item.header];
    [self.textView setAttributedString:self.item.value];
    
    [self.textView setFrameSize:self.item.size];
}



-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    int totalHeight = NSHeight(_textView.frame) + NSHeight(_headerField.frame);
    
    [_textView setFrameOrigin:NSMakePoint(self.item.xOffset, roundf((newSize.height - totalHeight)/2))];
    [_headerField setFrameOrigin:NSMakePoint(self.item.xOffset - 2, roundf((newSize.height - totalHeight)/2 + NSHeight(_textView.frame)))];
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(NSString *)string {
    return [self.textView attributedString].string;
}

- (void)setHeader:(NSString *)header {
   
    
    [_headerField setStringValue:header];
    [_headerField sizeToFit];
    
    [self setFrameSize:self.frame.size];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(self.item.xOffset, 0, self.bounds.size.width - self.item.xOffset * 2, DIALOG_BORDER_WIDTH));
}

@end