//
//  TGMessagesDateView.m
//  Telegram
//
//  Created by keepcoder on 28/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGMessagesDateView.h"
#import "TGCTextView.h"
@interface TGMessagesDateView ()
@property (nonatomic,strong) TGCTextView *textView;
@property (nonatomic,weak) MessagesTableView *tableView;
@end

@implementation TGMessagesDateView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWitTable:(MessagesTableView *)tableView {
    if(self = [super initWithFrame:NSMakeRect(0, 0, 60, 40)]) {
        _tableView = tableView;
        
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor redColor].CGColor;
        
        
        [self.tableView.containerView addSubview:self];
        
        [self configure];
    }
    
    return self;
}

-(void)configure {
    [self setCenterByView:self.superview];
}

@end
