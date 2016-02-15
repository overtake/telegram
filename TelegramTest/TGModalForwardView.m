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
#import "TGCirclularCounter.h"
@interface TGModalForwardView ()<SelectTableDelegate>
@property (nonatomic,strong) SelectUsersTableView *tableView;
@property (nonatomic,strong) TGCirclularCounter *counter;
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
    
    [self setContainerFrameSize:NSMakeSize(MAX(300,MIN(450,newSize.width - 60)), MAX(320,MIN(555,newSize.height - 60)))];

}

-(void)setContainerFrameSize:(NSSize)size {
    [super setContainerFrameSize:size];
    
    
    [self updateCounterOrigin];
}

-(void)modalViewDidShow {
    [self setContainerFrameSize:NSMakeSize(MAX(300,MIN(450,NSWidth(self.frame) - 60)), MAX(330,MIN(555,NSHeight(self.frame) - 60)))];
}

-(void)initialize {
    _tableView = [[SelectUsersTableView alloc] initWithFrame:NSMakeRect(0, 50, self.containerSize.width, self.containerSize.height - 50)];
    
    _tableView.selectDelegate = self;
    _tableView.selectLimit = 30;
    _tableView.searchHeight = 60;
    [self enableCancelAndOkButton];
    
    [self addSubview:_tableView.containerView];
    
    [_tableView readyConversations];
    
    [self.ok setTitle:NSLocalizedString(@"Conversation.Action.Share", nil) forControlState:BTRControlStateNormal];
    [self.ok setTitleColor:GRAY_TEXT_COLOR forControlState:BTRControlStateDisabled];
    
    _counter = [[TGCirclularCounter alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
    
    _counter.backgroundColor = NSColorFromRGB(0x5098d3);
    [_counter setTextFont:TGSystemFont(13)];
    [_counter setTextColor:[NSColor whiteColor]];
    
    [self selectTableDidChangedItem:nil];
    
    [self addSubview:_counter];
    
}

-(void)updateCounterOrigin {
    int w = [self.ok.titleLabel.attributedStringValue size].width;
    
    int x = NSMinX(self.ok.frame) + ( ((NSWidth(self.ok.frame) - w) /2) + w);
    
    [_counter setFrameOrigin:NSMakePoint(x - 5 , 0)];
}


-(void)okAction {
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    for(MessageTableItem *item in _messagesViewController.selectedMessages)
        [ids addObject:item.message];
    
    [ids sortUsingComparator:^NSComparisonResult(TLMessage * a, TLMessage * b) {
        return a.n_id > b.n_id ? NSOrderedDescending : NSOrderedAscending;
    }];

    
    [_tableView.selectedItems enumerateObjectsUsingBlock:^(SelectUserItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TL_conversation *conversation = [obj.object dialog];
        
        [_messagesViewController forwardMessages:ids conversation:conversation callback:nil];
        
    }];
    
    [_messagesViewController cancelSelectionAndScrollToBottom:NO];
    
    [self close:YES];
    
}

-(void)selectTableDidChangedItem:(id)item {
    
    
    [self.ok setEnabled:_tableView.selectedItems.count > 0];
    
    [[_counter animator] setAlphaValue:_tableView.selectedItems.count == 0 ? 0.0f : 1.0f];
    
    [self.ok setTitleColor:_tableView.selectedItems.count > 0 ? LINK_COLOR : GRAY_TEXT_COLOR forControlState:BTRControlStateNormal];
    
    _counter.backgroundColor = _tableView.selectedItems.count > 0 ? NSColorFromRGB(0x5098d3) : DIALOG_BORDER_COLOR;
    
    //_counter.animated = !isHidden || _tableView.selectedItems.count > 1;
    [_counter setStringValue:[NSString stringWithFormat:@"%ld",MAX(1,_tableView.selectedItems.count)]];
}

@end
