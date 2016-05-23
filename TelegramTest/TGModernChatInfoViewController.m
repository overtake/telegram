//
//  TGModernChatInfoViewController.m
//  Telegram
//
//  Created by keepcoder on 03/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGModernChatInfoViewController.h"
#import "TGSettingsTableView.h"
#import "TGProfileHeaderRowItem.h"
#import "TGSProfileMediaRowItem.h"
#import "TGProfileParamItem.h"
#import "ComposeActionInfoProfileBehavior.h"
#import "MessagesUtils.h"
#import "TGUserContainerRowItem.h"
#import "TGObjectContainerView.h"
#import "TGProfileHeaderRowView.h"
#import "TGModernUserViewController.h"
#import "ComposeActionAddGroupMembersBehavior.h"
#import "TGPhotoViewer.h"
#import "ChatAdminsViewController.h"
#import "TGModernUpgradeChatViewController.h"
#import "ComposeActionCustomBehavior.h"
@interface TGModernChatInfoViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;

@property (nonatomic,strong) TLChat *chat;
@property (nonatomic,strong) TL_conversation *conversation;


@property (nonatomic,strong) GeneralSettingsBlockHeaderItem *participantsHeaderItem;
@property (nonatomic,strong) GeneralSettingsRowItem *notificationItem;
@property (nonatomic,strong) GeneralSettingsRowItem *adminsItem;
@property (nonatomic,strong) GeneralSettingsRowItem *deleteAndExitItem;
@property (nonatomic,strong) GeneralSettingsRowItem *convertToSuperGroup;
@property (nonatomic,strong) TGProfileHeaderRowItem *headerItem;
@property (nonatomic,strong) TGSProfileMediaRowItem *mediaItem;

@end

@implementation TGModernChatInfoViewController


-(void)loadView {
    [super loadView];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    weak();
    
    [self.doneButton setTapBlock:^{
       
        [weakSelf changeEditable:!weakSelf.action.isEditable];
        
    }];
    
    
    _adminsItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
        
        ChatAdminsViewController *viewController = [[ChatAdminsViewController alloc] initWithFrame:NSZeroRect];
        
        viewController.chat = weakSelf.chat;
        
        [weakSelf.navigationViewController pushViewController:viewController animated:YES];
        
    } description:NSLocalizedString(@"Modern.Profile.SetAdmins", nil) height:42 stateback:nil];
    
    _notificationItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
        
        [weakSelf.conversation muteOrUnmute:nil until:0];
        
    } description:NSLocalizedString(@"Notifications", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @(!weakSelf.conversation.isMute);
    }];
    

    _deleteAndExitItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
        
        [weakSelf.messagesViewController deleteDialog:weakSelf.conversation callback:^{
            
        }];
        
    } description:NSLocalizedString(@"Conversation.DeleteAndExit", nil) height:42 stateback:nil];
    
    _convertToSuperGroup = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
        
        strongWeak();
        
        if(strongSelf == weakSelf) {
            TGModernUpgradeChatViewController *upgradeController = [[TGModernUpgradeChatViewController alloc] initWithFrame:NSZeroRect];
            
            
            ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionCustomBehavior class] filter:nil object:strongSelf.chat];
            
            ComposeActionCustomBehavior *behavior = (ComposeActionCustomBehavior *) action.behavior;
            
            behavior.customCenterTitle = NSLocalizedString(@"Conversation.ConvertToSuperGroup", nil);
            
            [behavior setComposeDone:^{
               
                strongWeak();
                
                if(strongSelf == weakSelf) {
                    [strongSelf upgradeToSuperGroup:YES];
                }
                
            }];
            
            [upgradeController setAction:action];
            [strongSelf.navigationViewController pushViewController:upgradeController animated:YES];
        }
        
    } description:NSLocalizedString(@"Conversation.ConvertToSuperGroup", nil) height:42 stateback:nil];
    
    _deleteAndExitItem.textColor = [NSColor redColor];
    _convertToSuperGroup.textColor = BLUE_UI_COLOR;
    
}

