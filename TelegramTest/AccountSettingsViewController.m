//
//  AccountSettingsViewController.m
//  Telegram
//
//  Created by keepcoder on 26.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "ChatAvatarImageView.h"
#import "TMPreviewUserPicture.h"
#import "TMMediaUserPictureController.h"
#import "UserInfoShortButtonView.h"
#import "UserInfoShortTextEditView.h"
#import "UserCardViewController.h"
@interface ExView : TMView

@end

@implementation ExView

-(void)drawRect:(NSRect)dirtyRect {
    [NSColorFromRGB(0xffffff) set];
    
    NSRectFill(NSMakeRect(0, 0, NSWidth(self.bounds) - DIALOG_BORDER_WIDTH, NSHeight(self.bounds)));
}

@end


@interface FlippedView : TMView

@end

@implementation FlippedView

-(BOOL)isFlipped {
    return YES;
}

@end

@interface AccountSettingsViewController ()
@property (nonatomic,strong) ChatAvatarImageView *avatarImageView;
@property (nonatomic,strong) TMNameTextField *nameTextField;
@property (nonatomic,strong) TMTextField *numberTextField;

@property (nonatomic,strong) UserInfoShortButtonView *updatePhotoButton;
@property (nonatomic,strong) UserInfoShortButtonView *updateProfileButton;

@property (nonatomic,strong) UserInfoShortButtonView *blockedUsers;
@property (nonatomic,strong) UserInfoShortButtonView *chatSettings;
@property (nonatomic,strong) UserInfoShortButtonView *securitySettings;
@property (nonatomic,strong) UserInfoShortTextEditView *firstNameView;
@property (nonatomic,strong) UserInfoShortTextEditView *lastNameView;


@property (nonatomic,strong) UserInfoShortButtonView *exportCard;
@property (nonatomic,strong) UserInfoShortButtonView *importCard;



@property (nonatomic,strong) UserCardViewController *userCardViewController;


@property (nonatomic,strong) NSView *defaultView;
@property (nonatomic,strong) NSView *editView;

@property (nonatomic,strong) NSScrollView *scrollView;

@property (nonatomic,strong) NSView *containerView;

typedef enum {
    AccountSettingsStateNormal,
    AccountSettingsStateEditable
} AccountSettingsState;

@property (nonatomic,assign) AccountSettingsState state;

@end

@implementation AccountSettingsViewController

-(void)loadView {
    
    
    self.view = [[ExView alloc] initWithFrame:self.frameInit];
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frameInit) - DIALOG_BORDER_WIDTH, NSHeight(self.frameInit))];
    
    self.scrollView.autoresizesSubviews = YES;
    self.scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.scrollView setDrawsBackground:YES];
    
    self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    self.userCardViewController = [[UserCardViewController alloc] initWithFrame:NSMakeRect(0, 0, 350, 150)];
    
    
    FlippedView *container = [[FlippedView alloc] initWithFrame:self.view.bounds];
    
    
    
    [container setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    
    [self.view addSubview:self.scrollView];
    
    self.avatarImageView = [ChatAvatarImageView standartUserInfoAvatar];
    [self.avatarImageView setCenterByView:self.view];
    
    int currentY = 30;
    
    [self.avatarImageView setFrameOrigin:NSMakePoint(NSMinX(self.avatarImageView.frame), currentY)];
    [container addSubview:self.avatarImageView];
    
    currentY+=140;
    
    self.nameTextField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(0, currentY, NSWidth(self.view.frame) , 40)];
    
    [self.nameTextField setSelector:@selector(titleForMessage)];
    
    [self.nameTextField setUser:[UsersManager currentUser]];
    
    [container addSubview:self.nameTextField];
    
 //   [container setBackgroundColor:[NSColor blueColor]];
    
    
