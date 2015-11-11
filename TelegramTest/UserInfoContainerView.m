//
//  UserInfoContainerView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/25/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserInfoContainerView.h"
#import "TMAvatarImageView.h"
#import "TMAttributedString.h"
#import "NS(Attributed)String+Geometrics.h"
#import "Telegram.h"
#import "UserInfoShortButtonView.h"
#import "UserInfoParamsView.h"
#import "ChatInfoNotificationView.h"
#import "HackUtils.h"
#import "ProfileSharedMediaView.h"
#import "PhotoHistoryFilter.h"
#import "EncryptedKeyWindow.h"
#import "Crypto.h"
#import "SelfDestructionController.h"
#import "MessagesUtils.h"
#import "TMMediaController.h"
#import "TMSharedMediaButton.h"
#import "TMMenuPopover.h"
#import "FullUsersManager.h"
#import "ComposeActionAddUserToGroupBehavior.h"
#import "TGShareContactModalView.h"
@interface UserInfoContainerView()
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@property (nonatomic, strong) NSTextView *nameTextView;

@property (nonatomic, strong) TMStatusTextField *statusTextField;

@property (nonatomic, strong) UserInfoShortButtonView *sendMessageButton;
@property (nonatomic, strong) UserInfoShortButtonView *shareContactButton;
@property (nonatomic, strong) UserInfoShortButtonView *blockContact;


@property (nonatomic, strong) TMSharedMediaButton *filesMediaButton;
@property (nonatomic, strong) TMSharedMediaButton *sharedMediaButton;
@property (nonatomic, strong) TMSharedMediaButton *sharedLinksButton;
@property (nonatomic, strong) UserInfoShortButtonView *startSecretChatButton;
@property (nonatomic, strong) UserInfoShortButtonView *setProfilePhotoButton;
@property (nonatomic, strong) UserInfoShortButtonView *importContacts;
@property (nonatomic, strong) UserInfoShortButtonView *addToGroupButton;
@property (nonatomic, strong) UserInfoShortButtonView *helpBotButton;

@property (nonatomic, strong) UserInfoShortButtonView *encryptedKeyButton;
@property (nonatomic, strong) UserInfoShortButtonView *setTTLButton;
@property (nonatomic, strong) UserInfoShortButtonView *deleteSecretChatButton;


@property (nonatomic, strong) UserInfoParamsView *phoneView;
@property (nonatomic, strong) UserInfoParamsView *userNameView;
@property (nonatomic, strong) UserInfoParamsView *botInfoView;

@property (nonatomic, strong) UserInfoShortButtonView *notificationView;

@property (nonatomic, strong) TMView *nameNormalView;
@property (nonatomic, strong) TMView *nameEditView;

@property (nonatomic, strong) NSImageView *imageForKey;

@property (nonatomic,strong) TMTextField *ttlTitle;
@property (nonatomic,strong) TMTextField *sharedTitle;

@property (nonatomic,strong) TMTextField *muteUntilTitle;

@property (nonatomic,strong) ITSwitch *notificationsSwitcher;

@property (nonatomic, strong) NSProgressIndicator *profileProgressIndicator;

@end

