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
        
        _forwardName = [[TGTextLabel alloc] initWithText:nil maxWidth:100];
      //  _forwardName.backgroundColor = [NSColor redColor];
        [self addSubview:_forwardName];
    }
    
    return self;
}


-(int)yContentOffset {
    return _tableItem.isHeaderForwardedMessage ? NSMaxY(_forwardHeader.frame) + _tableItem.contentHeaderOffset : 0;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [BLUE_SEPARATOR_COLOR set];

    
    NSRectFill(NSMakeRect(0, self.yContentOffset , 2, NSHeight(dirtyRect) - self.yContentOffset - _tableItem.defaultContentOffset));
    
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
            
            _forwardHeader = [[TGTextLabel alloc] initWithText:nil maxWidth:100];
            [self addSubview:_forwardHeader];
        }
        [_forwardHeader setText:_tableItem.forwardHeaderAttr maxWidth:self.containerWidth  height:_tableItem.forwardHeaderSize.height];

    } else {
        [_forwardHeader removeFromSuperview];
        _forwardHeader = nil;
    }
    
    [_forwardName setText:_tableItem.forwardName maxWidth:self.containerWidth  height:_tableItem.forwardNameSize.height];
    
    
    [_forwardName setFrameOrigin:NSMakePoint(_tableItem.defaultOffset, self.yContentOffset)];
    [_contentView setFrameOrigin:NSMakePoint(_tableItem.defaultOffset, NSMaxY(_forwardName.frame) + _tableItem.contentHeaderOffset)];
    
    [self setNeedsDisplay:YES];
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    if(!anim) {
        _forwardHeader.backgroundColor = color;
        _forwardName.backgroundColor = color;
    } else {
        [_forwardHeader pop_addAnimation:anim forKey:@"background"];
        [_forwardName pop_addAnimation:anim forKey:@"background"];
    }
    
    
}

-(int)containerWidth {
    return NSWidth(self.frame) - _tableItem.defaultOffset;
}


@end