//    
//    self.numberTextField = [TMTextField defaultTextField];
//    
//    currentY+=30;
//    
//    [self.numberTextField setFrame:NSMakeRect(0, currentY, NSWidth(self.view.frame) , 40)];
//    
//    
//    NSMutableAttributedString *number = [[NSMutableAttributedString alloc] init];
//    
//    [number appendString:[UsersManager currentUser].phoneWithFormat withColor:DARK_GRAY];
//    
//    [number setAlignment:NSCenterTextAlignment range:number.range];
//    
//    [number setFont:[NSFont fontWithName:@"HelveticaNeue" size:14] forRange:number.range];
//    
//    [self.numberTextField setAttributedStringValue:number];
//    
//    [container addSubview:self.numberTextField];
//    
    
    self.avatarImageView.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
    
    
    weakify();
    [_avatarImageView setTapBlock:^{
        PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:0 media:[UsersManager currentUser].photo.photo_big peer_id:[UsersManager currentUserId]];
        
        previewObject.reservedObject = strongSelf.avatarImageView;
        
        TMPreviewUserPicture *picture = [[TMPreviewUserPicture alloc] initWithItem:previewObject];
        if(picture) {
            [[TMMediaUserPictureController controller] prepare:[UsersManager currentUser] completionHandler:^{
                 [[TMMediaUserPictureController controller] show:picture];
            }];
        }
        
    }];
    
    [_avatarImageView setSourceType:ChatAvatarSourceUser];
    
    [self.avatarImageView setUser:[UsersManager currentUser]];
    
    
    currentY+=40;
    
    self.defaultView = [self defaultContainerView];
    
    
    
    
    [self.defaultView setFrameOrigin:NSMakePoint(0, currentY)];
    
    [container addSubview:self.defaultView];
    
    
    self.editView = [self editContainerView];

    
    
    [self.editView setFrameOrigin:NSMakePoint(0, currentY-52)];
    
    self.editView.layer.opacity = 0;
    [self.editView setHidden:YES];
    
    [container addSubview:self.editView];
  
    self.containerView = container;
    
    self.scrollView.documentView = self.containerView;
    
}

-(void)setState:(AccountSettingsState)state animated:(BOOL)animated {
    self->_state = state;
    
    
    
    float duration = 0.2;
    
    int defaultY = state == AccountSettingsStateNormal ? 210 : 180 + NSHeight(self.editView.frame);
    
    POPBasicAnimation *move = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    move.toValue = @(defaultY);
    move.duration = duration;
    
    [move setCompletionBlock:^(POPAnimation *anim, BOOL result) {
        [self.defaultView setFrameOrigin:NSMakePoint(0, defaultY)];
    }];
    
    
    [self.defaultView.layer pop_addAnimation:move forKey:@"slide"];
    
    float opacity = state == AccountSettingsStateNormal ? 0 : 1;
    
    
    if(state == AccountSettingsStateEditable) {
          [self.editView setHidden:NO];
    }
    
    POPBasicAnimation *fadeEdit = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    fadeEdit.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    fadeEdit.toValue = @(opacity);
    fadeEdit.duration = duration;
    
    [fadeEdit setCompletionBlock:^(POPAnimation *anim, BOOL result) {
        [self.editView setHidden:state == AccountSettingsStateNormal ? YES : NO];
        [self.firstNameView.textView becomeFirstResponder];
        [self.firstNameView.textView setSelectionRange:NSMakeRange(self.firstNameView.textView.stringValue.length, 0)];
    }];
    
    
    [self.editView.layer pop_addAnimation:fadeEdit forKey:@"opacity"];
    
    
    
    POPBasicAnimation *nameFade = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    nameFade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    nameFade.toValue = @(state == AccountSettingsStateNormal ? 1 : 0);
    nameFade.duration = duration;
    
    [nameFade setCompletionBlock:^(POPAnimation *anim, BOOL result) {
       // [self.nameTextField setHidden:state == AccountSettingsStateNormal ? NO : YES];
    }];
    
    
    [self.nameTextField.layer pop_addAnimation:nameFade forKey:@"opacity"];
    
    
    [self.updateProfileButton.textButton setStringValue:state == AccountSettingsStateNormal ? NSLocalizedString(@"Account.EditProfile",nil) : NSLocalizedString(@"Profile.Done",nil)];
    
    [self.firstNameView.textView setStringValue:[UsersManager currentUser].first_name];
    [self.lastNameView.textView setStringValue:[UsersManager currentUser].last_name];
    
    
    int height = defaultY + NSHeight(self.defaultView.frame);
    
    [self.scrollView.documentView setFrameSize:NSMakeSize(NSWidth(self.scrollView.frame), height)];
    
}



