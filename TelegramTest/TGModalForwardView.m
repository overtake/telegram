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


@property (nonatomic,strong) BTRButton *cpyLinkPost;

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
    
    [self.ok.titleLabel sizeToFit];
    
    [self.ok setFrameSize:NSMakeSize(NSWidth(self.ok.titleLabel.frame) + 20, NSHeight(self.ok.frame))];
    
    _counter = [[TGCirclularCounter alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
    
    _counter.backgroundColor = NSColorFromRGB(0x5098d3);
    [_counter setTextFont:TGSystemFont(13)];
    [_counter setTextColor:[NSColor whiteColor]];
    
    [self selectTableDidChangedItem:nil];
    
    [self addSubview:_counter];
    
}

-(void)setMessageCaller:(TL_localMessage *)messageCaller {
    _messageCaller = messageCaller;
    
    [self selectTableDidChangedItem:nil];
}

-(void)updateCounterOrigin {
    int w = [self.ok.titleLabel.attributedStringValue size].width;
    
    int x = NSMinX(self.ok.frame) + ( ((NSWidth(self.ok.frame) - w) /2) + w);
    
    [_counter setFrameOrigin:NSMakePoint(x - 5 , 0)];
}

-(BOOL)isShareModalType {
    return _messageCaller.isPost && _messageCaller.chat.username > 0 && !_user;
}

-(void)okAction {
    
    if(_tableView.selectedItems.count == 0 && self.isShareModalType) {
        
        TLChat *chat = _messageCaller.chat;
        
        
        __block NSString *link = @"";
        
        weak();
        
        dispatch_block_t copy_block = ^{
            dispatch_after_seconds(0.1, ^{
                NSPasteboard* cb = [NSPasteboard generalPasteboard];
                
                [cb declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:weakSelf];
                [cb setString:link forType:NSStringPboardType];
                
                [self close:YES];
                [TMViewController hideModalProgressWithSuccess];
            });
            
        };
        
        [TMViewController showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_channels_exportMessageLink createWithChannel:chat.inputPeer n_id:_messageCaller.n_id] successHandler:^(id request, TL_exportedMessageLink *response) {
            
            link = response.link;
            
            copy_block();
            
        } errorHandler:^(id request, RpcError *error) {
            alert(appName(), NSLocalizedString(error.error_msg, nil));
            [TMViewController hideModalProgress];
        }];
        
    }
    
    if(!_user) {
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        for(MessageTableItem *item in _messagesViewController.selectedMessages)
            [ids addObject:item.message];
        
        [ids sortUsingComparator:^NSComparisonResult(TLMessage * a, TLMessage * b) {
            return a.n_id > b.n_id ? NSOrderedDescending : NSOrderedAscending;
        }];
        
        if(ids.count == 0 && _messagesViewController.state == MessagesViewControllerStateNone && _messageCaller) {
            [ids addObject:_messageCaller];
        }
        
        
        [_tableView.selectedItems enumerateObjectsUsingBlock:^(SelectUserItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TL_conversation *conversation = [obj.object dialog];
            
            [_messagesViewController forwardMessages:ids conversation:conversation callback:nil];
            
        }];
    } else {
        [_tableView.selectedItems enumerateObjectsUsingBlock:^(SelectUserItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TL_conversation *conversation = [obj.object dialog];
            
            [_messagesViewController shareContact:_user forConversation:conversation callback:nil];
            
        }];
    }
    
    
    
    
    
    [self close:YES];
    
}

-(void)selectTableDidChangedItem:(id)item {
    
    
    
    
    [self.ok setTitle:_tableView.selectedItems.count == 0 && self.isShareModalType ? NSLocalizedString(@"Conversation.Action.CopyShareLink", nil) : NSLocalizedString(@"Conversation.Action.Share", nil) forControlState:BTRControlStateNormal];
    
    [self updateCounterOrigin];
    
    
    [self.ok setEnabled:_tableView.selectedItems.count > 0 || self.isShareModalType];
    [self.ok setTitleColor:_tableView.selectedItems.count > 0 || self.isShareModalType ? LINK_COLOR : GRAY_TEXT_COLOR forControlState:BTRControlStateNormal];

  
    [[_counter animator] setAlphaValue:_tableView.selectedItems.count == 0 ? 0.0f : 1.0f];
    
    
    _counter.backgroundColor = _tableView.selectedItems.count > 0 ? NSColorFromRGB(0x5098d3) : DIALOG_BORDER_COLOR;
    
    //_counter.animated = !isHidden || _tableView.selectedItems.count > 1;
    [_counter setStringValue:[NSString stringWithFormat:@"%ld",MAX(1,_tableView.selectedItems.count)]];
}

@end
