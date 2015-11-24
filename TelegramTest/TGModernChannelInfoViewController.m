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
#import "TGReportChannelModalView.h"
@interface TGModernChannelInfoViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;

@property (nonatomic,strong) TLChat *chat;
@property (nonatomic,strong) TL_conversation *conversation;


@property (nonatomic,strong) TGProfileHeaderRowItem *headerItem;
@property (nonatomic,strong) TGSProfileMediaRowItem *mediaItem;
@property (nonatomic,strong) GeneralSettingsRowItem *notificationItem;
@property (nonatomic,strong) GeneralSettingsBlockHeaderItem *participantsHeaderItem;



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
    
    [self drawParticipants:_chat.chatFull.participants.participants];
    
}

-(void)didUpdatedEditableState {
    
    if(!self.action.isEditable && ![self.headerItem.firstChangedValue isEqualToString:_chat.title] && self.headerItem.firstChangedValue.length > 0) {
        
        NSString *prev = _chat.title;
        
        _chat.title = self.headerItem.firstChangedValue;
        
        [Notification perform:CHAT_UPDATE_TITLE data:@{KEY_CHAT:_chat}];
        
        
        [RPCRequest sendRequest:[TLAPI_channels_editTitle createWithChannel:_chat.inputPeer title:self.headerItem.firstChangedValue] successHandler:^(RPCRequest *request, id response) {
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            _chat.title = prev;
            
            [Notification perform:CHAT_UPDATE_TITLE data:@{KEY_CHAT:_chat.title}];
        }];
    }
    
    
     [_tableView.list enumerateObjectsUsingBlock:^(TMRowItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:[TMRowItem class]]) {
            [obj setEditable:self.action.isEditable];
        }
        
    }];
    
    [self configure];
    
    [self drawParticipants:_chat.chatFull.participants.participants];
     
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [Notification removeObserver:self];
}

-(void)setChat:(TLChat *)chat {
    
    _chat = chat;
    _conversation = chat.dialog;
    
    if(_chat.isMegagroup) {
        _chat.chatFull.participants = [TL_chatParticipants createWithChat_id:_chat.n_id participants:[NSMutableArray array] version:0];
    }
    
    _composeActionManagment = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBehavior class] filter:@[] object:chat];;
    
    [self setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionInfoProfileBehavior class] filter:nil object:_conversation]];
    
    _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
}



-(void)loadNextParticipants {
    
    [self removeScrollEvent];
    
    int offset = (int) _chat.chatFull.participants.participants.count;
    
    [RPCRequest sendRequest:[TLAPI_channels_getParticipants createWithChannel:_chat.inputPeer filter:[TL_channelParticipantsRecent create] offset:offset limit:30] successHandler:^(id request, TL_channels_channelParticipants *response) {
        
        [SharedManager proccessGlobalResponse:response];
        
        
        [_chat.chatFull.participants.participants addObjectsFromArray:response.participants];
        
        [self drawParticipants:response.participants];
        
        
        if(response.participants.count > 0)
            [self addScrollEvent];
         else
            [self removeScrollEvent];

        
    } errorHandler:^(id request, RpcError *error) {
        
        
    }];

}

-(void)drawParticipants:(NSArray *)participants {
    
    NSMutableArray *items = [NSMutableArray array];
    
    [participants enumerateObjectsUsingBlock:^(TLChatParticipant *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TGUserContainerRowItem *user = [[TGUserContainerRowItem alloc] initWithUser:[[UsersManager sharedManager] find:obj.user_id]];
        user.height = 50;
        user.type = SettingsRowItemTypeNone;
        user.editable = self.action.isEditable;
        
        
        [user setStateback:^id(TGGeneralRowItem *item) {
            
            BOOL canRemoveUser = ((obj.user_id != [UsersManager currentUserId] && (self.chat.isCreator || self.chat.isManager)) && ![obj isKindOfClass:[TL_channelParticipantCreator class]]);
            
            return @(canRemoveUser);
            
        }];
        
        __weak TGUserContainerRowItem *weakItem = user;
        
        [user setStateCallback:^{
            
            if(self.action.isEditable) {
                if([weakItem.stateback(weakItem) boolValue])
                    [self kickParticipant:weakItem];
            } else {
                TGModernUserViewController *viewController = [[TGModernUserViewController alloc] initWithFrame:NSZeroRect];
                
                [viewController setUser:weakItem.user conversation:weakItem.user.dialog];
                
                [self.navigationViewController pushViewController:viewController animated:YES];
            }
            
        }];
        
        [items addObject:user];
    }];
    
    
    [_tableView insert:items startIndex:_tableView.list.count tableRedraw:YES];
}


- (void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
    
    if([self.tableView.scrollView isNeedUpdateBottom] ) {
        
        [self loadNextParticipants];
        
    }
    
}

- (void) addScrollEvent {
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

- (void) removeScrollEvent {
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:clipView];
}


