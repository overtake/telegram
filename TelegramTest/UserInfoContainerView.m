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
#import "UserInfoPhoneView.h"
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
@interface UserInfoContainerView()
@property (nonatomic, strong) TMAvatarImageView *avatarImageView;
@property (nonatomic, strong) NSTextView *nameTextView;

@property (nonatomic, strong) TMStatusTextField *statusTextField;

@property (nonatomic, strong) UserInfoShortButtonView *sendMessageButton;
@property (nonatomic, strong) UserInfoShortButtonView *shareContactButton;
@property (nonatomic, strong) TMSharedMediaButton *sharedMediaButton;
@property (nonatomic, strong) UserInfoShortButtonView *startSecretChatButton;
@property (nonatomic, strong) UserInfoShortButtonView *setProfilePhotoButton;
@property (nonatomic, strong) UserInfoShortButtonView *importContacts;

@property (nonatomic, strong) UserInfoShortButtonView *encryptedKeyButton;
@property (nonatomic, strong) UserInfoShortButtonView *setTTLButton;
@property (nonatomic, strong) UserInfoShortButtonView *deleteSecretChatButton;

@property (nonatomic, strong) UserInfoPhoneView *phoneView;

@property (nonatomic, strong) ChatInfoNotificationView *notificationView;

@property (nonatomic, strong) TMView *nameNormalView;
@property (nonatomic, strong) TMView *nameEditView;

@property (nonatomic, strong) NSImageView *imageForKey;

@property (nonatomic,strong) TMTextField *ttlTitle;
@property (nonatomic,strong) TMTextField *sharedTitle;

@property (nonatomic, strong) NSProgressIndicator *profileProgressIndicator;

@end

@implementation UserInfoContainerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.profileProgressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(40, 40, 30, 30)];
        
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
      
        float offsetRight = self.bounds.size.width - 286;
        
        __block UserInfoContainerView *weakSelf = self;
    
        self.sendMessageButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.SendMessage", nil) tapBlock:^{
            [[Telegram sharedInstance] showMessagesWidthUser:weakSelf.user sender:weakSelf];
        }];
        [self.sendMessageButton setFrameSize:NSMakeSize(offsetRight, 0)];
        [self addSubview:self.sendMessageButton];
        

        self.shareContactButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.ShareContact", nil) tapBlock:^{
            [[Telegram rightViewController] showShareContactModalView:weakSelf.user];
        }];
        
        self.sharedMediaButton = [TMSharedMediaButton buttonWithText:NSLocalizedString(@"Profile.SharedMedia", nil) tapBlock:^{
            [[Telegram rightViewController].messagesViewController setHistoryFilter:[PhotoHistoryFilter class] force:NO];
           [[Telegram rightViewController] showByDialog:weakSelf.controller.conversation withJump:0 historyFilter:[PhotoHistoryFilter class] sender:self];
        }];
        
        self.importContacts = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.ImportContacts", nil) tapBlock:^{
           
            [[NewContactsManager sharedManager] syncContacts:^{
               
               alert(NSLocalizedString(@"AccountSettings.ContactsSynced", nil), NSLocalizedString(@"Settings.ResyncDescription", nil));
               
           }];
            
        }];
        
        self.setProfilePhotoButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.UpdateProfilePhoto", nil) tapBlock:^{
            
            [self.controller.avatarImageView showUpdateChatPhotoBox];
        }];
        
        [self.setProfilePhotoButton setFrameSize:NSMakeSize(offsetRight, 0)];
        [self addSubview:self.setProfilePhotoButton];
        
        [self.importContacts setFrameSize:NSMakeSize(offsetRight, 0)];
        [self addSubview:self.importContacts];
        
        
        [self.shareContactButton setFrameSize:NSMakeSize(offsetRight, 0)];
        [self addSubview:self.shareContactButton];
        
        [self.sharedMediaButton setFrameSize:NSMakeSize(offsetRight, 0)];
        [self addSubview:self.sharedMediaButton];
        
        
        
        self.startSecretChatButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Conversation.StartSecretChat", nil) tapBlock:^{
            
            [weakSelf.startSecretChatButton setLocked:YES];
            [MessageSender startEncryptedChat:weakSelf.user callback:^ {
                [weakSelf.startSecretChatButton setLocked:NO];
            }];
        }];
        
        
        self.deleteSecretChatButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Conversation.DeleteSecretChat", nil) tapBlock:^{
            [weakSelf.deleteSecretChatButton setLocked:YES];
            [[Telegram rightViewController].messagesViewController deleteDialog:[Telegram rightViewController].messagesViewController.dialog callback:^{
                [weakSelf.deleteSecretChatButton setLocked:NO];
            }];
        }];
        
        self.encryptedKeyButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.ShowEncryptedKey",nil) tapBlock:^{
            [[Telegram rightViewController] showEncryptedKeyWindow:weakSelf.controller.conversation.encryptedChat];
           // [EncryptedKeyWindow showForChat:weakSelf.controller.conversation.encryptedChat];
        }];
        
        
        self.imageForKey = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        
        
        
        [self.encryptedKeyButton setFrameSize:NSMakeSize(offsetRight, 0)];
        
        [self addSubview:self.encryptedKeyButton];
        
        self.setTTLButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.SetEncryptedTTL",nil) tapBlock:^{
            
            NSMenu *menu = [MessagesViewController destructMenu:^ {
                [self.setTTLButton setLocked:NO];
                [self buildTTLTitle];
            } click:^{
                [self.setTTLButton setLocked:YES];
            }];
            
            [menu popUpForView:weakSelf.setTTLButton withType:PopUpAlignTypeRight];
        }];
        
        [self.setTTLButton setFrameSize:NSMakeSize(offsetRight, 0)];
        
        [self addSubview:self.setTTLButton];
        
        [self addSubview:self.deleteSecretChatButton];
        
        [self.deleteSecretChatButton.textButton setTextColor:[NSColor redColor]];
        [self.deleteSecretChatButton setFrameSize:NSMakeSize(offsetRight, 0)];
        [self.startSecretChatButton setFrameSize:NSMakeSize(offsetRight, 0)];
        [self.startSecretChatButton.textButton setTextColor:NSColorFromRGB(0x61ad5e)];
        [self addSubview:self.startSecretChatButton];
        
        offsetRight = self.bounds.size.width - 60;
        
        self.phoneView = [[UserInfoPhoneView alloc] initWithFrame:NSMakeRect(30, 0, offsetRight, 66)];
        [self addSubview:self.phoneView];
        
        
        self.notificationView = [[ChatInfoNotificationView alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width - 60, 40)];
        [self.notificationView setNoBorder:YES];
        
        [self.encryptedKeyButton setRightContainerOffset:NSMakePoint(-8, 3)];
        [self.setTTLButton setRightContainerOffset:NSMakePoint(0, 2)];
        
        
        weakify();
        [self.notificationView.switchControl setDidChangeHandler:^(BOOL change) {
            TL_conversation *dialog = [[DialogsManager sharedManager] findByUserId:strongSelf.user.n_id];
            
            BOOL isMute = dialog.isMute;
            if(isMute == change) {
                [dialog muteOrUnmute:nil];
            }
        }];
        [self addSubview:self.notificationView];
        
        
         [self.profileProgressIndicator startAnimation:self];
        
        [Notification addObserver:self selector:@selector(userNameChangedNotification:) name:USER_UPDATE_NAME];
    }
    return self;
}