-(void)changeEditable:(BOOL)editable {
    
    if(self.action.isEditable == editable)
        return;
    
    if(!editable && ![self.headerItem.firstChangedValue isEqualToString:_chat.title] && self.headerItem.firstChangedValue.length > 0) {
        
        NSString *prev = _chat.title;
        
        _chat.title = self.headerItem.firstChangedValue;
        
        [Notification perform:CHAT_UPDATE_TITLE data:@{KEY_CHAT:_chat}];
        
        [RPCRequest sendRequest:[TLAPI_messages_editChatTitle createWithChat_id:_chat.n_id title:self.headerItem.firstChangedValue] successHandler:^(RPCRequest *request, id response) {
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            _chat.title = prev;
            
            [Notification perform:CHAT_UPDATE_TITLE data:@{KEY_CHAT:_chat}];
        }];
    }
    
    
    NSUInteger deleteIndex = [self.tableView indexOfItem:_deleteAndExitItem];
    
    if(deleteIndex != NSNotFound) {
        if(_chat.isCreator && editable) {
            [_tableView insert:_convertToSuperGroup atIndex:deleteIndex tableRedraw:YES];
        }
    }
    
   
    
    
    [self.action setEditable:editable];
    
    [self updateActionNavigation];
    
    if(self.action.isEditable && _chat.isCreator) {
        [_tableView insert:_adminsItem atIndex:[_tableView indexOfItem:_notificationItem]+1 tableRedraw:YES];
    } else {
        [_tableView removeItem:_adminsItem tableRedraw:YES];
    }
    
    [_headerItem setEditable:self.action.isEditable];
    
    weak();
    
    [_tableView.list enumerateObjectsUsingBlock:^(TMRowItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:[TMRowItem class]]) {
            [obj setEditable:weakSelf.action.isEditable];
        }
        
    }];
    

    [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[_tableView indexOfItem:_headerItem]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    
    
    [_tableView enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
        
        TMRowView *view = [rowView.subviews firstObject];
        
        TMRowItem *item = _tableView.list[row];
        if([view isKindOfClass:[TGObjectContainerView class]]) {
            
            TGObjectContainerView *v = (TGObjectContainerView *) view;
            
            [v setEditable:item.isEditable animated:YES];
            
        }
        
    }];
    
    if(!editable)
        [_tableView removeItem:_convertToSuperGroup tableRedraw:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.action.editable = NO;
    
    [self updateActionNavigation];
    [self configure];
    [self drawParticipants];
    [self checkSupergroup];
    
    [_tableView addItem:_deleteAndExitItem tableRedraw:YES];
    
    [Notification addObserver:self selector:@selector(chatParticipantsUpdateNotification:) name:CHAT_UPDATE_PARTICIPANTS];
    [Notification addObserver:self selector:@selector(didChangeChatFlags:) name:CHAT_FLAGS_UPDATED];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
     [Notification removeObserver:self];
}


-(void)didChangeChatFlags:(NSNotification *)notification {
    TLChat *chat = notification.userInfo[KEY_CHAT];
    
    if(_chat == chat) {
        
        if(self.action.isEditable && ((_chat.isAdmins_enabled && !_chat.isAdmin) || !_chat.isCreator)) {
            self.action.editable = NO;
        }
        
        [self updateActionNavigation];
        [self configure];
        [self drawParticipants];
        [self checkSupergroup];
        
        
        [_tableView addItem:_deleteAndExitItem tableRedraw:YES];
    }
}

- (void)chatParticipantsUpdateNotification:(NSNotification *)notification {
    
    TLChat *chat = [[ChatsManager sharedManager] find:[notification.userInfo[KEY_CHAT_ID] intValue]];
    
    [ASQueue dispatchOnMainQueue:^{
        
        if(_chat == chat) {
        
            NSRange range = [self participantsRange];
       
            if(range.length > 0) {
            
                if(range.length != _chat.chatFull.participants_count && (range.length >= maxChatUsers()+1 || _chat.chatFull.participants_count >= maxChatUsers()+1) ) {
                    [self checkSupergroup];
                }
            }
        
            [self drawParticipants];
        
        }
    }];
    
    
}


-(void)setChat:(TLChat *)chat {    
    _chat = chat;
    _conversation = chat.dialog;

    [self setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionInfoProfileBehavior class] filter:nil object:_conversation]];
    
    _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
    

}

