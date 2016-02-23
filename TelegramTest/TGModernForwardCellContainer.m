//
//  TGModernForwardCellContainer.m
//  Telegram
//
//  Created by keepcoder on 22/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernForwardCellContainer.h"
#import "TGTextLabel.h"
#import "TGFont.h"
@interface TGModernForwardCellContainer ()
@property (nonatomic,strong) TGTextLabel *forwardHeader;
@property (nonatomic,strong) TGTextLabel *forwardName;
@end

@implementation TGModernForwardCellContainer

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _forwardName = [[TGTextLabel alloc] initWithText:@"" textColor:[NSColor redColor] font:TGCoreTextSystemFontOfSize(13) maxWidth:100];
        [self addSubview:_forwardName];
        
        _forwardName.backgroundColor = [NSColor blueColor];
    }
    
    return self;
}


-(int)yContentOffset {
    return _tableItem.isHeaderForwardedMessage ? 16 : 0;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [BLUE_SEPARATOR_COLOR set];

    
    NSRectFill(NSMakeRect(0, self.yContentOffset , 2, NSHeight(dirtyRect) - self.yContentOffset));
    
}

-(BOOL)isFlipped {
    return YES;
}


-(void)setTableItem:(MessageTableItem *)tableItem contentView:(TMView *)contentView containerView:(TGModernMessageCellContainerView *)containerView {
    _tableItem = tableItem;
    _contentView = contentView;
    _containerView = containerView;
    [self layoutContainer];
}


-(void)layoutContainer {
    
    if(_tableItem.isHeaderForwardedMessage) {
        if(!_forwardHeader) {
            _forwardHeader = [[TGTextLabel alloc] initWithText:@"" textColor:LINK_COLOR font:TGCoreTextSystemFontOfSize(13) maxWidth:100];
            _forwardHeader.backgroundColor = [NSColor redColor];
            [self addSubview:_forwardHeader];
        }
        
        [_forwardHeader setText:_tableItem.forwardHeaderAttr.string maxWidth:100];

    } else {
        [_forwardHeader removeFromSuperview];
        _forwardHeader = nil;
    }
    
    [_forwardName setFrameOrigin:NSMakePoint(_containerView.defaultOffset, self.yContentOffset)];
    
   // [_forwardName setAttributedString:_tableItem.forwardMessageAttributedString];
    [_forwardName sizeToFit];//need fix them
    
    [_contentView setFrameOrigin:NSMakePoint(_containerView.defaultOffset, NSMaxY(_forwardName.frame) + _containerView.defaultContentOffset)];
    
    [self setNeedsDisplay:YES];
}


@end
