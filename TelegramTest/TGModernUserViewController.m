//
//  TGModernUserViewController.m
//  Telegram
//
//  Created by keepcoder on 28.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGModernUserViewController.h"
#import "TGSettingsTableView.h"
#import "TGSProfileMediaRowItem.h"
#import "TGProfileParamItem.h"
#import "MessagesUtils.h"
#import "TGProfileHeaderRowItem.h"
#import <MtProtoKit/MTEncryption.h>
#import "ComposeActionInfoProfileBehavior.h"
#import "TGShareContactModalView.h"
#import "ComposeActionAddUserToGroupBehavior.h"
#import "TGReportChannelModalView.h"
#import "FullUsersManager.h"
@interface TGModernUserViewController ()
@property (nonatomic,strong) TLUser *user;
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) TGSettingsTableView *tableView;


@property (nonatomic,strong) TGProfileParamItem *userNameItem;
@property (nonatomic,strong) TGProfileParamItem *phoneNumberItem;

@property (nonatomic,strong) TGProfileHeaderRowItem *headerItem;

@property (nonatomic,strong) TL_userFull *userFull;
@end

@implementation TGModernUserViewController

-(void)loadView {
    [super loadView];
    
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    
    
    
}


- (TL_inputPhoneContact *)newContact {
    NSString *first_name = self.headerItem.firstChangedValue;
    NSString *last_name = self.headerItem.secondChangedValue;
    
    if( ([first_name isEqualToString:self.user.first_name] && [last_name isEqualToString:self.user.last_name]) || (first_name.length == 0))
        return nil;
    
    return [TL_inputPhoneContact createWithClient_id:0 phone:self.user.phone first_name:first_name last_name:last_name];
}

-(void)didUpdatedEditableState {
    
    if(!self.action.isEditable) {
        TL_inputPhoneContact *contact = [self newContact];
        
        if(contact) {
            [[NewContactsManager sharedManager] importContact:contact callback:^(BOOL isAdd, TL_importedContact *contact, TLUser *user) {
                
            }];
        } 
        
    }
    
    [self configure];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setEditable:YES];
    [Notification addObserver:self selector:@selector(changeUserName:) name:USER_UPDATE_NAME];
    
    [self configure];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Notification removeObserver:self];
}


-(void)changeUserName:(NSNotification *)notification
{
    TLUser *user = [notification.userInfo objectForKey:KEY_USER];
    if(user.n_id == self.user.n_id) {
        
        _tableView.defaultAnimation = NSTableViewAnimationEffectFade;
        if(![_userNameItem.value.string isEqualToString:user.username] && user.username.length > 0) {
            
            if(!_userNameItem)
            {
                _userNameItem = [[TGProfileParamItem alloc] init];
                [_userNameItem setHeader:NSLocalizedString(@"Profile.username", nil) withValue:[NSString stringWithFormat:@"@%@",_user.username]];
                
                _userNameItem.height = 50;
            }
            
            [_tableView insert:_userNameItem atIndex:_phoneNumberItem != nil ? 2 : 1 tableRedraw:YES];
        } else if(user.username.length == 0 && _userNameItem) {
            [_tableView removeItem:_userNameItem tableRedraw:YES];
        } else if([_userNameItem.value.string isEqualToString:user.username]) {
            [self configure];
        }
        _tableView.defaultAnimation = NSTableViewAnimationEffectNone;
    }
}

-(void)setUser:(TLUser *)user conversation:(TL_conversation *)conversation {
    
    
    [self loadViewIfNeeded];
    _conversation = conversation;
    _user = user;
    
    if(!conversation)
        _conversation = _user.dialog;
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
    [self setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionInfoProfileBehavior class] filter:nil object:_conversation]];
        
    _userFull = nil;
    
    if(user.isBot) {
        [[FullUsersManager sharedManager] loadUserFull:_user callback:^(TL_userFull *userFull) {
            
            _userFull = userFull;
            
            [self configure];
            
        }];
    }
    
    [self configure];
   
}

-(void)changeEditableWithAnimation {
    
}