-(void)configure {
    
   
    
    
    [self.doneButton setHidden:(_chat.isAdmins_enabled && (!_chat.isAdmin && !_chat.isCreator))];
    
    [_tableView removeAllItems:YES];
    _headerItem = [[TGProfileHeaderRowItem alloc] initWithObject:_conversation];
    
    _headerItem.height = 142;
    [_headerItem setEditable:self.action.isEditable];
    
    [_tableView addItem:_headerItem tableRedraw:YES];
        
    
    _mediaItem = [[TGSProfileMediaRowItem alloc] initWithObject:_conversation];
    _mediaItem.height = 50;
    

    weak();
    
    _mediaItem.controller = self;
    
    [_mediaItem setCallback:^(TGGeneralRowItem *item) {
        
        TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:NSZeroRect];
        
        [viewController setConversation:weakSelf.conversation];
        
        [weakSelf.navigationViewController pushViewController:viewController animated:YES];
        
    }];
    
    [_tableView addItem:_mediaItem tableRedraw:YES];
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    
    [_tableView addItem:_notificationItem tableRedraw:YES];
    
    
    _participantsHeaderItem = [[GeneralSettingsBlockHeaderItem alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Modern.Chat.Members", nil),_chat.chatFull.participants.participants.count] height:42 flipped:NO];
    
    [_tableView addItem:_participantsHeaderItem tableRedraw:YES];
    
   
    
}


-(void)drawParticipants {
    
    
    [_participantsHeaderItem updateWithString:[NSString stringWithFormat:NSLocalizedString(@"Modern.Chat.Members", nil),_chat.participants_count]];
    
    [_participantsHeaderItem redrawRow];
    
    NSRange range = [self participantsRange];
    
    if(range.length > 0) {
        [_tableView removeItemsInRange:range tableRedraw:YES];
    }
    
    weak();
    
    NSArray *participants = [_chat.chatFull.participants.participants copy];
    
    NSMutableArray *items = [NSMutableArray array];
    
    [participants enumerateObjectsUsingBlock:^(TLChatParticipant *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TGUserContainerRowItem *user = [[TGUserContainerRowItem alloc] initWithUser:[[UsersManager sharedManager] find:obj.user_id]];
        user.height = 50;
        user.type = SettingsRowItemTypeNone;
        user.editable = weakSelf.action.isEditable;
        
        if(([obj isKindOfClass:[TL_chatParticipantAdmin class]] && weakSelf.chat.isAdmins_enabled ) || [obj isKindOfClass:[TL_chatParticipantCreator class]]) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
            
            [attr appendString:NSLocalizedString(@"Channel.admin", nil) withColor:GRAY_TEXT_COLOR];
            
            [attr setFont:TGSystemFont(13) forRange:attr.range];
            
            user.badge = attr;
            
            if(user.user.isBot) {
                user.status = NSLocalizedString(@"Bot.botCanReadAllMessages", nil);
            }
            
        }
        
        [user setStateback:^id(TGGeneralRowItem *item) {
            
            
            BOOL canRemoveUser = weakSelf.chat.isAdmins_enabled ? (obj.user_id != [UsersManager currentUserId] && ((weakSelf.chat.isAdmin && ![obj isKindOfClass:[TL_chatParticipantAdmin class]]) || weakSelf.chat.isCreator) && ![obj isKindOfClass:[TL_chatParticipantCreator class]]) : (obj.user_id != [UsersManager currentUserId] && obj.inviter_id == [UsersManager currentUserId]);
            
            return @(canRemoveUser);
            
        }];
        
        __weak TGUserContainerRowItem *weakItem = user;
        
        [user setStateCallback:^{
            
            if(weakSelf.action.isEditable) {
                if([weakItem.stateback(weakItem) boolValue])
                    [weakSelf kickParticipant:weakItem];
            } else {
                TGModernUserViewController *viewController = [[TGModernUserViewController alloc] initWithFrame:NSZeroRect];
                
                [viewController setUser:weakItem.user conversation:weakItem.user.dialog];
                
                [weakSelf.isDisclosureController ? weakSelf.rightNavigationController : weakSelf.navigationViewController pushViewController:viewController animated:YES];
            }
            
        }];
        
        [items addObject:user];
    }];
    
    [items sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(TGUserContainerRowItem *obj1, TGUserContainerRowItem *obj2) {
        
        if(obj1.user.n_id == UsersManager.currentUserId) {
            return NSOrderedAscending;
        }
        
        if(obj2.user.n_id == UsersManager.currentUserId) {
            return NSOrderedDescending;
        }
        
        int online1 = obj1.user.lastSeenTime;
        int online2 = obj2.user.lastSeenTime;
        
        return online1 > online2 ?  NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSUInteger idx = MIN([_tableView indexOfItem:_deleteAndExitItem],[_tableView indexOfItem:_convertToSuperGroup]);
    
    [_tableView insert:items startIndex:idx == NSNotFound ? _tableView.count : idx-1 tableRedraw:YES];
    
    
    
    
    

}


-(void)checkSupergroup {
    
    weak();
    
    NSUInteger startIdx = [_tableView indexOfItem:_headerItem];
    
    NSUInteger stopIdx = [_tableView indexOfItem:_mediaItem];
    
    if(startIdx != NSNotFound && stopIdx != NSNotFound) {
        
        startIdx++;
        
        if(stopIdx > startIdx) {
            [_tableView removeItemsInRange:NSMakeRange(startIdx, stopIdx - startIdx) tableRedraw:YES];
        }
        
    }
    
    GeneralSettingsRowItem *addMembersItem;
    
    if(!_chat.isAdmins_enabled || (_chat.isManager)) {
        addMembersItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            NSMutableArray *filter = [[NSMutableArray alloc] init];
            
            for (TL_chatParticipant *participant in weakSelf.chat.chatFull.participants.participants) {
                [filter addObject:@(participant.user_id)];
            }
            
            
            ComposePickerViewController *viewController = [[ComposePickerViewController alloc] initWithFrame:NSZeroRect];
            
            [viewController setAction:[[ComposeAction alloc]initWithBehaviorClass:[ComposeActionAddGroupMembersBehavior class] filter:filter object:weakSelf.chat.chatFull reservedObjects:@[weakSelf.chat]]];
            
            [weakSelf.navigationViewController pushViewController:viewController animated:YES];
            
            
        } description:NSLocalizedString(@"Group.AddMembers", nil) height:42 stateback:nil];
        addMembersItem.textColor = BLUE_UI_COLOR;
    }
    
     GeneralSettingsRowItem *exportInviteLink;
    
    if(_chat.isCreator) {
        exportInviteLink = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            dispatch_block_t cblock = ^ {
                
                ChatExportLinkViewController *viewController = [[ChatExportLinkViewController alloc] initWithFrame:NSZeroRect];
                
                [viewController setChat:weakSelf.chat.chatFull];
                
                [weakSelf.navigationViewController pushViewController:viewController animated:YES];
                
            };
            
            
            if([weakSelf.chat.chatFull.exported_invite isKindOfClass:[TL_chatInviteExported class]]) {
                
                cblock();
                
            } else {
                
                [weakSelf showModalProgress];
                
                [RPCRequest sendRequest:[TLAPI_messages_exportChatInvite createWithChat_id:weakSelf.chat.n_id] successHandler:^(RPCRequest *request, TL_chatInviteExported *response) {
                    
                    [weakSelf hideModalProgressWithSuccess];
                    
                    weakSelf.chat.chatFull.exported_invite = response;
                    
                    [[Storage manager] insertFullChat:weakSelf.chat.chatFull completeHandler:nil];
                    
                    cblock();
                    
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    [weakSelf hideModalProgress];
                } timeout:10];
                
            }

            
        } description:NSLocalizedString(@"Group.CopyExportChatInvite", nil) height:42 stateback:nil];
        
         exportInviteLink.textColor = BLUE_UI_COLOR;
    }
    
    
    if(addMembersItem || exportInviteLink) {
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    }
    
    int upgradeCount = maxChatUsers()+1;
    
    
    if(self.participantsRange.length >= upgradeCount && _chat.isCreator) {
        
       [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        GeneralSettingsRowItem *upgradeToMegagroup = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            strongWeak();
            
            [strongSelf upgradeToSuperGroup:NO];
            
        } description:NSLocalizedString(@"Modern.Chat.UpgrateToMegagroup", nil) height:42 stateback:nil];
        upgradeToMegagroup.textColor = BLUE_UI_COLOR;
        
        
        GeneralSettingsBlockHeaderItem *upgradeHeaderItem = [[GeneralSettingsBlockHeaderItem alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Modern.Chat.UpgradeToMegagroupDescription", nil),upgradeCount,megagroupSizeMax()] height:200 flipped:YES];
        
        upgradeHeaderItem.autoHeight = YES;
        
        
        [_tableView insert:[[TGGeneralRowItem alloc] initWithHeight:20] atIndex:startIdx tableRedraw:YES];
        [_tableView insert:upgradeHeaderItem atIndex:startIdx tableRedraw:YES];
        [_tableView insert:upgradeToMegagroup atIndex:startIdx tableRedraw:YES];
        
    } else if(addMembersItem) {
        [_tableView insert:[[TGGeneralRowItem alloc] initWithHeight:20] atIndex:startIdx tableRedraw:YES];
        
        if(exportInviteLink) {
            [_tableView insert:exportInviteLink atIndex:startIdx tableRedraw:YES];
        }
        
        [_tableView insert:addMembersItem atIndex:startIdx tableRedraw:YES];
        
        
        
    }
}

