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
#import "TGUserContainerView.h"
#import "TGProfileHeaderRowView.h"
#import "TGModernUserViewController.h"
#import "ComposeActionAddGroupMembersBehavior.h"
#import "TGPhotoViewer.h"
#import "ChatAdminsViewController.h"
@interface TGModernChatInfoViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;

@property (nonatomic,strong) TLChat *chat;
@property (nonatomic,strong) TL_conversation *conversation;


@property (nonatomic,strong) GeneralSettingsBlockHeaderItem *participantsHeaderItem;
@property (nonatomic,strong) GeneralSettingsRowItem *notificationItem;
@property (nonatomic,strong) GeneralSettingsRowItem *adminsItem;
@property (nonatomic,strong) GeneralSettingsRowItem *deleteAndExitItem;
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
        
        viewController.chat = self.chat;
        
        [self.navigationViewController pushViewController:viewController animated:YES];
        
    } description:NSLocalizedString(@"Modern.Profile.SetAdmins", nil) height:42 stateback:nil];
    
    _notificationItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
        
        [_conversation muteOrUnmute:nil until:0];
        
    } description:NSLocalizedString(@"Notifications", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @(!_conversation.isMute);
    }];
    

    _deleteAndExitItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
        
        [self.messagesViewController deleteDialog:_conversation callback:^{
            
        }];
        
    } description:NSLocalizedString(@"Conversation.DeleteAndExit", nil) height:42 stateback:nil];
    _deleteAndExitItem.textColor = [NSColor redColor];
    
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
    
    
    
    [self.action setEditable:editable];
    
    [self updateActionNavigation];
    
    if(self.action.isEditable && _chat.isCreator) {
        [_tableView insert:_adminsItem atIndex:[_tableView indexOfItem:_notificationItem]+1 tableRedraw:YES];
    } else {
        [_tableView removeItem:_adminsItem tableRedraw:YES];
    }
    
    [_headerItem setEditable:self.action.isEditable];
    
    
    [_tableView.list enumerateObjectsUsingBlock:^(TMRowItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:[TMRowItem class]]) {
            [obj setEditable:self.action.isEditable];
        }
        
    }];
    

    [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[_tableView indexOfItem:_headerItem]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    
    
    [_tableView enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * _Nonnull rowView, NSInteger row) {
        
        TMRowView *view = [rowView.subviews firstObject];
        
        TMRowItem *item = _tableView.list[row];
        if([view isKindOfClass:[TGUserContainerView class]]) {
            
            TGUserContainerView *v = (TGUserContainerView *) view;
            
            [v setEditable:item.isEditable animated:YES];
            
        }
        
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.action.editable = NO;
    
    [self updateActionNavigation];
    
    [self configure];
    
    [self drawParticipants];
    
    [self checkSupergroup];
    
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
        
        [self configure];
        [self drawParticipants];
        
    }
}

