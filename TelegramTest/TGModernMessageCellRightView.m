//
//  TGModernMessageCellRightView.m
//  Telegram
//
//  Created by keepcoder on 24/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernMessageCellRightView.h"
#import "TGTextLabel.h"
#import "MessageStateLayer.h"
@interface TGModernMessageCellRightView ()
@property (nonatomic,strong) TGTextLabel *dateLabel;
@property (nonatomic,strong) MessageStateLayer *stateLayer;
@end

@implementation TGModernMessageCellRightView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.backgroundColor = [NSColor redColor];
        _dateLabel = [[TGTextLabel alloc] init];
        
        [self addSubview:_dateLabel];
        
        
    }
    
    return self;
}

-(void)setItem:(MessageTableItem *)item container:(TGModernMessageCellContainerView *)container {
    _item = item;
    _container = container;
    
    if(item.message.n_out || self.item.message.isPost) {
        
        if(!_stateLayer) {
            _stateLayer = [[MessageStateLayer alloc] initWithFrame:NSZeroRect];
            [self addSubview:_stateLayer];
        }
        [_stateLayer setFrameSize:NSMakeSize(NSWidth(self.frame) - item.dateSize.width - item.defaultContentOffset, item.rightSize.height)];
      
        [_stateLayer setState:container.actionState];
        
    } else {
        [_stateLayer removeFromSuperview];
        _stateLayer = nil;
    }
    
    [_dateLabel setFrame:NSMakeRect(NSWidth(self.frame) - item.dateSize.width, 0, item.dateSize.width, item.dateSize.height)];
    
    [_dateLabel setText:item.dateAttributedString maxWidth:item.dateSize.width height:item.dateSize.height];
    
}

-(void)setEditable:(BOOL)editable animated:(BOOL)animated {
    
}

-(void)setState:(MessageTableCellState)actionState animated:(BOOL)animated {
    [_stateLayer setState:actionState animated:animated];
}

@end