-(void)buildTTLTitle  {
    
    static NSTextAttachment *attach;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attach = [NSMutableAttributedString textAttachmentByImage:[image_selectPopup() imageWithInsets:NSEdgeInsetsMake(0, 3, 0, 5)]];
    });
    
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    NSString *str = [MessagesUtils shortTTL:[SelfDestructionController lastTTL:self.controller.conversation.encryptedChat]];
    
    [string appendString:str withColor:NSColorFromRGB(0xa1a1a1)];
    
    [string setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:15] forRange:NSMakeRange(0, string.length)];
   
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
    [self.ttlTitle setAttributedStringValue:string];
    
    [self.ttlTitle sizeToFit];
    
    self.setTTLButton.rightContainer = self.ttlTitle;
    
}



- (void)userNameChangedNotification:(NSNotification *)notify {
    TGUser *user = [notify.userInfo objectForKey:KEY_USER];
    if(user.n_id == self.user.n_id) {
        [self setUser:user];
    }
}

- (void)buildPage {
    float offset = self.bounds.size.height - 104;
    

    //if(self.user.type != TGUserTypeSelf) {
        offset -= self.sendMessageButton.bounds.size.height;
        [self.sendMessageButton setFrameOrigin:NSMakePoint(170, offset)];
        
        [self.sendMessageButton setHidden:NO];
  //  } else {
     //   [self.sendMessageButton setHidden:YES];
  //  }
    
   
    
    [self.setProfilePhotoButton setHidden:self.user.type != TGUserTypeSelf];
    [self.importContacts setHidden:self.user.type != TGUserTypeSelf];
    
    if(self.user.type == TGUserTypeContact || self.user.type == TGUserTypeSelf) {
        offset -= self.shareContactButton.bounds.size.height;
        [self.shareContactButton setFrameOrigin:NSMakePoint(170, offset)];
        [self.shareContactButton setHidden:NO];
    } else {
        [self.shareContactButton setHidden:YES];
    }
    
    if(self.user.type != TGUserTypeSelf) {
        offset-= self.sharedMediaButton.frame.size.height+30;
        
        [self.sharedMediaButton setFrameOrigin:NSMakePoint(170, offset)];
        
        [self.sharedMediaButton setHidden:NO];
    } else {
        [self.sharedMediaButton setHidden:YES];
    }
    
    offset -= 60;
    
    if(self.user.type == TGUserTypeSelf) {
        offset-=self.setProfilePhotoButton.bounds.size.height;
        [self.setProfilePhotoButton setFrameOrigin:NSMakePoint(170, offset)];
        
        offset-=self.importContacts.bounds.size.height;
        [self.importContacts setFrameOrigin:NSMakePoint(170, offset)];
    }
    
    
    if(self.user.type != TGUserTypeSelf) {
        if(!self.controller.isSecretProfile) {
            offset-=12;
        }
        [self.startSecretChatButton setHidden:self.controller.isSecretProfile];
        [self.startSecretChatButton setFrameOrigin:NSMakePoint(170, offset)];
    } else {
        [self.startSecretChatButton setHidden:YES];
    }
    
    
    [self.encryptedKeyButton setHidden:!self.controller.isSecretProfile];
    [self.setTTLButton setHidden:!self.controller.isSecretProfile];
    [self.deleteSecretChatButton setHidden:!self.controller.isSecretProfile];
    
    if(self.controller.isSecretProfile) {
        offset-=12;
        [self.encryptedKeyButton setFrameOrigin:NSMakePoint(170, offset )];
        
        offset-=self.encryptedKeyButton.bounds.size.height;
        
        [self.setTTLButton setFrameOrigin:NSMakePoint(170, offset )];

        [self.encryptedKeyButton setRightContainer:self.imageForKey];
        
       
        
        offset-=self.deleteSecretChatButton.frame.size.height+30;
        
        [self.deleteSecretChatButton setFrameOrigin:NSMakePoint(170, offset)];
        
    }
    
    
    self.imageForKey.image = [self createEncryptedImage];
    
    [self buildTTLTitle];
    
    offset -= self.phoneView.bounds.size.height;
    [self.phoneView setFrameOrigin:NSMakePoint(30, offset)];
    
    
    [self.notificationView setFrameOrigin:NSMakePoint(30, offset - 55)];
    
//    offset-=self.notificationView.frame.size.height;
    
    
    
    
//    self.navigationView;

}