- (void)chatParticipantsUpdateNotification:(NSNotification *)notification {
    
    TLChat *chat = notification.userInfo[KEY_CHAT];
    
    if(_chat == chat) {
        
        NSRange range = [self participantsRange];
       
        if(range.length > 0) {
            
            if(range.length != _chat.chatFull.participants_count && (range.length >= maxChatUsers()+1 || _chat.chatFull.participants_count >= maxChatUsers()+1) ) {
                [self checkSupergroup];
            }
        }
        
        [self drawParticipants];
        
    }
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
    
    [_participantsHeaderItem redrawRow];
    
    NSRange range = [self participantsRange];
    
    if(range.length > 0) {
        [_tableView removeItemsInRange:range tableRedraw:YES];
    }
    
    
    NSArray *participants = [_chat.chatFull.participants.participants copy];
    
    NSMutableArray *items = [NSMutableArray array];
    
    [participants enumerateObjectsUsingBlock:^(TLChatParticipant *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TGUserContainerRowItem *user = [[TGUserContainerRowItem alloc] initWithUser:[[UsersManager sharedManager] find:obj.user_id]];
        user.height = 50;
        user.type = SettingsRowItemTypeNone;
        user.editable = self.action.isEditable;
        
        
        [user setStateback:^id(TGGeneralRowItem *item) {
            
            BOOL canRemoveUser = _chat.isAdmins_enabled ? (obj.user_id != [UsersManager currentUserId] && (self.chat.isAdmin || self.chat.isCreator) && ![obj isKindOfClass:[TL_chatParticipantCreator class]]) : (obj.user_id != [UsersManager currentUserId] && obj.inviter_id == [UsersManager currentUserId]);
            
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
    
    [_tableView insert:items startIndex:_tableView.list.count tableRedraw:YES];
    
    
    [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    
    [_tableView addItem:_deleteAndExitItem tableRedraw:YES];
    
}


-(void)checkSupergroup {
    
    
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
            
            for (TL_chatParticipant *participant in _chat.chatFull.participants.participants) {
                [filter addObject:@(participant.user_id)];
            }
            
            
            ComposePickerViewController *viewController = [[ComposePickerViewController alloc] initWithFrame:NSZeroRect];
            
            [viewController setAction:[[ComposeAction alloc]initWithBehaviorClass:[ComposeActionAddGroupMembersBehavior class] filter:filter object:_chat.chatFull reservedObjects:@[_chat]]];
            
            [self.navigationViewController pushViewController:viewController animated:YES];
            
            
        } description:NSLocalizedString(@"Group.AddMembers", nil) height:42 stateback:nil];
        addMembersItem.textColor = BLUE_UI_COLOR;
    }
    
     GeneralSettingsRowItem *exportInviteLink;
    
    if(_chat.isCreator) {
        exportInviteLink = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            dispatch_block_t cblock = ^ {
                
                ChatExportLinkViewController *viewController = [[ChatExportLinkViewController alloc] initWithFrame:NSZeroRect];
                
                [viewController setChat:self.chat.chatFull];
                
                [self.navigationViewController pushViewController:viewController animated:YES];
                
            };
            
            
            if([_chat.chatFull.exported_invite isKindOfClass:[TL_chatInviteExported class]]) {
                
                cblock();
                
            } else {
                
                [self showModalProgress];
                
                [RPCRequest sendRequest:[TLAPI_messages_exportChatInvite createWithChat_id:self.chat.n_id] successHandler:^(RPCRequest *request, TL_chatInviteExported *response) {
                    
                    [self hideModalProgressWithSuccess];
                    
                    _chat.chatFull.exported_invite = response;
                    
                    [[Storage manager] insertFullChat:self.chat.chatFull completeHandler:nil];
                    
                    cblock();
                    
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    [self hideModalProgress];
                } timeout:10];
                
            }

            
        } description:NSLocalizedString(@"Group.CopyExportChatInvite", nil) height:42 stateback:nil];
        
         exportInviteLink.textColor = BLUE_UI_COLOR;
    }
    
    
    if(addMembersItem || exportInviteLink) {
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
    }
    
    int upgradeCount = maxChatUsers()+1;
    
//#ifdef TGDEBUG 
//    upgradeCount = ACCEPT_FEATURE ? 4 : upgradeCount;
//#endif
    
    if(self.participantsRange.length >= upgradeCount && _chat.isCreator && ACCEPT_FEATURE) {
        
       [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        GeneralSettingsRowItem *upgradeToMegagroup = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            confirm(NSLocalizedString(@"Modern.Chat.UpgradeConfirmHeader", nil), NSLocalizedString(@"Modern.Chat.UpgradeConfirmDescription", nil), ^{
                
                [self showModalProgress];
                
                [RPCRequest sendRequest:[TLAPI_messages_migrateChat createWithChat_id:_chat.n_id] successHandler:^(id request, id response) {
                    
                    TLChat *chat = [[ChatsManager sharedManager] find:_chat.migrated_to.channel_id];
                    
                    if(chat) {
                        
                        [[FullChatManager sharedManager] performLoad:chat.n_id callback:^(TLChatFull *fullChat) {
                            
                            [self.navigationViewController showMessagesViewController:chat.dialog];
                            
                            [self hideModalProgressWithSuccess];
                        }];
                        
                        
                    }
                    
                    
                } errorHandler:^(id request, RpcError *error) {
                    [self hideModalProgress];
                    
                    alert(appName(), NSLocalizedString(@"Alert.somethingIsWrong", nil));
                } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
                
            }, ^{
                
            });
            
            
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
    NSUInteger stopIdx = [_tableView indexOfItem:_deleteAndExitItem];
    
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
        
        [[FullChatManager sharedManager] performLoad:_chat.n_id callback:^(TLChatFull *fullChat) {
            [self drawParticipants];
        }];

    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
}

@end