-(void)kickParticipant:(TGUserContainerRowItem *)participant {
    
    
    NSUInteger idx = [_tableView indexOfItem:participant];
    
    _chat.chatFull.participants_count--;
    [_participantsHeaderItem redrawRow];
    
    if(idx != NSNotFound) {
        [_tableView removeItem:participant tableRedraw:YES];
        
        [RPCRequest sendRequest:[TLAPI_channels_kickFromChannel createWithChannel:self.chat.inputPeer user_id:participant.user.inputUser kicked:YES] successHandler:^(id request, id response) {
            
        } errorHandler:^(id request, RpcError *error) {
            
            [_tableView insert:participant atIndex:idx tableRedraw:YES];
            
        }];
    }
    
    

}

-(void)configure {
    
    [self.doneButton setHidden:!_chat.isManager && !_chat.isCreator];
    
    [_tableView removeAllItems:YES];
 
    _headerItem = [[TGProfileHeaderRowItem alloc] initWithObject:_conversation];
    
    _headerItem.height = 142;
    
    
    
    [_headerItem setEditable:self.action.isEditable];
    
    [_tableView addItem:_headerItem tableRedraw:YES];
    
    
    if(!self.action.isEditable) {
        GeneralSettingsRowItem *adminsItem;
        GeneralSettingsRowItem *membersItem;
        GeneralSettingsRowItem *blacklistItem;
        GeneralSettingsRowItem *addMembersItem;
        GeneralSettingsRowItem *inviteViaLink;
        if(_chat.username.length > 0) {
            TGProfileParamItem *linkItem = [[TGProfileParamItem alloc] initWithHeight:30];
            
            [linkItem setHeader:NSLocalizedString(@"Profile.ShareLink", nil) withValue:_chat.usernameLink];
            
            [_tableView addItem:linkItem tableRedraw:YES];
            
            [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        }
        
        
        if(_chat.chatFull.about.length > 0) {
            TGProfileParamItem *aboutItem = [[TGProfileParamItem alloc] initWithHeight:30];
            
            [aboutItem setHeader:[NSLocalizedString(@"Compose.ChannelAboutPlaceholder", nil) lowercaseString] withValue:_chat.chatFull.about];
            
            [_tableView addItem:aboutItem tableRedraw:YES];
            
            [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        }
        
        
        if(_chat.isManager || _chat.isCreator) {
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
            
            
            addMembersItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
                
                NSMutableArray *filter = [[NSMutableArray alloc] init];
                
                [_chat.chatFull.participants.participants enumerateObjectsUsingBlock:^(TLChatParticipant *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    [filter addObject:@(obj.user_id)];
                    
                    ComposePickerViewController *viewController = [[ComposePickerViewController alloc] initWithFrame:NSZeroRect];
                    
                    [viewController setAction:[[ComposeAction alloc]initWithBehaviorClass:[ComposeActionAddGroupMembersBehavior class] filter:filter object:_chat.chatFull reservedObjects:@[_chat]]];
                    
                    [self.navigationViewController pushViewController:viewController animated:YES];
                    
                }];
                
            } description:NSLocalizedString(@"Group.AddMembers", nil) height:42 stateback:nil];
            
            
            inviteViaLink = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
                
                ChatExportLinkViewController *export = [[ChatExportLinkViewController alloc] initWithFrame:NSZeroRect];
                
                [export setChat:_chat.chatFull];
                
                [self.navigationViewController pushViewController:export animated:YES];
                
                
            } description:NSLocalizedString(@"Modern.Channel.InviteViaLink", nil) height:42 stateback:nil];
            
            if(_chat.chatFull.kicked_count > 0) {
                blacklistItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
                    
                    ComposeChannelParticipantsViewController *viewController = [[ComposeChannelParticipantsViewController alloc] initWithFrame:NSZeroRect];
                    
                    [viewController setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBlackListBehavior class] filter:@[] object:_chat reservedObjects:@[[TL_channelParticipantsKicked create]]]];
                    
                    [self.navigationViewController pushViewController:viewController animated:YES];
                    
                } description:NSLocalizedString(@"Settings.BlackList", nil) subdesc:[NSString stringWithFormat:@"%d",_chat.chatFull.kicked_count] height:42 stateback:nil];
            }
            
        } else {
            
            if(!_chat.isMegagroup) {
                GeneralSettingsRowItem *openChannel = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
                    
                    [self.navigationViewController showMessagesViewController:_conversation];
                    
                } description:NSLocalizedString(@"Profile.OpenChannel", nil) height:42 stateback:nil];
                
                openChannel.textColor = BLUE_UI_COLOR;
                
                [_tableView addItem:openChannel tableRedraw:YES];
                
                [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
            }
            
        }
        
        if(adminsItem)
            [_tableView addItem:adminsItem tableRedraw:YES];
        
        if(_chat.isMegagroup) {
            if(addMembersItem)
                [_tableView addItem:addMembersItem tableRedraw:YES];
            if(_chat.isCreator)
                [_tableView addItem:inviteViaLink tableRedraw:YES];
        } else {
            if(membersItem)
                [_tableView addItem:membersItem tableRedraw:YES];
        }
        
        
        
        if(blacklistItem)
            [_tableView addItem:blacklistItem tableRedraw:YES];
        
        if(adminsItem || membersItem || blacklistItem) {
            [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        }
        
        
        _mediaItem = [[TGSProfileMediaRowItem alloc] initWithObject:_conversation];
        
        _mediaItem.controller = self;
        
        weak();
        [_mediaItem setCallback:^(TGGeneralRowItem *item) {
            
            TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:NSZeroRect];
            
            [viewController setConversation:weakSelf.conversation];
            
            [weakSelf.navigationViewController pushViewController:viewController animated:YES];
            
        }];
        
        _mediaItem.height = 50;
        
        [_tableView addItem:_mediaItem tableRedraw:YES];
        
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        _notificationItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
            
            [_conversation muteOrUnmute:nil until:0];
            
        } description:NSLocalizedString(@"Notifications", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
            return @(!_conversation.isMute);
        }];
        
        
        [_tableView addItem:_notificationItem tableRedraw:YES];
    } else {
        
        GeneralSettingsRowItem *descriptionItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
            
            ComposeChangeChannelDescriptionViewController *viewController = [[ComposeChangeChannelDescriptionViewController alloc] init];
            
            [viewController setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionChangeChannelAboutBehavior class] filter:nil object:_chat reservedObjects:@[NSLocalizedString(@"Compose.ChannelAboutPlaceholder", nil),(_chat.isMegagroup ? NSLocalizedString(@"Compose.ChatAboutDescription", nil) : NSLocalizedString(@"Compose.ChannelAboutDescription", nil))]]];
            
            [self.navigationViewController pushViewController:viewController animated:YES];
            
        } description:NSLocalizedString(@"Compose.ChannelAboutPlaceholder", nil) subdesc:[_chat.chatFull.about stringByReplacingOccurrencesOfString:@"\n" withString:@" "] height:42 stateback:nil];
        
        [_tableView addItem:descriptionItem tableRedraw:YES];
        
        
        if(!_chat.isMegagroup) {
            GeneralSettingsRowItem *linkItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
                
                ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBehavior class]];
                action.result = [[ComposeResult alloc] init];
                action.result.singleObject = _chat;
                ComposeCreateChannelUserNameStepViewController *viewController = [[ComposeCreateChannelUserNameStepViewController alloc] initWithFrame:NSZeroRect];
                
                [viewController setAction:action];
                
                [self.navigationViewController pushViewController:viewController animated:YES];
                
            } description:NSLocalizedString(@"Profile.EditLink", nil) subdesc:_chat.usernameLink height:42 stateback:nil];
            
            [_tableView addItem:linkItem tableRedraw:YES];
            
        }
        
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
       
        
        if(_chat.isCreator) {
            GeneralSettingsRowItem *deleteChannelItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
                
                [self.navigationViewController.messagesViewController deleteDialog:_conversation];
                
                
            } description:_chat.isMegagroup ? NSLocalizedString(@"Conversation.Confirm.DeleteGroup", nil) : NSLocalizedString(@"Profile.DeleteChannel", nil) height:42 stateback:nil];
            
            deleteChannelItem.textColor = [NSColor redColor];
            
            [_tableView addItem:deleteChannelItem tableRedraw:YES];
        }
        
    }
    
    if(!_chat.isCreator && !_chat.isMegagroup) {
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        
        GeneralSettingsRowItem *reportItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            TGReportChannelModalView *reportModalView = [[TGReportChannelModalView alloc] initWithFrame:[self.view.window.contentView bounds]];
            
            reportModalView.conversation = _conversation;
            
            [reportModalView show:self.view.window animated:YES];
            
            
        } description:NSLocalizedString(@"Profile.ReportChannel", nil) height:42 stateback:nil];
        
        reportItem.textColor = BLUE_UI_COLOR;
        
        [_tableView addItem:reportItem tableRedraw:YES];
        
        
        if(!_conversation.invisibleChannel) {
            GeneralSettingsRowItem *deleteChannelItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
                
                [self.navigationViewController.messagesViewController deleteDialog:_conversation];
                
                
            } description:_chat.isMegagroup ? NSLocalizedString(@"Conversation.Actions.LeaveGroup", nil) : NSLocalizedString(@"Profile.LeaveChannel", nil) height:42 stateback:nil];
            
            deleteChannelItem.textColor = [NSColor redColor];
            
            [_tableView addItem:deleteChannelItem tableRedraw:YES];
        }
        

    }
    
    if(_chat.isMegagroup) {
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        
        _participantsHeaderItem = [[GeneralSettingsBlockHeaderItem alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Modern.Chat.Members", nil),_chat.chatFull.participants_count] height:42 flipped:NO];
        
        [_tableView addItem:_participantsHeaderItem tableRedraw:YES];
        
        [self loadNextParticipants];
    }
    
    
    
}

@end
