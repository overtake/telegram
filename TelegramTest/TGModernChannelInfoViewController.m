//
//  TGModernChannelInfoViewController.m
//  Telegram
//
//  Created by keepcoder on 04/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGModernChannelInfoViewController.h"
#import "TGSettingsTableView.h"
#import "TGProfileHeaderRowItem.h"
#import "TGSProfileMediaRowItem.h"
#import "TGProfileParamItem.h"
#import "ComposeActionInfoProfileBehavior.h"
#import "MessagesUtils.h"
#import "TGUserContainerRowItem.h"
#import "TGUserContainerView.h"
#import "TGProfileHeaderRowView.h"
#import "TGModernUserViewController.h"
#import "ComposeActionAddGroupMembersBehavior.h"
#import "TGPhotoViewer.h"
#import "ChatAdminsViewController.h"
#import "ComposeActionBlackListBehavior.h"
#import "ComposeActionChannelMembersBehavior.h"
#import "ComposeChangeChannelDescriptionViewController.h"
#import "ComposeActionChangeChannelAboutBehavior.h"
@interface TGModernChannelInfoViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;

@property (nonatomic,strong) TLChat *chat;
@property (nonatomic,strong) TL_conversation *conversation;


@property (nonatomic,strong) TGProfileHeaderRowItem *headerItem;
@property (nonatomic,strong) TGSProfileMediaRowItem *mediaItem;
@property (nonatomic,strong) GeneralSettingsRowItem *notificationItem;



@property (nonatomic,strong) ComposeAction *composeActionManagment;
@end

@implementation TGModernChannelInfoViewController


-(void)loadView {
    [super loadView];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.action.editable = NO;
    
    [self updateActionNavigation];
    
    [self configure];
    
}

-(void)didUpdatedEditableState {
    [self configure];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [Notification removeObserver:self];
}

-(void)setChat:(TLChat *)chat {
    
    _chat = chat;
    _conversation = chat.dialog;
    
    _composeActionManagment = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBehavior class] filter:@[] object:chat];;
    
    [self setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionInfoProfileBehavior class] filter:nil object:_conversation]];
    
    _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
}


/*
 [self.exportChatInvite setHidden:YES];
 [self.sharedMediaButton setHidden:self.type == ChatInfoViewControllerEdit];
 [self.filesMediaButton setHidden:self.type == ChatInfoViewControllerEdit];
 [self.sharedLinksButton setHidden:self.type == ChatInfoViewControllerEdit];
 
 [self.admins setHidden:YES];
 
 
 [self.linkView setHidden:self.type == ChatInfoViewControllerEdit || self.linkView.string.length == 0];
 [self.aboutView setHidden:self.type == ChatInfoViewControllerEdit || self.aboutView.string.length == 0];
 
 
 [self.exportChatInvite setHidden:self.type != ChatInfoViewControllerEdit || self.controller.chat.username.length > 0];
 
 [self.editAboutContainer setHidden:self.type != ChatInfoViewControllerEdit];
 
 [self.linkEditButton setHidden:self.type != ChatInfoViewControllerEdit || self.controller.chat.isMegagroup];
 [self.setGroupPhotoButton setHidden:self.type != ChatInfoViewControllerEdit];
 
 
 [self.openOrJoinChannelButton setHidden:self.controller.chat.isManager || self.controller.chat.isMegagroup];
 
 
 [self.managmentButton setHidden:!self.controller.chat.isManager];
 
 [self.membersButton setHidden:!self.controller.chat.isManager];
 [self.blackListButton setHidden:self.type != ChatInfoViewControllerEdit || !self.controller.chat.isManager || self.controller.chat.isBroadcast];
 
 
 [self.enableCommentsButton setHidden:YES];
 
 [self.addMembersButton setHidden:self.type == ChatInfoViewControllerEdit || !self.controller.chat.isAdmin || self.controller.fullChat.participants_count >= 200];
 */