- (NSImage *)createEncryptedImage  {
    EncryptedParams *params = [EncryptedParams findAndCreate:self.controller.conversation.encryptedChat.n_id];
    
    NSData *hashData = [Crypto sha1:params.encrypt_key];

    
    return TGIdenticonImage(hashData,NSMakeSize(20, 20));
}

- (BOOL) isFlipped {
    return NO;
}

- (void)setState:(UserInfoViewControllerType)state animation:(BOOL)animation {
    
}

#define DEFAULT_FONT [NSFont fontWithName:@"HelveticaNeue-Medium" size:13]
#define DEFAULT_COLOR NSColorFromRGB(0xa1a1a1)

- (void)setUser:(TGUser *)user {
    self->_user = user;
    
    [self.sharedMediaButton setConversation:self.controller.conversation];
    
    
    [self.avatarImageView setUser:user];
    NSSize size;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode: NSLineBreakByTruncatingTail];
    
    NSAttributedString *userNameAttributedString = [[NSAttributedString alloc] initWithString:user.fullName ? user.fullName : NSLocalizedString(@"User.Deleted", nil) attributes:@{NSForegroundColorAttributeName: NSColorFromRGB(0x333333), NSFontAttributeName: [NSFont fontWithName:@"Helvetica" size:22], NSParagraphStyleAttributeName: paragraphStyle}];
    size = [userNameAttributedString sizeForWidth:FLT_MAX height:FLT_MAX];
    
    [[self.nameTextView textStorage] setAttributedString:userNameAttributedString];
    [self.nameTextView setFrameSize:NSMakeSize(self.bounds.size.width - 204 - 55, size.height)];
    [self.nameTextView setFrameOrigin:NSMakePoint(175, self.bounds.size.height - 44 - self.nameTextView.bounds.size.height)];
    
    [self.statusTextField setUser:self.user];
    [self.phoneView setPhoneNumber:self.user.phoneWithFormat];
    
    
    if(self.user.type != TGUserTypeSelf) {
        [self.notificationView setHidden:self.controller.isSecretProfile];
        weakify();
        
        TL_conversation *dialog = [[DialogsManager sharedManager] findByUserId:user.n_id];
        
        BOOL isMute =  dialog.isMute;
        [strongSelf.notificationView.switchControl setOn:!isMute animated:YES];
        
    } else {
        [self.notificationView setHidden:YES];
    }
    
    [self buildPage];
}

- (void)TMStatusTextFieldDidChanged:(TMStatusTextField *)textField {
    [self.statusTextField sizeToFit];
    [self.statusTextField setFrameOrigin:NSMakePoint(self.nameTextView.frame.origin.x + 3, self.nameTextView.frame.origin.y - self.statusTextField.bounds.size.height - 4)];
}

+ (NSDictionary *)attributsForInfoPlaceholderString {
    static NSDictionary *info = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        info = @{NSForegroundColorAttributeName: DEFAULT_COLOR, NSFontAttributeName: DEFAULT_FONT};
    });
    return info;
}

@end
