//
//  SearchMessageCellView.m
//  Telegram
//
//  Created by keepcoder on 21.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchMessageCellView.h"

@implementation SearchMessageCellView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self setSwipePanelActive:NO];
    }
    
    return self;
}

@end
