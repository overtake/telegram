//
//  TGModalDeleteChannelMessagesView.m
//  Telegram
//
//  Created by keepcoder on 17.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGModalDeleteChannelMessagesView.h"
#import "TGSettingsTableView.h"
@interface TGModalDeleteChannelMessagesView () <ComposeBehaviorDelegate>
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,strong) ComposeAction *action;

@property (nonatomic,strong) BTRButton *ok;
@property (nonatomic,strong) BTRButton *cancel;


@end

@implementation TGModalDeleteChannelMessagesView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
         [self setContainerFrameSize:NSMakeSize(280, 260)];
        
        
        weak();
        
        _ok = [[BTRButton alloc] initWithFrame:NSMakeRect(self.containerSize.width/2, 0, self.containerSize.width/2, 49)];
        
        _ok.layer.backgroundColor = [NSColor whiteColor].CGColor;
        
        [_ok setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
        
        [_ok setTitle:NSLocalizedString(@"OK", nil) forControlState:BTRControlStateNormal];
        
        [_ok addBlock:^(BTRControlEvents events) {
            
            [weakSelf.action.behavior composeDidDone];
            
        } forControlEvents:BTRControlEventMouseDownInside];
        
        
        [self addSubview:_ok];
        
        
        
        _cancel = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width/2, 50)];
        
        _cancel.layer.backgroundColor = [NSColor whiteColor].CGColor;
        
        [_cancel setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
        
        [_cancel setTitle:NSLocalizedString(@"Cancel", nil) forControlState:BTRControlStateNormal];
        
        [_cancel addBlock:^(BTRControlEvents events) {
            
            [weakSelf.action.behavior composeDidCancel];
            
            weakSelf.action = nil;
            [weakSelf close:YES];
            
            
        } forControlEvents:BTRControlEventMouseDownInside];
        
        [self addSubview:_cancel];
        
        
        TMView *separator = [[TMView alloc] initWithFrame:NSMakeRect(0, 49, self.containerSize.width, 1)];
        [separator setBackgroundColor:DIALOG_BORDER_COLOR];
        [self addSubview:separator];
        
        separator = [[TMView alloc] initWithFrame:NSMakeRect(self.containerSize.width/2, 0, 1, 50)];
        [separator setBackgroundColor:DIALOG_BORDER_COLOR];
        [self addSubview:separator];
        
        
        _tableView = [[TGSettingsTableView alloc] initWithFrame:NSMakeRect(0, 50, self.containerSize.width, self.containerSize.height - 49)];
        
        [self addSubview:_tableView.containerView];
    }
    
    return self;
}

-(void)behaviorDidEndRequest:(id)response {
    [TMViewController hideModalProgressWithSuccess];
}

-(void)behaviorDidStartRequest {
    [self close:NO];
    [TMViewController showModalProgress];
}


-(void)showWithAction:(ComposeAction *)action {
 
    _action = action;
    _action.behavior.delegate = self;
    
    assert(action.result.multiObjects.count == 4);
    
    [super show:[[NSApp delegate] mainWindow] animated:YES];
    
    
    GeneralSettingsBlockHeaderItem *header = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.DeleteMessagesModalHeader", nil) height:42 flipped:NO];
    
    
    header.xOffset = 30;
    
    [header setAligment:NSCenterTextAlignment];
    [header setTextColor:TEXT_COLOR];
    [header setFont:TGSystemFont(15)];
    
    [_tableView addItem:header tableRedraw:NO];
    
    GeneralSettingsRowItem *deleteItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {} description:NSLocalizedString(@"Channel.DeleteMessageModal", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return _action.result.multiObjects[0];
    }];
    
    GeneralSettingsRowItem *banUser = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        BOOL currentValue = [self.action.result.multiObjects[1] boolValue];
        
        _action.result = [[ComposeResult alloc] initWithMultiObjects:@[@(YES),@(!currentValue),_action.result.multiObjects[2],_action.result.multiObjects[3]]];
        
        [_tableView reloadData];
        
    } description:NSLocalizedString(@"Channel.BanUserModal", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return _action.result.multiObjects[1];
    }];
    
    GeneralSettingsRowItem *reportSpam = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        BOOL currentValue = [self.action.result.multiObjects[2] boolValue];
        
        _action.result = [[ComposeResult alloc] initWithMultiObjects:@[@(YES),_action.result.multiObjects[1],@(!currentValue),_action.result.multiObjects[3]]];
        
        [_tableView reloadData];
        
    } description:NSLocalizedString(@"Channel.ReportSpamModal", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return _action.result.multiObjects[2];
    }];
    
    GeneralSettingsRowItem *deleteAllMesages = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        BOOL currentValue = [self.action.result.multiObjects[3] boolValue];
        
        _action.result = [[ComposeResult alloc] initWithMultiObjects:@[@(YES),_action.result.multiObjects[1],_action.result.multiObjects[2],@(!currentValue)]];
        
        [_tableView reloadData];
        
    } description:NSLocalizedString(@"Channel.DeleteAllMessagesModal", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return _action.result.multiObjects[3];
    }];
    
    deleteAllMesages.drawsSeparator = NO;
    
    deleteItem.xOffset = banUser.xOffset = reportSpam.xOffset = deleteAllMesages.xOffset = 30;
    
    
    [_tableView addItem:deleteItem tableRedraw:NO];
    [_tableView addItem:banUser tableRedraw:NO];
    [_tableView addItem:reportSpam tableRedraw:NO];
 //   [_tableView addItem:deleteAllMesages tableRedraw:NO];
    
    [_tableView reloadData];
    
}

@end
