//
//  TGGeneralSearchRowView.m
//  Telegram
//
//  Created by keepcoder on 29/10/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGGeneralSearchRowView.h"
#import "TGSearchRowItem.h"
@interface TGGeneralSearchRowView ()
@property (nonatomic,strong) TMSearchTextField *searchField;
@end

@implementation TGGeneralSearchRowView


-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _searchField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(10, 10, NSWidth(frameRect) - 20, 30)];
        
        
        [self addSubview:_searchField];
        
    }
    
    return self;
}



-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    TGSearchRowItem *rowItem = (TGSearchRowItem *) [self rowItem];
    
    [_searchField setFrame:NSMakeRect(MAX(rowItem.xOffset, 10), 10, newSize.width - MAX(rowItem.xOffset, 10)*2, rowItem.height - 20)];
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    [self.searchField becomeFirstResponder];
}

-(BOOL)becomeFirstResponder {
    return [_searchField becomeFirstResponder];
}

-(void)redrawRow {
    
    TGSearchRowItem *rowItem = (TGSearchRowItem *) [self rowItem];
    
    self.searchField.delegate = rowItem.delegate;

}

@end
