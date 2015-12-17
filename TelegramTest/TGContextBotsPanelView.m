//
//  TGContextBotsPanelView.m
//  Telegram
//
//  Created by keepcoder on 15/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGContextBotsPanelView.h"

@interface TGContextBotsPanelView ()
@property (nonatomic,strong) TMTableView *tableView;
@end

@implementation TGContextBotsPanelView

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

-(void)initializeContextBotWithUser:(TLInputUser *)user contextRequestString:(NSString *)requestString {
    
    [RPCRequest sendRequest:[TLAPI_messages_getContextBotResults createWithBot:user query:requestString offset:nil] successHandler:^(id request, id response) {
        
        int bp = 0;
        
    } errorHandler:^(id request, RpcError *error) {
        
    }];
    
}

@end
