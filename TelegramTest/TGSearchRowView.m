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
        
        _searchField.autoresizingMask = NSViewWidthSizable ;
        
        [self addSubview:_searchField];
        
    }
    
    return self;
}

-(BOOL)becomeFirstResponder {
    return [_searchField becomeFirstResponder];
}

-(void)redrawRow {
    self.searchField.delegate = self.rowItem.table;
}

@end