-(void)configure {
    
    [self.doneButton setHidden:_conversation.type == DialogTypeSecretChat || [_user isSelf]];
    
    [_tableView removeAllItems:YES];
    
    _headerItem = [[TGProfileHeaderRowItem alloc] initWithObject:_conversation];
    _headerItem.height = 142;
    
    [_headerItem setEditable:self.action.isEditable];
    self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
    [_tableView addItem:_headerItem tableRedraw:YES];
    self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
    weak();
    
    GeneralSettingsRowItem *sendMessage;
    
    if(_conversation.type != DialogTypeSecretChat) {
        sendMessage = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            [weakSelf.navigationViewController showMessagesViewController:weakSelf.conversation];
            
        } description:NSLocalizedString(@"Profile.SendMessage", nil) height:42 stateback:nil];
    }
    
    GeneralSettingsRowItem *startSecretChat;
    
    if(_user.type != TLUserTypeSelf && _conversation.type != DialogTypeSecretChat && !_user.isBot) {
        startSecretChat = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            [weakSelf showModalProgress];
           
            [MessageSender startEncryptedChat:weakSelf.user callback:^ {
                
                [weakSelf hideModalProgressWithSuccess];
                
            }];
            
        } description:NSLocalizedString(@"Conversation.StartSecretChat", nil) height:42 stateback:nil];
    }
    
    GeneralSettingsRowItem *shareContact;
    if((_user.type == TLUserTypeContact || _user.type == TLUserTypeSelf || self.user.isBot) && _conversation.type != DialogTypeSecretChat) {
        shareContact = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            
            if(weakSelf.user.isBot) {
                
                
                [weakSelf showModalProgress];
                
                NSPasteboard* cb = [NSPasteboard generalPasteboard];
                
                [cb declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:weakSelf];
                [cb setString:[NSString stringWithFormat:@"https://telegram.me/%@",weakSelf.user.username] forType:NSStringPboardType];
                
                dispatch_after_seconds(0.2, ^{
                    
                    [weakSelf hideModalProgressWithSuccess];
                    
                });
                
            } else {
                
                TGShareContactModalView *shareContactModalView = [[TGShareContactModalView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.window.frame), NSHeight(self.view.window.frame))];
                
                
                [shareContactModalView setMessagesViewController:self.navigationViewController.messagesViewController];
                [shareContactModalView setUser:self.user];
                
                [shareContactModalView show:self.view.window animated:YES];
                
            }

            
        } description:NSLocalizedString(_user.isBot ? @"Profile.ShareBot" : @"Profile.ShareContact", nil) height:42 stateback:nil];
    }
    
    GeneralSettingsRowItem *addToGroupItem;
    
    if(_user.isBot && !_user.isBot_nochats) {
        
       addToGroupItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            ComposeChooseGroupViewController *viewController = [[ComposeChooseGroupViewController alloc] init];
            
            [viewController setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionAddUserToGroupBehavior class] filter:nil object:weakSelf.user]];
            
            [weakSelf.navigationViewController pushViewController:viewController animated:YES];
            
        } description:NSLocalizedString(@"Profile.AddToGroup", nil) height:42 stateback:nil];
        
    }
    
    GeneralSettingsRowItem *helpItem;
    if(_user.isBot && _userFull) {
        
        __block BOOL canHelp = NO;
       __block  NSString *command = @"/help";
        
        [_userFull.bot_info.commands enumerateObjectsUsingBlock:^(TL_botCommand *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if([obj.command hasPrefix:@"help"]) {
                command = obj.command;
                canHelp = YES;
                *stop = YES;
            }
            
        }];
        
        if(canHelp) {
            helpItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
                
                [weakSelf.navigationViewController showMessagesViewController:_conversation];
                [weakSelf.navigationViewController.messagesViewController sendMessage:command forConversation:weakSelf.conversation];
                
            } description:NSLocalizedString(@"Bot.Help", nil) height:42 stateback:nil];
        } 
        
    }

    helpItem.textColor = BLUE_UI_COLOR;
    addToGroupItem.textColor = BLUE_UI_COLOR;
    sendMessage.textColor = BLUE_UI_COLOR;
    startSecretChat.textColor = BLUE_UI_COLOR;
    shareContact.textColor = BLUE_UI_COLOR;
    
    
    GeneralSettingsRowItem *encryptionKeyItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        EncryptedKeyViewController *viewController = [[EncryptedKeyViewController alloc] initWithFrame:NSZeroRect];
        
        [viewController showForChat:weakSelf.conversation.encryptedChat];
        
        [weakSelf.navigationViewController pushViewController:viewController animated:YES];
        
    } description:NSLocalizedString(@"Profile.ShowEncryptedKey", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        
        EncryptedParams *params = [EncryptedParams findAndCreate:weakSelf.conversation.encryptedChat.n_id];
        
        NSData *hashData = MTSha1([params lastKey]);
        
        return TGIdenticonImage(hashData,NSMakeSize(20, 20));
        
    }];
    
    GeneralSettingsRowItem *notificationItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
        
        [weakSelf.conversation muteOrUnmute:nil until:0];
        
    } description:NSLocalizedString(@"Notifications", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @(!_conversation.isMute);
    }];
    
    GeneralSettingsRowItem *blockUserItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
        
        BlockedHandler handlerBlock = ^(BOOL result) {
            
            [weakSelf hideModalProgressWithSuccess];
            
            if(!weakSelf.user.isBlocked && weakSelf.user.isBot)
            {
                [weakSelf.navigationViewController showMessagesViewController:weakSelf.conversation];
                [weakSelf.navigationViewController.messagesViewController sendMessage:@"/start" forConversation:weakSelf.conversation];
            }
            
            [weakSelf configure];
        };
        
        [self showModalProgress];
        
        if(weakSelf.user.isBlocked) {
            [[BlockedUsersManager sharedManager] unblock:weakSelf.user.n_id completeHandler:handlerBlock];
        } else {
            [[BlockedUsersManager sharedManager] block:weakSelf.user.n_id completeHandler:handlerBlock];
        }
        
    } description:_user.isBlocked ? (_user.isBot ? NSLocalizedString(@"RestartBot", nil) : NSLocalizedString(@"Profile.UnblockContact", nil)) : (_user.isBot ? NSLocalizedString(@"StopBot", nil) : NSLocalizedString(@"Profile.BlockContact", nil)) height:42 stateback:nil];
    blockUserItem.textColor = [NSColor redColor];
    
    
    GeneralSettingsRowItem *reportItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
        
        TGReportChannelModalView *reportModalView = [[TGReportChannelModalView alloc] initWithFrame:[self.view.window.contentView bounds]];
        
        reportModalView.conversation = _conversation;
        
        [reportModalView show:self.view.window animated:YES];
        
        
    } description:NSLocalizedString(@"Profile.ReportChannel", nil) height:42 stateback:nil];
    
    reportItem.textColor = BLUE_UI_COLOR;
    
    GeneralSettingsRowItem *deleteSecretChatItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
        
        [weakSelf showModalProgress];
        [weakSelf.navigationViewController.messagesViewController deleteDialog:weakSelf.conversation callback:^{
            [weakSelf hideModalProgressWithSuccess];
        }];

        
    } description:NSLocalizedString(@"Conversation.DeleteSecretChat", nil) height:42 stateback:nil];
    deleteSecretChatItem.textColor = [NSColor redColor];
    
    TGSProfileMediaRowItem *profileMediaItem = [[TGSProfileMediaRowItem alloc] initWithObject:_conversation];
    
    profileMediaItem.controller = self;
    
    [profileMediaItem setCallback:^(TGGeneralRowItem *item) {
        TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:NSZeroRect];
        
        [viewController setConversation:weakSelf.conversation];
        
        [weakSelf.navigationViewController pushViewController:viewController animated:YES];
        
    }];
    
    profileMediaItem.height = 50;
    profileMediaItem.xOffset = 30;
    
    if(!self.action.isEditable) {
        
        
        if(_userFull && _userFull.bot_info.n_description.length > 0) {
            TGProfileParamItem *botInfo = [[TGProfileParamItem alloc] init];
            
            [botInfo setHeader:NSLocalizedString(@"Profile.About", nil) withValue:_userFull.bot_info.n_description];
            [_tableView addItem:botInfo tableRedraw:YES];
            [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        }
        
        
        if(_user.username.length > 0) {
            _userNameItem = [[TGProfileParamItem alloc] init];
            
            [_userNameItem setHeader:NSLocalizedString(@"Profile.username", nil) withValue:[NSString stringWithFormat:@"@%@",_user.username]];
            
            _userNameItem.height = 50;
            
            [_tableView addItem:_userNameItem tableRedraw:YES];
        }
        
        if(_user.phone.length > 0) {
            _phoneNumberItem = [[TGProfileParamItem alloc] init];
            
            [_phoneNumberItem setHeader:NSLocalizedString(@"Profile.MobilePhone", nil) withValue:_user.phoneWithFormat];
            
            _phoneNumberItem.height = 50;
            
            if(_userNameItem)
                [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
            
            [_tableView addItem:_phoneNumberItem tableRedraw:YES];
        }
        
        
        
        if(sendMessage || startSecretChat || shareContact) {
            [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        }
        
        if(sendMessage)
            [_tableView addItem:sendMessage tableRedraw:YES];
        if(startSecretChat)
            [_tableView addItem:startSecretChat tableRedraw:YES];
        if(shareContact)
            [_tableView addItem:shareContact tableRedraw:YES];
        
        if(addToGroupItem)
            [_tableView addItem:addToGroupItem tableRedraw:YES];
        if(helpItem)
            [_tableView addItem:helpItem tableRedraw:YES];
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        [_tableView addItem:profileMediaItem tableRedraw:YES];
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        [_tableView addItem:notificationItem tableRedraw:YES];
        
        if(_conversation.type == DialogTypeSecretChat)
            [_tableView addItem:encryptionKeyItem tableRedraw:YES];
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        if(_conversation.type != DialogTypeSecretChat) {
            if(self.user.isBot) {
                [_tableView addItem:reportItem tableRedraw:YES];
            }
            
            if(self.user.type != TLUserTypeSelf)
                [_tableView addItem:blockUserItem tableRedraw:YES];
        } else
            [_tableView addItem:deleteSecretChatItem tableRedraw:YES];
    } else {
        [_tableView addItem:notificationItem tableRedraw:YES];
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        if(_user.isContact) {
            GeneralSettingsRowItem *deleteContact = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
                
                [[NewContactsManager sharedManager] deleteContact:weakSelf.user completeHandler:^(BOOL result) {
                    weakSelf.action.editable = NO;
                    [weakSelf updateActionNavigation];
                    [weakSelf didUpdatedEditableState];
                }];
                
            } description:NSLocalizedString(@"Profile.DeleteContact", nil) height:42 stateback:nil];
            
            deleteContact.textColor = [NSColor redColor];
            
            [_tableView addItem:deleteContact tableRedraw:YES];
        }

    }
}


-(void)_didStackRemoved {
    NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)self));
    
    int bp = 0;
}

-(void)dealloc {
    
}

@end
