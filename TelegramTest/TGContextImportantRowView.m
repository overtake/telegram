//
//  TGContextImportantRowView.m
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGContextImportantRowView.h"
#import "TGTextLabel.h"

@interface TGContextImportantRowView ()
@property (nonatomic,strong) TGTextLabel *textLabel;
@end

@implementation TGContextImportantRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(0, 0, NSWidth(self.frame), 1));
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textLabel = [[TGTextLabel alloc] init];
        [_textLabel setFrameOrigin:NSMakePoint(10, 0)];
        _textLabel.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
        [self addSubview:_textLabel];
    }
    
    return self;
}

-(void)redrawRow {
    [super redrawRow];
    TGContextImportantRowItem *item = (TGContextImportantRowItem *)[self rowItem];
    
    [_textLabel setText:item.header maxWidth:NSWidth(self.frame) - 20];
    [_textLabel setCenterByView:self];
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    
    TGContextImportantRowItem *item = (TGContextImportantRowItem *)[self rowItem];
    [_textLabel setText:item.header maxWidth:NSWidth(self.frame) - 20];
     [_textLabel setCenterByView:self];
}

@end