@implementation UserInfoContainerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.wantsLayer = YES;
        
       // self.layer.backgroundColor = [NSColor blueColor].CGColor;
        
        self.profileProgressIndicator = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(40, 40, 30, 30)];
        
        //NameView
        self.nameNormalView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
        [self addSubview:self.nameNormalView];

        self.statusTextField = [[TMStatusTextField alloc] initWithFrame:NSZeroRect];
        [self.statusTextField setStatusDelegate:self];
        [self.statusTextField setSelector:@selector(statusForUserInfoView)];
        [self addSubview:self.statusTextField];
        
        self.nameTextView = [[NSTextView alloc] initWithFrame:NSZeroRect];
        [self.nameTextView setAutoresizesSubviews:YES];
        [self.nameTextView setAutoresizingMask:NSViewWidthSizable];
        [self.nameTextView setEditable:NO];
        [self addSubview:self.nameTextView];
        
        
        self.ttlTitle = [TMTextField defaultTextField];
        self.sharedTitle = [TMTextField defaultTextField];
        self.muteUntilTitle = [TMTextField defaultTextField];
      
        float offsetRight = self.bounds.size.width - 200;
        
        __block UserInfoContainerView *weakSelf = self;
    
        self.sendMessageButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.SendMessage", nil) tapBlock:^{
            [appWindow().navigationController showMessagesViewController:weakSelf.user.dialog];
        }];
        [self.sendMessageButton setFrameSize:NSMakeSize(offsetRight, 42)];
        [self addSubview:self.sendMessageButton];
        

        self.shareContactButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.ShareContact", nil) tapBlock:^{
            
            if(weakSelf.user.isBot) {
                
                
                [self.controller showModalProgress];
                
                NSPasteboard* cb = [NSPasteboard generalPasteboard];
                
                [cb declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:self];
                [cb setString:[NSString stringWithFormat:@"https://telegram.me/%@",weakSelf.user.username] forType:NSStringPboardType];
                
                dispatch_after_seconds(0.2, ^{
                    
                    [self.controller hideModalProgressWithSuccess];
                    
                });
                
            } else {
                
                TGShareContactModalView *shareContactModalView = [[TGShareContactModalView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(weakSelf.window.frame), NSHeight(weakSelf.window.frame))];
                
                [shareContactModalView setMessagesViewController:weakSelf.controller.navigationViewController.messagesViewController];
                [shareContactModalView setUser:weakSelf.user];
                
                [shareContactModalView show:weakSelf.window animated:YES];
                
               // [[Telegram rightViewController] showShareContactModalView:weakSelf.user];
            }
            
        }];
        
        
        self.blockContact = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.BlockContact", nil) tapBlock:^{
            
            self.blockContact.locked = YES;
            
            BlockedHandler handlerBlock = ^(BOOL result) {
                self.blockContact.locked = NO;
                
                if(!self.user.isBlocked && self.user.isBot)
                {
                    [self.controller.navigationViewController goBackWithAnimation:YES];
                    [self.controller.navigationViewController.messagesViewController sendMessage:@"/start" forConversation:self.controller.conversation];
                }
            };
            
            if(self.user.isBlocked) {
                [[BlockedUsersManager sharedManager] unblock:self.user.n_id completeHandler:handlerBlock];
            } else {
                [[BlockedUsersManager sharedManager] block:self.user.n_id completeHandler:handlerBlock];
            }
            

            
        }];
        
        self.addToGroupButton =[UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.AddToGroup", nil) tapBlock:^{
            
            
            ComposeChooseGroupViewController *viewController = [[ComposeChooseGroupViewController alloc] initWithFrame:self.controller.view.bounds];
           
            [viewController setAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionAddUserToGroupBehavior class] filter:nil object:self.user]];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
        }];
        
        self.helpBotButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Bot.Help", nil) tapBlock:^{
            
            [self.controller.navigationViewController goBackWithAnimation:YES];
            
            [self.controller.navigationViewController.messagesViewController sendMessage:@"/help" forConversation:self.user.dialog];
            
        }];

        
        self.sharedMediaButton = [TMSharedMediaButton buttonWithText:NSLocalizedString(@"Profile.SharedMedia", nil) tapBlock:^{
            
            TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:self.controller.view.bounds];
            
            [viewController loadViewIfNeeded];
            
            [viewController setConversation:self.controller.conversation];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
            
           
            [viewController showAllMedia];
        }];
        
        
        self.filesMediaButton = [TMSharedMediaButton buttonWithText:NSLocalizedString(@"Profile.SharedMediaFiles", nil) tapBlock:^{
            
            TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:self.controller.view.bounds];
            
            [viewController loadViewIfNeeded];
            
            [viewController setConversation:self.controller.conversation];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
            
            [viewController showFiles];
        }];
        
        
        self.sharedLinksButton = [TMSharedMediaButton buttonWithText:NSLocalizedString(@"Conversation.Filter.SharedLinks", nil) tapBlock:^{
            
            TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:self.controller.view.bounds];
            
            [viewController loadViewIfNeeded];
            
            [viewController setConversation:self.controller.conversation];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
            
            [viewController showSharedLinks];
        }];
        
        
        
        
        self.sharedMediaButton.type = TMSharedMediaPhotoVideoType;
        self.filesMediaButton.type = TMSharedMediaDocumentsType;
        self.sharedLinksButton.type = TMSharedMediaSharedLinksType;