-(void)configure {
    
    [self.doneButton setHidden:!_chat.isManager || !_chat.isAdmin];
    
    [_tableView removeAllItems:YES];
    
    _headerItem = [[TGProfileHeaderRowItem alloc] initWithObject:_conversation];
    
    _headerItem.height = 142;
    
    [_headerItem setEditable:self.action.isEditable];
    
    [_tableView addItem:_headerItem tableRedraw:YES];
    
    
    if(!self.action.isEditable) {
        GeneralSettingsRowItem *adminsItem;
        GeneralSettingsRowItem *membersItem;
        GeneralSettingsRowItem *blacklistItem;
        
        
        if(_chat.username.length > 0) {
            TGProfileParamItem *linkItem = [[TGProfileParamItem alloc] initWithHeight:30];
            
            [linkItem setHeader:NSLocalizedString(@"Profile.ShareLink", nil) withValue:_chat.usernameLink];
            
            [_tableView addItem:linkItem tableRedraw:YES];
            
            [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        }
        
        
        if(_chat.chatFull.about.length > 0) {
            TGProfileParamItem *aboutItem = [[TGProfileParamItem alloc] initWithHeight:30];
            
            [aboutItem setHeader:NSLocalizedString(@"Profile.About", nil) withValue:_chat.chatFull.about];
            
            [_tableView addItem:aboutItem tableRedraw:YES];
            
            [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        }
        
        
        if(_chat.isManager || _chat.isAdmin) {
            adminsItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
                
                ComposeManagmentViewController *viewController = [[ComposeManagmentViewController alloc] initWithFrame:NSZeroRect];
                
                [viewController setAction:_composeActionManagment];
                
                [self.navigationViewController pushViewController:viewController animated:YES];
                
            } description:NSLocalizedString(@"Channel.Managment", nil) subdesc:[NSString stringWithFormat:@"%d",_chat.chatFull.admins_count] height:42 stateback:nil];
            
            membersItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
                
                ComposeChannelParticipantsViewController *viewController = [[ComposeChannelParticipantsViewController alloc] initWithFrame:NSZeroRect];
                
                [viewController setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionChannelMembersBehavior class] filter:@[] object:_chat reservedObjects:@[[TL_channelParticipantsRecent create]]]];
                
                [self.navigationViewController pushViewController:viewController animated:YES];
                
                
            } description:NSLocalizedString(@"Channel.Members", nil) subdesc:[NSString stringWithFormat:@"%d",_chat.chatFull.participants_count] height:42 stateback:nil];
            
            if(_chat.chatFull.kicked_count > 0) {
                blacklistItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
                    
                    ComposeChannelParticipantsViewController *viewController = [[ComposeChannelParticipantsViewController alloc] initWithFrame:NSZeroRect];
                    
                    [viewController setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBlackListBehavior class] filter:@[] object:_chat reservedObjects:@[[TL_channelParticipantsKicked create]]]];
                    
                    [self.navigationViewController pushViewController:viewController animated:YES];
                    
                } description:NSLocalizedString(@"Profile.ChannelBlackList", nil) subdesc:[NSString stringWithFormat:@"%d",_chat.chatFull.kicked_count] height:42 stateback:nil];
            }
            
        }
        
        if(adminsItem)
            [_tableView addItem:adminsItem tableRedraw:YES];
        if(membersItem)
            [_tableView addItem:membersItem tableRedraw:YES];
        if(blacklistItem)
            [_tableView addItem:blacklistItem tableRedraw:YES];
        
        if(adminsItem || membersItem || blacklistItem) {
            [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        }
        
        
        _mediaItem = [[TGSProfileMediaRowItem alloc] initWithObject:_conversation];
        
        weak();
        [_mediaItem setCallback:^(TGGeneralRowItem *item) {
            
            TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:NSZeroRect];
            
            [viewController setConversation:weakSelf.conversation];
            
            [weakSelf.navigationViewController pushViewController:viewController animated:YES];
            
        }];
        
        _mediaItem.height = 50;
        
        [_tableView addItem:_mediaItem tableRedraw:YES];
        
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        _notificationItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeChoice callback:^(TGGeneralRowItem *item) {
            
        } description:NSLocalizedString(@"Notifications", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
            return [MessagesUtils muteUntil:_conversation.notify_settings.mute_until];
        }];
        
        _notificationItem.menu = [MessagesViewController notifications:^{
            
            [self configure];
            
        } conversation:_conversation click:nil];
        
        
        [_tableView addItem:_notificationItem tableRedraw:YES];
    } else {
        
        GeneralSettingsRowItem *descriptionItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
            
            ComposeChangeChannelDescriptionViewController *viewController = [[ComposeChangeChannelDescriptionViewController alloc] init];
            
            [viewController setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionChangeChannelAboutBehavior class] filter:nil object:_chat]];
            
            [self.navigationViewController pushViewController:viewController animated:YES];
            
        } description:NSLocalizedString(@"Compose.ChannelAboutPlaceholder", nil) subdesc:_chat.chatFull.about height:42 stateback:nil];
        
        [_tableView addItem:descriptionItem tableRedraw:YES];
        
        GeneralSettingsRowItem *linkItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
            
            ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBehavior class]];
            action.result = [[ComposeResult alloc] init];
            action.result.singleObject = _chat;
            ComposeCreateChannelUserNameStepViewController *viewController = [[ComposeCreateChannelUserNameStepViewController alloc] initWithFrame:NSZeroRect];
            
            [viewController setAction:action];
            
            [self.navigationViewController pushViewController:viewController animated:YES];
            
        } description:NSLocalizedString(@"Profile.EditLink", nil) subdesc:_chat.usernameLink height:42 stateback:nil];
        
        [_tableView addItem:linkItem tableRedraw:YES];
        
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        if(_chat.isAdmin) {
            GeneralSettingsRowItem *deleteChannelItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
                
                [self.navigationViewController.messagesViewController deleteDialog:_conversation];
                
                
            } description:NSLocalizedString(@"Profile.DeleteChannel", nil) height:42 stateback:nil];
            
            deleteChannelItem.textColor = [NSColor redColor];
            
            [_tableView addItem:deleteChannelItem tableRedraw:YES];
        }
        
    }
    
    if(!_chat.isManager && !_chat.isAdmin) {
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        GeneralSettingsRowItem *deleteChannelItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            [self.navigationViewController.messagesViewController deleteDialog:_conversation];
            
            
        } description:NSLocalizedString(@"Profile.LeaveChannel", nil) height:42 stateback:nil];
        
        deleteChannelItem.textColor = [NSColor redColor];
        
        [_tableView addItem:deleteChannelItem tableRedraw:YES];

    }
    
    
}

@end
