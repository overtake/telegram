//
//  TGModalForwardView.m
//  Telegram
//
//  Created by keepcoder on 21.10.15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGModalForwardView.h"
#import "SelectUsersTableView.h"
#import "MessageTableItem.h"
#import "TGSettingsTableView.h"
@interface TGModalForwardView ()<SelectTableDelegate>
@property (nonatomic,strong) SelectUsersTableView *tableView;
@end

@implementation TGModalForwardView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self setContainerFrameSize:NSMakeSize(300, 370)];
        
        
        [self initialize];
    }
    
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self setContainerFrameSize:NSMakeSize(300, 370)];
    
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
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    for(MessageTableItem *item in _messagesViewController.selectedMessages)
        [ids addObject:item.message];
    
    [ids sortUsingComparator:^NSComparisonResult(TLMessage * a, TLMessage * b) {
        return a.n_id > b.n_id ? NSOrderedDescending : NSOrderedAscending;
    }];

    
    [_tableView.selectedItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TL_conversation *conversation = [obj isKindOfClass:[SelectUserItem class]] ? [[obj valueForKey:@"user"] dialog] : [[obj valueForKey:@"chat"] dialog];
        
        [_messagesViewController forwardMessages:ids conversation:conversation callback:nil];
        
    }];
    
    [_messagesViewController cancelSelectionAndScrollToBottom:NO];
    
    [self close:YES];
    
}


-(void)selectTableDidChangedItem:(id)item {
    
}

@end