//        self.importContacts = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.ImportContacts", nil) tapBlock:^{
//           
//            [[NewContactsManager sharedManager] syncContacts:^{
//               
//               alert(NSLocalizedString(@"AccountSettings.ContactsSynced", nil), NSLocalizedString(@"Settings.ResyncDescription", nil));
//               
//           }];
//            
//        }];
//        
//        self.setProfilePhotoButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.UpdateProfilePhoto", nil) tapBlock:^{
//            
//            [self.controller.avatarImageView showUpdateChatPhotoBox];
//        }];
        
      //  [self.setProfilePhotoButton setFrameSize:NSMakeSize(offsetRight, 42)];
     //   [self addSubview:self.setProfilePhotoButton];
        
    //    [self.importContacts setFrameSize:NSMakeSize(offsetRight, 42)];
      //  [self addSubview:self.importContacts];
        
        
        [self.shareContactButton setFrameSize:NSMakeSize(offsetRight, 42)];
        [self addSubview:self.shareContactButton];
        
        [self.sharedMediaButton setFrameSize:NSMakeSize(offsetRight, 42)];
        [self addSubview:self.sharedMediaButton];
        
        [self.sharedLinksButton setFrameSize:NSMakeSize(offsetRight, 42)];
        [self addSubview:self.sharedLinksButton];
        
        [self.filesMediaButton setFrameSize:NSMakeSize(offsetRight, 42)];
        [self addSubview:self.filesMediaButton];
        
        [self.addToGroupButton setFrameSize:NSMakeSize(offsetRight, 42)];
        [self addSubview:self.addToGroupButton];

        [self.helpBotButton setFrameSize:NSMakeSize(offsetRight, 42)];
        [self addSubview:self.helpBotButton];

        
        [self.blockContact.textButton setTextColor:[NSColor redColor]];
        [self.blockContact setFrameSize:NSMakeSize(offsetRight, 42)];
        [self addSubview:self.blockContact];
        
        
        
        self.startSecretChatButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Conversation.StartSecretChat", nil) tapBlock:^{
            
            [weakSelf.startSecretChatButton setLocked:YES];
            [MessageSender startEncryptedChat:weakSelf.user callback:^ {
                [weakSelf.startSecretChatButton setLocked:NO];
            }];
        }];
        
        
        self.deleteSecretChatButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Conversation.DeleteSecretChat", nil) tapBlock:^{
            [weakSelf.deleteSecretChatButton setLocked:YES];
            [[Telegram rightViewController].messagesViewController deleteDialog:self.controller.conversation callback:^{
                [weakSelf.deleteSecretChatButton setLocked:NO];
            }];
        }];
        
        self.encryptedKeyButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.ShowEncryptedKey",nil) tapBlock:^{
            
            EncryptedKeyViewController *viewController = [[EncryptedKeyViewController alloc] initWithFrame:self.controller.view.bounds];
            
            [viewController showForChat:weakSelf.controller.conversation.encryptedChat];
            
            [self.controller.navigationViewController pushViewController:viewController animated:YES];
        }];
        
        
        self.imageForKey = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        
        
        
        [self.encryptedKeyButton setFrameSize:NSMakeSize(offsetRight, 42)];
        
        [self addSubview:self.encryptedKeyButton];
        
        self.setTTLButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.SetEncryptedTTL",nil) tapBlock:^{
            
            NSMenu *menu = [MessagesViewController destructMenu:^ {
              //  [self.setTTLButton setLocked:NO];
                [self buildTTLTitle];
            } click:^{
              //  [self.setTTLButton setLocked:YES];
            }];
            
            TMMenuPopover *menuPopover = [[TMMenuPopover alloc] initWithMenu:menu];
            
            [menuPopover showRelativeToRect:weakSelf.setTTLButton.bounds ofView:weakSelf.setTTLButton preferredEdge:CGRectMinYEdge];
            
        }];
        
        [self.setTTLButton setFrameSize:NSMakeSize(offsetRight, 42)];
        
        [self addSubview:self.setTTLButton];
        
        [self addSubview:self.deleteSecretChatButton];
        
        [self.deleteSecretChatButton.textButton setTextColor:[NSColor redColor]];
        [self.deleteSecretChatButton setFrameSize:NSMakeSize(offsetRight, 42)];
     
        
        [self.startSecretChatButton setFrameSize:NSMakeSize(offsetRight, 42)];
       // [self.startSecretChatButton.textButton setTextColor:NSColorFromRGB(0x61ad5e)];
        [self addSubview:self.startSecretChatButton];
        
        
        self.phoneView = [[UserInfoParamsView alloc] initWithFrame:NSMakeRect(100, 0, offsetRight, 61)];
        
        [self.phoneView setHeader:NSLocalizedString(@"Profile.MobilePhone", nil)];
        
        [self addSubview:self.phoneView];
        
        self.userNameView = [[UserInfoParamsView alloc] initWithFrame:NSMakeRect(100, 0, offsetRight, 61)];
        
        [self.userNameView setHeader:NSLocalizedString(@"Profile.username", nil)];
        
        [self addSubview:self.userNameView];
        
        self.botInfoView = [[UserInfoParamsView alloc] initWithFrame:NSMakeRect(100, 0, offsetRight, 61)];
        
        [self.botInfoView setHeader:NSLocalizedString(@"Profile.botInfo", nil)];
        
        [self addSubview:self.botInfoView];
        
        
        
         weakify();
        
        
        self.notificationView = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Notifications", nil) tapBlock:^{
            
            
            NSMenu *menu = [MessagesViewController notifications:^{
                
                [self buildNotificationsTitle];
                
            } conversation:self.controller.conversation click:^{
                
                
            }];;
            
            
            TMMenuPopover *menuPopover = [[TMMenuPopover alloc] initWithMenu:menu];

            [menuPopover showRelativeToRect:weakSelf.muteUntilTitle.bounds ofView:weakSelf.muteUntilTitle preferredEdge:CGRectMinYEdge];
            

        }];
        
        
        
        self.notificationsSwitcher = [[ITSwitch alloc] initWithFrame:NSMakeRect(0, 0, 36, 21)];
        
       
        
        [self.notificationsSwitcher setDidChangeHandler:^(BOOL isOn) {
            
            
            TL_conversation *dialog = [[DialogsManager sharedManager] findByUserId:strongSelf.user.n_id];
            
            BOOL isMute = dialog.isMute;
            if(isMute == isOn) {
                
                [strongSelf.notificationView setLocked:YES];
                
//                [dialog muteOrUnmute:^{
//                    
//                    [strongSelf.notificationView setLocked:NO];
//                    
//                    [strongSelf buildNotificationsTitle];
//                    
//                }];
            }
        
        }];
        
       // [self.notificationView setRightContainer:self.notificationsSwitcher];
        
        [self.encryptedKeyButton setRightContainerOffset:NSMakePoint(-8, 3)];
        [self.setTTLButton setRightContainerOffset:NSMakePoint(0, 2)];
        
        [self.notificationView setFrameSize:NSMakeSize(offsetRight, 42)];
        
        

        [self addSubview:self.notificationView];
        
        
        [self.profileProgressIndicator startAnimation:self];
        
        [Notification addObserver:self selector:@selector(userNameChangedNotification:) name:USER_UPDATE_NAME];
        
        
        self.sharedLinksButton.textButton.textColor = self.filesMediaButton.textButton.textColor = self.notificationView.textButton.textColor = self.sharedMediaButton.textButton.textColor = self.setTTLButton.textButton.textColor = self.encryptedKeyButton.textButton.textColor = DARK_BLACK;
        
        
        [Notification addObserver:self selector:@selector(didChangedBlockedUsers:) name:USER_BLOCK];
        
        
    }
    return self;
}



