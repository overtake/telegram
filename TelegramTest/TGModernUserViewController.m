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
@interface TGModernUserViewController ()
@property (nonatomic,strong) TLUser *user;
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) TGSettingsTableView *tableView;


@property (nonatomic,strong) TGProfileParamItem *userNameItem;
@property (nonatomic,strong) TGProfileParamItem *phoneNumberItem;



@end

@implementation TGModernUserViewController

-(void)loadView {
    [super loadView];
    
    
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
    
   
    
}

-(void)didUpdatedEditableState {
    [self configure];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setEditable:YES];
    [Notification addObserver:self selector:@selector(changeUserName:) name:USER_UPDATE_NAME];
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
    
    [self configure];
}

-(void)changeEditableWithAnimation {
    
}

-(void)configure {
    
    
    
    
    [_tableView removeAllItems:YES];
    
    
    TGProfileHeaderRowItem *headerItem = [[TGProfileHeaderRowItem alloc] initWithObject:_conversation];
    headerItem.height = 142;
    
    [headerItem setEditable:self.action.isEditable];
    self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
    [_tableView addItem:headerItem tableRedraw:YES];
    self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
    GeneralSettingsRowItem *sendMessage;
    
    if(_conversation.type != DialogTypeSecretChat) {
        sendMessage = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
        } description:NSLocalizedString(@"Profile.SendMessage", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
            
            return nil;
            
        }];
    }
    
    
    
    GeneralSettingsRowItem *startSecretChat;
    
    
    if(_user.type != TLUserTypeSelf && _conversation.type != DialogTypeSecretChat && !_user.isBot) {
        startSecretChat = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            
        } description:NSLocalizedString(@"Conversation.StartSecretChat", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
            
            return nil;
            
        }];
    }
    
    GeneralSettingsRowItem *shareContact;
    if((_user.type == TLUserTypeContact || _user.type == TLUserTypeSelf || self.user.isBot) && _conversation.type != DialogTypeSecretChat) {
        shareContact = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
        } description:NSLocalizedString(_user.isBot ? @"Profile.ShareBot" : @"Profile.ShareContact", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
            
            return nil;
            
        }];
    }
    
    
    
    sendMessage.textColor = BLUE_UI_COLOR;
    startSecretChat.textColor = BLUE_UI_COLOR;
    shareContact.textColor = BLUE_UI_COLOR;
    
    
    
    GeneralSettingsRowItem *encryptionKeyItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        
        
    } description:NSLocalizedString(@"Profile.ShowEncryptedKey", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        
        EncryptedParams *params = [EncryptedParams findAndCreate:_conversation.encryptedChat.n_id];
        
        NSData *hashData = MTSha1([params lastKey]);
        
        return TGIdenticonImage(hashData,NSMakeSize(20, 20));
        
    }];
    
    
    
    GeneralSettingsRowItem *notificationItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeChoice callback:^(TGGeneralRowItem *item) {
        
        
    } description:NSLocalizedString(@"Notifications", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        
        return [MessagesUtils muteUntil:self.conversation.notify_settings.mute_until];
        
    }];
    
    
    notificationItem.menu = [MessagesViewController notifications:^{
        
        [self configure];
        
    } conversation:self.conversation click:^{
        
    }];
    
    GeneralSettingsRowItem *blockUserItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
        
    } description:NSLocalizedString(@"Profile.BlockContact", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return nil;
    }];
    blockUserItem.textColor = [NSColor redColor];
    
    GeneralSettingsRowItem *deleteSecretChatItem = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
        
    } description:NSLocalizedString(@"Conversation.DeleteSecretChat", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return nil;
    }];
    deleteSecretChatItem.textColor = [NSColor redColor];
    
    TGSProfileMediaRowItem *profileMediaItem = [[TGSProfileMediaRowItem alloc] initWithObject:_conversation];
    
    profileMediaItem.height = 50;
    profileMediaItem.xOffset = 30;
    
    
    if(!self.action.isEditable) {
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
        
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        [_tableView addItem:profileMediaItem tableRedraw:YES];
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        [_tableView addItem:notificationItem tableRedraw:YES];
        
        if(_conversation.type == DialogTypeSecretChat)
            [_tableView addItem:encryptionKeyItem tableRedraw:YES];
        
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        if(_conversation.type != DialogTypeSecretChat)
            [_tableView addItem:blockUserItem tableRedraw:YES];
        else
            [_tableView addItem:deleteSecretChatItem tableRedraw:YES];
    } else {
        [_tableView addItem:notificationItem tableRedraw:YES];
        
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:YES];
        
        GeneralSettingsRowItem *deleteContact = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNone callback:^(TGGeneralRowItem *item) {
            
            
        } description:NSLocalizedString(@"Profile.DeleteContact", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
            return nil;
        }];
        
        deleteContact.textColor = [NSColor redColor];
        
        [_tableView addItem:deleteContact tableRedraw:YES];
        
    }
    
    
    
    
   // [_tableView reloadData];
    
}

@end
