//
//  TGSearchRowView.m
//  Telegram
//
//  Created by keepcoder on 30.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSearchRowView.h"

@implementation TGSearchRowView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _searchField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(10, 10, NSWidth(frameRect) - 20, 30)];
        
        
        [self addSubview:_searchField];
        
    }
    
    return self;
}

-(void)setXOffset:(int)xOffset {
    _xOffset = xOffset;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_searchField setFrame:NSMakeRect(MAX(_xOffset, 10), NSMinY(_searchField.frame), newSize.width - MAX(_xOffset, 10)*2, NSHeight(_searchField.frame))];
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    [self.searchField becomeFirstResponder];
}

-(BOOL)becomeFirstResponder {
    return [_searchField becomeFirstResponder];
}

-(void)redrawRow {
    self.searchField.delegate = self.rowItem.table;
    
    if(_delegate)
    {
        self.searchField.delegate = _delegate;
    }
}

@end