-(void)didChangedBlockedUsers:(NSNotification *)notification {
    TL_contactBlocked *user = [notification.userInfo objectForKey:KEY_USER];
    
    
    if(self.user.n_id != user.user_id)
        return;
    
    [self updateBlockedText];
    
}

-(void)updateBlockedText {
    [self.blockContact.textButton setStringValue:self.user.isBlocked ? NSLocalizedString(@"Profile.UnblockContact", nil) : NSLocalizedString(@"Profile.BlockContact", nil)];
    
    if(self.user.isBot)
    {
        [self.blockContact.textButton setStringValue:self.user.isBlocked ? NSLocalizedString(@"RestartBot", nil) : NSLocalizedString(@"StopBot", nil)];
    }
    
    [self.blockContact sizeToFit];
}


-(void)buildTTLTitle  {
    
    static NSTextAttachment *attach;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attach = [NSMutableAttributedString textAttachmentByImage:[image_selectPopup() imageWithInsets:NSEdgeInsetsMake(0, 10, 0, 0)]];
    });
    
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    NSString *str = [MessagesUtils shortTTL:[EncryptedParams findAndCreate:self.controller.conversation.peer.chat_id].ttl];
    
    [string appendString:str withColor:NSColorFromRGB(0xa1a1a1)];
    
    [string setFont:TGSystemLightFont(15) forRange:NSMakeRange(0, string.length)];
   
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
    [self.ttlTitle setAttributedStringValue:string];
    
    [self.ttlTitle sizeToFit];
    
    self.setTTLButton.rightContainer = self.ttlTitle;
    
}


