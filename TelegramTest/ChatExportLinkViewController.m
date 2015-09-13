//
//  ChatExportLinkViewController.m
//  Telegram
//
//  Created by keepcoder on 27.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChatExportLinkViewController.h"
#import "GeneralSettingsRowView.h"
#import "GeneralSettingsBlockHeaderView.h"
#import "GeneralSettingsDescriptionRowView.h"
@interface ChatExportLinkViewController ()<TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@end

@implementation ChatExportLinkViewController


-(void)loadView {
    [super loadView];
    
    
    _tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    _tableView.tm_delegate = self;
    
    [self.view addSubview:_tableView.containerView];

}


-(void)setChat:(TLChatFull *)chat {
    _chat = chat;
    
    if(!self.view)
        [self loadView];
    
    
    [self rebuild];
}


-(void)rebuild {
    
    [self.tableView removeAllItems:YES];
    
    
    GeneralSettingsRowItem *copyLink = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(GeneralSettingsRowItem *item) {
        
        if([_chat.exported_invite isKindOfClass:[TL_chatInviteExported class]]) {
            
            [TMViewController showModalProgress];
            
            NSPasteboard* cb = [NSPasteboard generalPasteboard];
            
            [cb declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:self];
            [cb setString:_chat.exported_invite.link forType:NSStringPboardType];
            
            dispatch_after_seconds(0.2, ^{
                
                [TMViewController hideModalProgressWithSuccess];

            });
            
            
        }

    } description:NSLocalizedString(@"ChatExportLink.CopyLink", nil) height:62 stateback:^id(GeneralSettingsRowItem *item) {
        return nil;
    }];
    
    [self.tableView insert:copyLink atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    GeneralSettingsRowItem *revokeLink = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(GeneralSettingsRowItem *item) {
        
        
        confirm(appName(), NSLocalizedString(@"ChatExportLink.RevokeConfirm", nil), ^{
            
            [TMViewController showModalProgress];
            
            [RPCRequest sendRequest:[TLAPI_messages_exportChatInvite createWithChat_id:[TL_inputChat createWithChat_id:_chat.n_id]] successHandler:^(RPCRequest *request, TL_chatInviteExported *response) {
                
                [TMViewController hideModalProgressWithSuccess];
                
                _chat.exported_invite = response;
                
                [[Storage manager] insertFullChat:_chat completeHandler:nil];
                
                alert(nil, NSLocalizedString(@"ChatExportLink.Alert.Revoked", nil));
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                [TMViewController hideModalProgress];
            } timeout:10];
        }, nil);
        
        
        
    } description:NSLocalizedString(@"ChatExportLink.RevokeLink", nil) height:42 stateback:^id(GeneralSettingsRowItem *item) {
        return nil;
    }];
    
    
    [self.tableView insert:revokeLink atIndex:self.tableView.list.count tableRedraw:NO];
    
    
    GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"ChatExportLink.Description", nil)] height:100 flipped:YES];
    
    [self.tableView insert:description atIndex:self.tableView.count tableRedraw:NO];
    
    
    
    [self.tableView reloadData];
    
}



- (CGFloat)rowHeight:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return  item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[GeneralSettingsBlockHeaderItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsBlockHeaderView class] identifier:@"GeneralSettingsBlockHeaderView"];
    }
    
    if([item isKindOfClass:[GeneralSettingsRowItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsRowView class] identifier:@"GeneralSettingsRowViewClass"];
    }
    
    return nil;
    
}

- (void)selectionDidChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

@end
