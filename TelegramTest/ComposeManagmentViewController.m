//
//  ComposeManagmentViewController.m
//  Telegram
//
//  Created by keepcoder on 17.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeManagmentViewController.h"

#include "TGSettingsTableView.h"
#import "TGUserContainerRowItem.h"
#import "ComposeActionAddChannelModeratorBehavior.h"
#import "SelectUserItem.h"
#import "ComposeActionAddChannelModeratorBehavior.h"
@interface ComposeManagmentViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@end

@implementation ComposeManagmentViewController


-(void)loadView {
    [super loadView];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView.containerView];
    
    
}

-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
    
    
    
    [self setLoading:YES];
    
    [RPCRequest sendRequest:[TLAPI_channels_getParticipants createWithChannel:[self.action.object inputPeer] filter:[TL_channelParticipantsAdmins create] offset:0 limit:100] successHandler:^(id request, TL_channels_channelParticipants *response) {
        
        [SharedManager proccessGlobalResponse:response];
        
        action.result = [[ComposeResult alloc] initWithMultiObjects:response.participants];
        
        [self reload];
        
        [self setLoading:NO];
        
    } errorHandler:^(id request, RpcError *error) {
        
    }];
    
   
}


-(void)reload {
    
    [self.tableView removeAllItems:NO];
    
    TLChat *chat = self.action.object;
    
    weak();
    
    if(chat.isCreator) {
        
        
        if(chat.isMegagroup) {
            GeneralSettingsBlockHeaderItem *changePrivacyDescription = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"SuperGroup.WhocanAddNewMembers", nil) height:42 flipped:NO];
            [_tableView addItem:changePrivacyDescription tableRedraw:NO];
            
            void (^request)(BOOL enabled) = ^(BOOL enabled) {
              
                [weakSelf showModalProgress];
                
                [RPCRequest sendRequest:[TLAPI_channels_toggleInvites createWithChannel:chat.inputPeer enabled:enabled] successHandler:^(id request, id response) {
                    
                    [weakSelf hideModalProgressWithSuccess];
                    
                    [weakSelf.tableView reloadData];
                    
                } errorHandler:^(id request, RpcError *error) {
                    [weakSelf hideModalProgress];
                }];
                
            };
            
            GeneralSettingsRowItem *allMembers = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
                
                request(YES);
                
                
            } description:NSLocalizedString(@"SuperGroup.InviteSettings.AllMembers", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
                return @(chat.isDemocracy);
            }];
            
            GeneralSettingsRowItem *onlyAdmins = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
                
                request(NO);
                
            } description:NSLocalizedString(@"SuperGroup.InviteSettings.OnlyAdmins", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
                return @(!chat.isDemocracy);
            }];
            
            
            [_tableView addItem:allMembers tableRedraw:NO];
            [_tableView addItem:onlyAdmins tableRedraw:NO];
        }
        
        GeneralSettingsRowItem *addModerator = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
            
            ComposePickerViewController *viewController = [[ComposePickerViewController alloc] initWithFrame:weakSelf.view.bounds];
            
            [viewController setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionAddChannelModeratorBehavior class] filter:@[] object:chat]];
            
            [weakSelf.navigationViewController pushViewController:viewController animated:YES];
            
        } description:chat.isBroadcast ? NSLocalizedString(@"Channel.AddEditor", nil) : NSLocalizedString(@"Channel.AddModerator", nil) height:62 stateback:nil];
        
        [_tableView addItem:addModerator tableRedraw:NO];
        
        GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:chat.isMegagroup ? NSLocalizedString(@"Group.AddModeratorDescription", nil) : NSLocalizedString(@"Channel.AddModeratorDescription", nil) height:62 flipped:YES];
        
        
        [_tableView addItem:description tableRedraw:NO];

    } else {
        GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:@"" height:30 flipped:YES];
        
        [_tableView addItem:description tableRedraw:NO];
    }
    
    
    NSArray *sort = @[NSStringFromClass([TL_channelParticipantCreator class]),NSStringFromClass([TL_channelParticipantEditor class]),NSStringFromClass([TL_channelParticipantModerator class])];
    
    NSArray *admins = [self.action.result.multiObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [@([sort indexOfObject:[obj1 className]]) compare:@([sort indexOfObject:[obj2 className]])];
        
    }];
    
    
    [admins enumerateObjectsWithOptions:0 usingBlock:^(TL_channelParticipant *obj, NSUInteger idx, BOOL *stop) {
        
        TGUserContainerRowItem *item = [[TGUserContainerRowItem alloc] initWithUser:[[UsersManager sharedManager] find:obj.user_id]];
        item.type = SettingsRowItemTypeNone;
        item.height = 42;
        item.avatarHeight = 30;
        item.status = [obj isKindOfClass:[TL_channelParticipantCreator class]] ? NSLocalizedString(@"Channel.Creator", nil) : [obj isKindOfClass:[TL_channelParticipantModerator class]] ? NSLocalizedString(@"Channel.Moderator", nil) : [TL_channelParticipantEditor class] ? NSLocalizedString(@"Channel.Editor", nil) : @"";
        
        [_tableView addItem:item tableRedraw:NO];
        
        TLUser *user = item.user;
        
        __weak TGUserContainerRowItem *weakItem = item;
        
        item.stateCallback = ^{
            
            if(![obj isKindOfClass:[TL_channelParticipantCreator class]]) {
                if((chat.isBroadcast || chat.isMegagroup) && chat.isCreator) {
                    
                    confirm(NSLocalizedString(@"Channel.DismissModerator", nil), NSLocalizedString(@"Channel.DismissModeratorConfirm", nil), ^{
                        
                        
                        [RPCRequest sendRequest:[TLAPI_channels_editAdmin createWithChannel:chat.inputPeer user_id:user.inputUser role:[TL_channelRoleEmpty create]] successHandler:^(id request, id response) {
                            
                            
                            weakSelf.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
                            [weakSelf.tableView removeItem:weakItem tableRedraw:YES];
                            weakSelf.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
                            
                            chat.chatFull.participants = nil;
                            [[ChatFullManager sharedManager] loadParticipantsWithMegagroupId:chat.n_id];
                            
                        } errorHandler:^(id request, RpcError *error) {
                            
                        }];
                        
                        
                    }, ^{
                        
                    });
                    
                } else if(chat.isCreator) {
                    
                    ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionAddChannelModeratorBehavior class] filter:@[] object:chat reservedObjects:@[@(YES),obj]];
                    
                    action.result = [[ComposeResult alloc] initWithMultiObjects:@[user]];
                    
                    ComposeConfirmModeratorViewController *viewController = [[ComposeConfirmModeratorViewController alloc] initWithFrame:weakSelf.view.bounds];
                    
                    [viewController setAction:action];
                    
                    [weakSelf.navigationViewController pushViewController:viewController animated:YES];
                }

            }
            
           
            
        };
        
    }];
    
    
    
    [_tableView reloadData];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setCenterBarViewText:NSLocalizedString(@"Channel.Managment", nil)];
    
    [self.doneButton setStringValue:@""];
    
    self.action = self.action;
}

-(void)dealloc {
    [_tableView clear];
}

@end