-(void)buildNotificationsTitle  {
    
    static NSTextAttachment *attach;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attach = [NSMutableAttributedString textAttachmentByImage:[image_selectPopup() imageWithInsets:NSEdgeInsetsMake(0, 10, 0, 0)]];
    });
    
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    NSString *str = [MessagesUtils muteUntil:self.controller.conversation.notify_settings.mute_until];
    
    [string appendString:str withColor:NSColorFromRGB(0xa1a1a1)];
    
    [string setFont:TGSystemLightFont(15) forRange:NSMakeRange(0, string.length)];
    
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
    [self.muteUntilTitle setAttributedStringValue:string];
    
    [self.muteUntilTitle sizeToFit];
    
    self.notificationView.rightContainer = self.muteUntilTitle;
    
}



- (void)userNameChangedNotification:(NSNotification *)notify {
    TLUser *user = [notify.userInfo objectForKey:KEY_USER];
    if(user.n_id == self.user.n_id) {
        [self setUser:user];
    }
}

- (void)buildPage {
    float offset = self.bounds.size.height - 145;
    
    [self.phoneView setHidden:self.user.isBot];
    
    
    [self.botInfoView setHidden:!self.user.isBot || self.botInfoView.string.length == 0];
    
    
    if(self.botInfoView.isHidden)
    {
        offset-=42;
    } else {
        offset-=NSHeight(self.botInfoView.frame);
    }
    
    [self.botInfoView setFrameOrigin:NSMakePoint(100, offset)];
    
    [self.phoneView setFrameOrigin:NSMakePoint(100, offset)];
    
    if(self.botInfoView.isHidden && self.user.isBot) {
        offset+=62;
    }
    
    
   
    [self.userNameView setHidden:self.user.username.length == 0];
    
    if(!self.userNameView.isHidden) {
        offset-=62;
        
        [self.userNameView setFrameOrigin:NSMakePoint(100, offset)];
    }
    
    [self.addToGroupButton setHidden:YES];
   
    if(!self.controller.isSecretProfile) {
        offset -= 62;
        [self.sendMessageButton setFrameOrigin:NSMakePoint(100, offset)];
        
        [self.sendMessageButton setHidden:NO];
        
        
        [self.addToGroupButton setHidden:!self.user.isBot || (self.user.flags & TGBOTGROUPBLOCKED)];
        if(self.user.isBot && !self.addToGroupButton.isHidden) {
            offset-=NSHeight(self.sendMessageButton.frame);
            
            [self.addToGroupButton setFrameOrigin:NSMakePoint(100, offset)];
        }
        
        
        [self.setProfilePhotoButton setHidden:self.user.type != TLUserTypeSelf];
        [self.importContacts setHidden:self.user.type != TLUserTypeSelf];
        
        
        if(self.user.type == TLUserTypeContact || self.user.type == TLUserTypeSelf || self.user.isBot) {
            
            [self.shareContactButton.textButton setStringValue:NSLocalizedString(self.user.isBot ? @"Profile.ShareBot" : @"Profile.ShareContact", nil)];
            [self.shareContactButton sizeToFit];
            
            offset -= self.shareContactButton.bounds.size.height;
            [self.shareContactButton setFrameOrigin:NSMakePoint(100, offset)];
            [self.shareContactButton setHidden:NO];
        } else {
            [self.shareContactButton setHidden:YES];
        }
        
        if(!self.helpBotButton.isHidden) {
            
            offset-=NSHeight(self.helpBotButton.frame);
            [self.helpBotButton setFrameOrigin:NSMakePoint(100, offset)];
        }
        
    } else {
        [self.sendMessageButton setHidden:YES];
        [self.blockContact setHidden:YES];
        [self.shareContactButton setHidden:YES];
        [self.setProfilePhotoButton setHidden:YES];
        [self.importContacts setHidden:YES];
    }

    if(self.user.type != TLUserTypeSelf && !self.controller.isSecretProfile && ![self.user isBot]) {
        
         offset -= self.shareContactButton.bounds.size.height;
        
        [self.startSecretChatButton setHidden:self.controller.isSecretProfile];
        [self.startSecretChatButton setFrameOrigin:NSMakePoint(100, offset)];
    } else {
        [self.startSecretChatButton setHidden:YES];
    }
    
    

    if(self.user.type != TLUserTypeSelf) {
        offset-=62;
        
        [self.sharedMediaButton setFrameOrigin:NSMakePoint(100, offset)];
        
        [self.sharedMediaButton setHidden:NO];
        
        offset-=NSHeight(self.filesMediaButton.frame);
        
        [self.filesMediaButton setFrameOrigin:NSMakePoint(100, offset)];
        
        [self.filesMediaButton setHidden:NO];
        
        
        [self.sharedLinksButton setHidden:self.controller.isSecretProfile];
        
        if(!self.controller.isSecretProfile) {
            offset-=NSHeight(self.sharedLinksButton.frame);
            
            [self.sharedLinksButton setFrameOrigin:NSMakePoint(100, offset)];
            
            [self.sharedLinksButton setHidden:NO];
        }
        
    } else {
        [self.sharedMediaButton setHidden:YES];
        [self.filesMediaButton setHidden:YES];
        [self.sharedLinksButton setHidden:YES];
    }
    
    
    
    
    [self.encryptedKeyButton setHidden:!self.controller.isSecretProfile];
    [self.setTTLButton setHidden:!self.controller.isSecretProfile];
    [self.deleteSecretChatButton setHidden:!self.controller.isSecretProfile];
    
    if(self.controller.isSecretProfile) {
        
        offset-=self.filesMediaButton.frame.size.height;
        [self.encryptedKeyButton setFrameOrigin:NSMakePoint(100, offset )];
        
        offset-=self.encryptedKeyButton.bounds.size.height;
        
        [self.setTTLButton setFrameOrigin:NSMakePoint(100, offset )];

        [self.encryptedKeyButton setRightContainer:self.imageForKey];
        
       
        
        offset-=62;
        
        [self.deleteSecretChatButton setFrameOrigin:NSMakePoint(100, offset)];
        
    }
    
    
    self.imageForKey.image = [self createEncryptedImage];
    
    [self buildTTLTitle];
    
    offset-=self.notificationView.frame.size.height;
    
    [self.notificationView setFrameOrigin:NSMakePoint(100, offset)];
    
    
    
    if(!self.controller.isSecretProfile) {
        
        offset-=62;
        
        if(self.user.type != TLUserTypeSelf) {
            [self.blockContact setFrameOrigin:NSMakePoint(100, offset)];
            [self.blockContact setHidden:NO];
        } else {
            [self.blockContact setHidden:YES];
        }
        
    }
    
 
}

