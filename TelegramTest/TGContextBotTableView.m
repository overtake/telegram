//
//  TGContextBotTableView.m
//  Telegram
//
//  Created by keepcoder on 22/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGContextBotTableView.h"
#import "TGContextRowItem.h"
@interface TGContextBotTableView ()

@end

@implementation TGContextBotTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        
    }
    
    return self;
    
}


- (void)selectionDidChange:(NSInteger)row item:(TGContextRowItem *) item {
    if(_didSelectedItem) {
        _didSelectedItem();
    }
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TGGeneralRowItem *) item {
    return YES;
}

- (BOOL)isSelectable:(NSInteger)row item:(TGGeneralRowItem *) item {
    return YES;
}


@end
