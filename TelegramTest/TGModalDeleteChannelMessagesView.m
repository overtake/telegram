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



@end

@implementation TGModalDeleteChannelMessagesView

@synthesize ok = _ok;
@synthesize cancel = _cancel;

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
         [self setContainerFrameSize:NSMakeSize(280, 260)];
        
        

        [self enableCancelAndOkButton];
        
        _tableView = [[TGSettingsTableView alloc] initWithFrame:NSMakeRect(0, 50, self.containerSize.width, self.containerSize.height - 49)];
        
        [self addSubview:_tableView.containerView];
    }
    
    return self;
}


-(void)okAction {
     [self.action.behavior composeDidDone];
}

-(void)cancelAction {
    [self.action.behavior composeDidCancel];
    
    self.action = nil;
    [self close:YES];
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
    
    weak();
    
    [super show:[[NSApp delegate] mainWindow] animated:YES];
    
    
    GeneralSettingsBlockHeaderItem *header = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.DeleteMessagesModalHeader", nil) height:42 flipped:NO];
    
    
    header.xOffset = 30;
    
    [header setAligment:NSCenterTextAlignment];
    [header setTextColor:TEXT_COLOR];
    [header setFont:TGSystemFont(15)];
    
    [_tableView addItem:header tableRedraw:NO];
    
    GeneralSettingsRowItem *deleteItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {} description:NSLocalizedString(@"Channel.DeleteMessageModal", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return weakSelf.action.result.multiObjects[0];
    }];
    
    GeneralSettingsRowItem *banUser = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        BOOL currentValue = [weakSelf.action.result.multiObjects[1] boolValue];
        
        weakSelf.action.result = [[ComposeResult alloc] initWithMultiObjects:@[@(YES),@(!currentValue),weakSelf.action.result.multiObjects[2],weakSelf.action.result.multiObjects[3]]];
        
        [weakSelf.tableView reloadData];
        
    } description:NSLocalizedString(@"Channel.BanUserModal", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return weakSelf.action.result.multiObjects[1];
    }];
    
    GeneralSettingsRowItem *reportSpam = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        BOOL currentValue = [weakSelf.action.result.multiObjects[2] boolValue];
        
        weakSelf.action.result = [[ComposeResult alloc] initWithMultiObjects:@[@(YES),weakSelf.action.result.multiObjects[1],@(!currentValue),weakSelf.action.result.multiObjects[3]]];
        
        [weakSelf.tableView reloadData];
        
    } description:NSLocalizedString(@"Channel.ReportSpamModal", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return weakSelf.action.result.multiObjects[2];
    }];
    
    GeneralSettingsRowItem *deleteAllMesages = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        BOOL currentValue = [weakSelf.action.result.multiObjects[3] boolValue];
        
        weakSelf.action.result = [[ComposeResult alloc] initWithMultiObjects:@[@(YES),weakSelf.action.result.multiObjects[1],weakSelf.action.result.multiObjects[2],@(!currentValue)]];
        
        [weakSelf.tableView reloadData];
        
    } description:NSLocalizedString(@"Channel.DeleteAllMessagesModal", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return weakSelf.action.result.multiObjects[3];
    }];
    
    deleteAllMesages.drawsSeparator = NO;
    
    deleteItem.xOffset = banUser.xOffset = reportSpam.xOffset = deleteAllMesages.xOffset = 30;
    
    
    [_tableView addItem:deleteItem tableRedraw:NO];
    [_tableView addItem:banUser tableRedraw:NO];
    [_tableView addItem:reportSpam tableRedraw:NO];
    [_tableView addItem:deleteAllMesages tableRedraw:NO];
    
    [_tableView reloadData];
    
}

-(void)dealloc {
    [_tableView clear];
}

@end
