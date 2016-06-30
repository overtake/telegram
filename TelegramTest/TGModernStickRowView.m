//
//  TGModernStickRowView.m
//  Telegram
//
//  Created by keepcoder on 21/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernStickRowView.h"
#import "TGTextLabel.h"
#import "TGModernStickRowItem.h"


@interface TGModernStickRowView ()

@end

@implementation TGModernStickRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(self.isStickView) {
        [DIALOG_BORDER_COLOR set];
        NSRectFill(NSMakeRect(0, 0, NSWidth(self.frame), DIALOG_BORDER_WIDTH));
    }
    
    
    // Drawing code here.
}

-(void)setIsStickView:(BOOL)isStickView {
    _isStickView = isStickView;
    
    [self setNeedsDisplay:YES];
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textLabel = [[TGTextLabel alloc] initWithFrame:NSMakeRect(5 + 6, 0, 0, 0)];
        [self addSubview:_textLabel];
        self.backgroundColor = NSColorFromRGBWithAlpha(0xffffff, 1.0);
    }
    
    return self;
}


-(void)redrawRow {
    [super redrawRow];
    
    TGModernStickRowItem *item = (TGModernStickRowItem *)self.rowItem;
    
    [_textLabel setText:item.header maxWidth:NSWidth(self.frame) - 20];
    
    [_textLabel setCenteredYByView:self];
}


@end
