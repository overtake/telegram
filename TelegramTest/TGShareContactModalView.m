//
//  TGShareContactModalView.m
//  Telegram
//
//  Created by keepcoder on 23.10.15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGShareContactModalView.h"
#import "SelectUsersTableView.h"
#import "MessageTableItem.h"

@interface TGShareContactModalView ()<SelectTableDelegate>
@property (nonatomic,strong) SelectUsersTableView *tableView;
@end

@implementation TGShareContactModalView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self setContainerFrameSize:NSMakeSize(300, 300)];
        
        
        [self initialize];
    }
    
    return self;
}

-(void)initialize {
    _tableView = [[SelectUsersTableView alloc] initWithFrame:NSMakeRect(0, 50, self.containerSize.width, self.containerSize.height - 50)];
    
    _tableView.selectDelegate = self;
    _tableView.selectLimit = 10;
    
    [self enableCancelAndOkButton];
    
    [self addSubview:_tableView.containerView];
    
    [_tableView readyConversations];
}

-(void)okAction {

    [_tableView.selectedItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TL_conversation *conversation = [obj isKindOfClass:[SelectUserItem class]] ? [[obj valueForKey:@"user"] dialog] : [[obj valueForKey:@"chat"] dialog];
        
        [_messagesViewController shareContact:_user forConversation:conversation callback:nil];
        
    }];
    
    [self close:YES];
    
}


-(void)selectTableDidChangedItem:(id)item {
    
}


@end