-(NSRange)participantsRange {
    NSUInteger startIdx = [_tableView indexOfItem:_participantsHeaderItem]+1;
    NSUInteger stopIdx = MIN([_tableView indexOfItem:_deleteAndExitItem],[_tableView indexOfItem:_convertToSuperGroup]);
    
    if(stopIdx != NSNotFound)
        stopIdx--;
     else
         stopIdx = _tableView.count - startIdx;
    
    
    if(startIdx != stopIdx && startIdx < stopIdx) {
        
        return NSMakeRange(startIdx, stopIdx - startIdx);
        
    }
    
    return NSMakeRange(startIdx, 0);
}

-(void)kickParticipant:(TGUserContainerRowItem *)participant {
    
    NSRange range = [self participantsRange];
    
    [_tableView removeItem:participant];
    
    
    if(range.length == maxChatUsers() && _chat.isCreator) {
        [self checkSupergroup];
    }
    
    dispatch_block_t updateBlock = ^{
        NSArray *participants = [_chat.chatFull.participants.participants filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.user_id == %d",participant.user.n_id]];
        
        if(participants.count == 1) {
            id object = participants[0];
            
            [_chat.chatFull.participants.participants removeObject:object];
            
            [[Storage manager] insertFullChat:_chat.chatFull completeHandler:nil];
        }
    };
    
     updateBlock();
    
    [RPCRequest sendRequest:[TLAPI_messages_deleteChatUser createWithChat_id:_chat.n_id user_id:participant.user.inputUser] successHandler:^(RPCRequest *request, id response) {
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        [[ChatFullManager sharedManager] requestChatFull:_chat.n_id withCallback:^(TLChatFull *fullChat) {
            [self drawParticipants];
        }];

    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
}

-(void)dealloc {
    
    [_tableView clear];
    
}

-(void)upgradeToSuperGroup:(BOOL)force {
    
    confirm(NSLocalizedString(force ? @"ConvertGroupAlertWarning" : @"Modern.Chat.UpgradeConfirmHeader", nil), NSLocalizedString(force ? @"ConvertGroupAlert" : @"Modern.Chat.UpgradeConfirmDescription", nil), ^{
        
        [self showModalProgress];
        
        
        [RPCRequest sendRequest:[TLAPI_messages_migrateChat createWithChat_id:self.chat.n_id] successHandler:^(id request, id response) {
            
            TLChat *chat = [[ChatsManager sharedManager] find:self.chat.migrated_to.channel_id];
            
            if(chat) {
                
                [[ChatFullManager sharedManager] requestChatFull:chat.n_id withCallback:^(TLChatFull *fullChat) {
                    
                    [self.navigationViewController showMessagesViewController:chat.dialog];
                    
                    [self hideModalProgressWithSuccess];
                }];
                
                
            }

            
            
            
            
        } errorHandler:^(id request, RpcError *error) {
            [ASQueue dispatchOnMainQueue:^{
                [self hideModalProgress];
                alert(appName(), NSLocalizedString(@"Alert.somethingIsWrong", nil));
            }];

        } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
        
    }, nil);
    
}

@end