-(NSView *)defaultContainerView {
    
    int currentY = 0;
    
    
    FlippedView *container = [[FlippedView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frameInit), 500)];
    
    container.wantsLayer = YES;
    
   // container.backgroundColor = [NSColor redColor];
    
    self.updateProfileButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.EditProfile",nil) tapBlock:^{
        
        [self enterClick];
        
    }];
    
   
    
    [self.updateProfileButton setFrame:NSMakeRect(20, currentY, NSWidth(self.view.frame) - 30, 60)];
    
    //   [self.updateProfileButton.textButton setAlignment:NSCenterTextAlignment];
    [self.updateProfileButton.textButton setFrameSize:NSMakeSize(NSWidth(self.updateProfileButton.frame), NSHeight(self.updateProfileButton.textButton.frame))];
    [self.updateProfileButton.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.updateProfileButton.textButton.frame))];
    
    self.updateProfileButton.autoresizingMask = self.updateProfileButton.textButton.autoresizingMask = self.numberTextField.autoresizingMask = self.nameTextField.autoresizingMask = NSViewWidthSizable;
    
    [container addSubview:self.updateProfileButton];

    
     currentY+=42;
    
    self.updatePhotoButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.UpdateProfilePhoto",nil) tapBlock:^{
        [self.avatarImageView showUpdateChatPhotoBox];
    }];
    
   
    
    
    [self.updatePhotoButton setFrame:NSMakeRect(20, currentY, NSWidth(self.view.frame) - 30, 60)];
    
    // [self.updatePhotoButton.textButton setAlignment:NSCenterTextAlignment];
    [self.updatePhotoButton.textButton setFrameSize:NSMakeSize(NSWidth(self.updatePhotoButton.frame), NSHeight(self.updatePhotoButton.textButton.frame))];
    [self.updatePhotoButton.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.updatePhotoButton.textButton.frame))];
    
    
    [container addSubview:self.updatePhotoButton];
    
     currentY+=42;
    
    
    
    self.exportCard = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.ExportCard",nil) tapBlock:^{
        
        NSRect rect = self.exportCard.bounds;
        
        rect.origin.y-=10;

        
        [self.userCardViewController showWithType:UserCardViewTypeExport relativeRect:rect ofView:self.exportCard preferredEdge:CGRectMinYEdge];
    
    
    }];
    
    [self.exportCard setFrame:NSMakeRect(20, currentY, NSWidth(self.view.frame) - 30, 60)];
    
    [self.exportCard.textButton setFrameSize:NSMakeSize(NSWidth(self.exportCard.frame), NSHeight(self.exportCard.textButton.frame))];
    [self.exportCard.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.exportCard.textButton.frame))];
    
    
    [container addSubview:self.exportCard];
    
    
//    currentY+=42;
//    
//    
//    self.importCard = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.ImportCard",nil) tapBlock:^{
//        
//    }];
//    
//    container.wantsLayer = YES;
//    
//    
//    
//    [self.importCard setFrame:NSMakeRect(20, currentY, NSWidth(self.view.frame) - 30, 60)];
//    
//    [self.importCard.textButton setFrameSize:NSMakeSize(NSWidth(self.importCard.frame), NSHeight(self.importCard.textButton.frame))];
//    [self.importCard.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.importCard.textButton.frame))];
//    
//    
//    [container addSubview:self.importCard];
    
    
    self.blockedUsers = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.BlockedUsers",nil) tapBlock:^{
        [[Telegram rightViewController] showBlockedUsers];
         //[[Telegram settingsWindowController] showWindowWithAction:SettingsWindowActionBlockedUsers];
    }];
   
    
    currentY+=80;
    
    [self.blockedUsers setFrame:NSMakeRect(20, currentY, NSWidth(self.view.frame) - 30, 60)];
    
    [self.blockedUsers.textButton setFrameSize:NSMakeSize(NSWidth(self.blockedUsers.frame), NSHeight(self.blockedUsers.textButton.frame))];
    [self.blockedUsers.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.blockedUsers.textButton.frame))];
    
    
    [container addSubview:self.blockedUsers];
    
    
    
    self.chatSettings = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.ChatSettings",nil) tapBlock:^{
        [[Telegram rightViewController] showGeneralSettings];
        
    }];
    
    currentY+=42;
    
    [self.chatSettings setFrame:NSMakeRect(20, currentY, NSWidth(self.view.frame) - 30, 60)];
    
    [self.chatSettings.textButton setFrameSize:NSMakeSize(NSWidth(self.chatSettings.frame), NSHeight(self.chatSettings.textButton.frame))];
    [self.chatSettings.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.chatSettings.textButton.frame))];
    
    
    
    [container addSubview:self.chatSettings];
    
    
    self.securitySettings = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.SecuritySettings",nil) tapBlock:^{
        [[Telegram settingsWindowController] showWindowWithAction:SettingsWindowActionSecuritySettings];
    }];
    
    currentY+=42;
    
    [self.securitySettings setFrame:NSMakeRect(20, currentY, NSWidth(self.view.frame) - 30, 60)];
    
    [self.securitySettings.textButton setFrameSize:NSMakeSize(NSWidth(self.securitySettings.frame), NSHeight(self.securitySettings.textButton.frame))];
    [self.securitySettings.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.securitySettings.textButton.frame))];
    
    
    
    [container addSubview:self.securitySettings];
    
    
    self.securitySettings.autoresizingMask = self.securitySettings.textButton.autoresizingMask = self.chatSettings.autoresizingMask = self.chatSettings.textButton.autoresizingMask = self.blockedUsers.autoresizingMask = self.blockedUsers.textButton.autoresizingMask = self.updateProfileButton.autoresizingMask = self.updateProfileButton.textButton.autoresizingMask = self.updatePhotoButton.autoresizingMask = self.updatePhotoButton.textButton.autoresizingMask = self.numberTextField.autoresizingMask = self.nameTextField.autoresizingMask = NSViewWidthSizable;
    
    
    self.securitySettings.textButton.textColor = self.chatSettings.textButton.textColor = self.blockedUsers.textButton.textColor = DARK_BLACK;
    
    [container setAutoresizingMask:NSViewWidthSizable];
    
    [container setFrameSize:NSMakeSize(NSWidth(container.frame), currentY+50)];
    
    return container;
}