- (NSImage *)createEncryptedImage  {
    EncryptedParams *params = [EncryptedParams findAndCreate:self.controller.conversation.encryptedChat.n_id];
    
    NSData *hashData = [Crypto sha1:[params lastKey]];

    
    return TGIdenticonImage(hashData,NSMakeSize(20, 20));
}

- (BOOL) isFlipped {
    return NO;
}

- (void)setState:(UserInfoViewControllerType)state animation:(BOOL)animation {
    
}

#define DEFAULT_FONT TGSystemFont(13)
#define DEFAULT_COLOR NSColorFromRGB(0xa1a1a1)

- (void)setUser:(TLUser *)user {
    self->_user = user;
    
    [self.userNameView setString:[NSString stringWithFormat:@"@%@",user.username]];
    
    [self.sharedMediaButton setConversation:self.controller.conversation];
    
    [self.filesMediaButton setConversation:self.controller.conversation];
    
    [self.sharedLinksButton setConversation:self.controller.conversation];
    
    [self.helpBotButton setHidden:YES];
    
    NSSize size;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode: NSLineBreakByTruncatingTail];
    
    NSAttributedString *userNameAttributedString = [[NSAttributedString alloc] initWithString:user.fullName ? user.fullName : NSLocalizedString(@"User.Deleted", nil) attributes:@{NSForegroundColorAttributeName: NSColorFromRGB(0x333333), NSFontAttributeName: TGSystemFont(18), NSParagraphStyleAttributeName: paragraphStyle}];
    size = [userNameAttributedString sizeForWidth:FLT_MAX height:FLT_MAX];
    
    [[self.nameTextView textStorage] setAttributedString:userNameAttributedString];
    [self.nameTextView setFrameSize:NSMakeSize(self.bounds.size.width - 204 - 55, size.height)];
    [self.nameTextView setFrameOrigin:NSMakePoint(185, self.bounds.size.height - 51 - self.nameTextView.bounds.size.height)];
    [self.nameTextView setTextContainerInset:NSMakeSize(-3, 0)];
    
    [self.statusTextField setUser:self.user];
    [self.phoneView setString:self.user.phoneWithFormat ? self.user.phoneWithFormat : NSLocalizedString(@"User.Hidden", nil)];
    
    if(user.isBot) {
        [[FullUsersManager sharedManager] loadUserFull:user callback:^(TL_userFull *userFull) {
            
            int h = [_botInfoView setString:userFull.bot_info.share_text];
            
            [_botInfoView setFrameSize:NSMakeSize(NSWidth(_botInfoView.frame), h+30)];
            
            __block BOOL canHelp = NO;
            
            [userFull.bot_info.commands enumerateObjectsUsingBlock:^(TL_botCommand *obj, NSUInteger idx, BOOL *stop) {
                if([obj.command isEqualToString:@"help"]) {
                    canHelp = YES;
                    *stop = YES;
                }
            }];
            
            [_helpBotButton setHidden:!canHelp];
            
            [self buildPage];
            
        }];
    }
    
    
    
    
    if(self.user.type != TLUserTypeSelf) {
        [self.notificationView setHidden:self.controller.isSecretProfile];
        
        TL_conversation *dialog = [[DialogsManager sharedManager] findByUserId:user.n_id];
        
        BOOL isMute =  dialog.isMute;
        
        [self buildNotificationsTitle];
        
      //  [self.notificationsSwitcher setOn:!isMute animated:YES];
        
    } else {
        [self.notificationView setHidden:YES];
    }
    
    [self buildPage];
    
    [self updateBlockedText];
    
}

- (void)TMStatusTextFieldDidChanged:(TMStatusTextField *)textField {
    [self.statusTextField sizeToFit];
    [self.statusTextField setFrameOrigin:NSMakePoint(self.nameTextView.frame.origin.x, self.nameTextView.frame.origin.y - self.statusTextField.bounds.size.height - 3 )];
}

+ (NSDictionary *)attributsForInfoPlaceholderString {
    static NSDictionary *info = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        info = @{NSForegroundColorAttributeName: BLUE_UI_COLOR, NSFontAttributeName: DEFAULT_FONT};
    });
    return info;
}

@end
