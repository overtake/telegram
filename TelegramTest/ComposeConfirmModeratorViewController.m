//
//  ComposeConfirmModeratorViewController.m
//  Telegram
//
//  Created by keepcoder on 16.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeConfirmModeratorViewController.h"
#import "TGSettingsTableView.h"
#import "TGUserContainerRowItem.h"
#import "SelectUserItem.h"

@interface ComposeConfirmModeratorViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,strong) TGUserContainerRowItem *userContainer;

@property (nonatomic,strong) TLChannelParticipantRole *participantRole;
@end

@implementation ComposeConfirmModeratorViewController

-(void)loadView {
    [super loadView];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    [self setCenterBarViewText:NSLocalizedString(@"Channel.Moderator", nil)];
    
    
}


-(void)setAction:(ComposeAction *)action {
    
    [super setAction:action];
    
    
    _participantRole = [self.action.object isBroadcast] ? [TL_channelRoleEditor create] : [TL_channelRoleModerator create];
    
    _userContainer = [[TGUserContainerRowItem alloc] initWithUser:action.result.multiObjects[0]];
    _userContainer.type = SettingsRowItemTypeNone;
    _userContainer.height = 60;
    
    [_tableView removeAllItems:NO];
    
    [_tableView addItem:_userContainer tableRedraw:NO];
    
    GeneralSettingsRowItem *moderatorItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        self.participantRole = [TL_channelRoleModerator create];
        [_tableView reloadData];
        
    } description:NSLocalizedString(@"Channel.Comments.Moderator", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @([self.participantRole isKindOfClass:[TL_channelRoleModerator class]]);
    }];
    
   
    GeneralSettingsRowItem *editorItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        self.participantRole = [TL_channelRoleEditor create];
        [_tableView reloadData];
        
    } description:NSLocalizedString(@"Channel.Comments.Editor", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @(![self.participantRole isKindOfClass:[TL_channelRoleModerator class]]);
    }];
    
     moderatorItem.xOffset = 30;
     editorItem.xOffset = 30;
    
    
    
    
    GeneralSettingsBlockHeaderItem *accessHeader = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.AccessHeader", nil) height:42 flipped:NO];
    
    accessHeader.xOffset = 30;
    
    GeneralSettingsBlockHeaderItem *accessDescription = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Channel.AccessDescription", nil) height:42 flipped:YES];
    
    accessDescription.xOffset = 30;
    accessDescription.autoHeight = YES;
    
    
    [_tableView addItem:accessHeader tableRedraw:NO];
    
    
    if(![self.action.object isBroadcast])
        [_tableView addItem:moderatorItem tableRedraw:NO];
    [_tableView addItem:editorItem tableRedraw:NO];
    
    [_tableView addItem:accessDescription tableRedraw:NO];
    
    
    if([self.action.reservedObject1 boolValue]) {
       
        GeneralSettingsRowItem *dismissModerator = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
            
            confirm(appName(), NSLocalizedString(@"Channel.DismissModeratorConfirm", nil), ^{
                self.participantRole = [TL_channelRoleEmpty create];
                
                [self.action.behavior composeDidDone];
                
            }, nil);
            
            
        } description:NSLocalizedString(@"Channel.DismissModerator", nil) height:82 stateback:^id(TGGeneralRowItem *item) {
            return nil;
        }];
        
        dismissModerator.textColor = [NSColor redColor];
        
        dismissModerator.xOffset = 30;
        
        [_tableView addItem:dismissModerator tableRedraw:NO];
        
    }
    
    [_tableView reloadData];
}

-(void)setParticipantRole:(TLChannelParticipantRole *)participantRole  {
    _participantRole = participantRole;
    
    self.action.result.singleObject = participantRole;
}


@end