- (void)enterClick {
    
    
    if(self.state == AccountSettingsStateEditable) {
        [[UsersManager sharedManager] updateAccount:self.firstNameView.textView.stringValue lastName:self.lastNameView.textView.stringValue completeHandler:^(TGUser *user) {
            
        } errorHandler:^(NSString *description) {
            
        }];
    }
    
    [self setState:self.state == AccountSettingsStateEditable ? AccountSettingsStateNormal : AccountSettingsStateEditable animated:YES];
    
    
}

-(NSView *)editContainerView {
    
    int offsetY = 0;
    
    FlippedView *container = [[FlippedView alloc] initWithFrame:NSMakeRect(0, 0, self.frameInit.size.width, 84)];
    
     container.wantsLayer = YES;
    
   // container.backgroundColor = [NSColor blueColor];
    
    self.firstNameView = [[UserInfoShortTextEditView alloc] initWithFrame:NSZeroRect];
    [self.firstNameView setFrameOrigin:NSMakePoint(10, offsetY)];
    [self.firstNameView setFrameSize:NSMakeSize(self.frameInit.size.width-20, 42)];
    
    [container addSubview:self.firstNameView];
    
    
    
    self.lastNameView = [[UserInfoShortTextEditView alloc] initWithFrame:NSZeroRect];
    [self.lastNameView setFrameOrigin:NSMakePoint(10, offsetY + self.firstNameView.bounds.size.height)];
    [self.lastNameView setFrameSize:NSMakeSize(self.frameInit.size.width-20, 42)];
    [container addSubview:self.lastNameView];
    
    //        [self.firstNameView setNextResponder:self.lastNameView];
    [self.firstNameView.textView setNextKeyView:self.lastNameView.textView];
    [self.firstNameView.textView setTarget:self];
    [self.firstNameView.textView setAction:@selector(enterClick)];
    
    
    
    [self.lastNameView.textView setNextKeyView:self.firstNameView.textView];
    [self.lastNameView.textView setTarget:self];
    [self.lastNameView.textView setAction:@selector(enterClick)];
    
    [self.firstNameView.textView setFont:[NSFont fontWithName:@"Helvetica" size:14]];
    [self.lastNameView.textView setFont:[NSFont fontWithName:@"Helvetica" size:14]];
    
    [self.firstNameView.textView setAlignment:NSCenterTextAlignment];
    [self.lastNameView.textView setAlignment:NSCenterTextAlignment];
    
    [self.firstNameView.textView setFrameOrigin:NSMakePoint(0, 0)];
    [self.lastNameView.textView setFrameOrigin:NSMakePoint(0, 0)];
    
    [container setAutoresizingMask:NSViewWidthSizable];
   
    return container;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
      [[TMMediaUserPictureController controller] prepare:[UsersManager currentUser] completionHandler:nil];
}

@end
