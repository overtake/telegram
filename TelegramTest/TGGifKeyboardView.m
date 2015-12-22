//
//  TGGifKeyboardView.m
//  Telegram
//
//  Created by keepcoder on 22/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGGifKeyboardView.h"

@interface TGGifKeyboardView ()
@property (nonatomic,strong) TMTableView *tableView;
@end

@implementation TGGifKeyboardView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _tableView = [[TMTableView alloc] initWithFrame:self.bounds];
        
        [self addSubview:_tableView.containerView];
    }
    
    return self;
}

@end
