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
#import "TGPeer+Extensions.h"
@interface ExView : TMView

@end

@implementation ExView

-(void)drawRect:(NSRect)dirtyRect {
    [NSColorFromRGB(0xffffff) set];
    
   // NSRectFill(NSMakeRect(0, 0, NSWidth(self.bounds) - DIALOG_BORDER_WIDTH, NSHeight(self.bounds)));
}

@end


@interface FlippedView : TMView

@end

@implementation FlippedView

-(BOOL)isFlipped {
    return YES;
}

@end

@interface AccountSettingsViewController ()<TMNavagationDelegate>
@property (nonatomic,strong) ChatAvatarImageView *avatarImageView;
@property (nonatomic,strong) TMNameTextField *nameTextField;
@property (nonatomic,strong) TMStatusTextField *statusTextField;

@property (nonatomic,strong) UserInfoShortButtonView *updatePhotoButton;



@property (nonatomic,strong) UserInfoShortButtonView *blockedUsers;
@property (nonatomic,strong) UserInfoShortButtonView *generalSettings;
@property (nonatomic,strong) UserInfoShortButtonView *userName;

@property (nonatomic,strong) UserInfoShortButtonView *about;
@property (nonatomic,strong) UserInfoShortButtonView *faq;
@property (nonatomic,strong) UserInfoShortButtonView *askQuestion;


@property (nonatomic,strong) UserInfoShortTextEditView *firstNameView;
@property (nonatomic,strong) UserInfoShortTextEditView *lastNameView;


@property (nonatomic,strong) UserInfoShortButtonView *exportCard;
@property (nonatomic,strong) UserInfoShortButtonView *importCard;



@property (nonatomic,strong) UserCardViewController *userCardViewController;


@property (nonatomic,strong) UserInfoShortButtonView *selectedController;


@property (nonatomic,strong) TMTextButton *editButton;
@property (nonatomic,strong) TMTextButton *cancelEditButton;


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
    
    self.view.isFlipped = YES;
    
    self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    TMView *topContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.frame) - DIALOG_BORDER_WIDTH, 49)];
    
    topContainer.backgroundColor = [NSColor whiteColor];
    
    topContainer.autoresizesSubviews = YES;
    topContainer.autoresizingMask = NSViewWidthSizable;
    
    
    TMTextField *header = [TMTextField defaultTextField];
    
    [header setStringValue:NSLocalizedString(@"Settings", nil)];
    
    [header setFont:[NSFont fontWithName:@"HelveticaNeue" size:16]];
    [header setTextColor:DARK_BLACK];
    
    [header sizeToFit];
    
    weakify();
    
    
    self.editButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:@"Edit"];
    
    
    [self.editButton setTapBlock:^{
        [strongSelf enterClick];
    }];

    [self.editButton setCenterByView:topContainer];
    
    [self.editButton setFrameOrigin:NSMakePoint(NSWidth(self.view.frame) - NSWidth(self.editButton.frame) - 17, NSMinY(self.editButton.frame))];
    
    [topContainer addSubview:self.editButton];
    
    self.editButton.autoresizingMask = NSViewMinXMargin;
    
    
    self.cancelEditButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:@"Cancel"];
    
    
    [self.cancelEditButton setTapBlock:^{
        [strongSelf cancel];
    }];
    
    [self.cancelEditButton setCenterByView:topContainer];
    
    [self.cancelEditButton setFrameOrigin:NSMakePoint(15, NSMinY(self.cancelEditButton.frame))];
    
    [topContainer addSubview:self.cancelEditButton];
    
    [self.cancelEditButton setHidden:YES];
   
    
    header.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
    
    
    [header setCenterByView:topContainer];
    
    
    [topContainer addSubview:header];
    
    
    [self.view addSubview:topContainer];
    

    self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 50, NSWidth(self.frameInit) - DIALOG_BORDER_WIDTH, NSHeight(self.frameInit) - 50)];
    
    self.scrollView.autoresizesSubviews = YES;
    self.scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.scrollView setDrawsBackground:YES];
    
    
    
    self.userCardViewController = [[UserCardViewController alloc] initWithFrame:NSMakeRect(0, 0, 350, 150)];
    
    
    FlippedView *container = [[FlippedView alloc] initWithFrame:self.scrollView.bounds];
    
    
    [container setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
    
    [self.view addSubview:self.scrollView];
    
    self.avatarImageView = [ChatAvatarImageView standartUserInfoAvatar];
    
    [self.avatarImageView setFrameSize:NSMakeSize(70, 70)];
    
    
    int currentY = 20;
    
    [self.avatarImageView setFrameOrigin:NSMakePoint(15, currentY)];
    [container addSubview:self.avatarImageView];
    
    
    currentY+=10;
   
    
    self.nameTextField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(100, currentY, NSWidth(self.view.frame) - 115 , 20)];
    
    [self.nameTextField setSelector:@selector(profileTitle)];
    
    [self.nameTextField setUser:[UsersManager currentUser]];
    
    
    [container addSubview:self.nameTextField];
    
    currentY+=20;
    
    self.statusTextField = [[TMStatusTextField alloc] initWithFrame:NSMakeRect(100, currentY, NSWidth(self.view.frame) - 115, 20)];
    
    [self.statusTextField setSelector:@selector(statusForProfile)];
    
    [self.statusTextField setUser:[UsersManager currentUser]];
    
    
    [container addSubview:self.statusTextField];
    

    
    //self.avatarImageView.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
    
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
    
    
    currentY+=48;
    
    self.defaultView = [self defaultContainerView];
    
    
    
    
    [self.defaultView setFrameOrigin:NSMakePoint(0, currentY)];
    
    [container addSubview:self.defaultView];
    
    
    self.editView = [self editContainerView];

    
    
    [self.editView setFrameOrigin:NSMakePoint(NSMinX(self.editView.frame), 5)]; //17
    
    self.editView.layer.opacity = 0;
    [self.editView setHidden:YES];
    
    [container addSubview:self.editView];
  
    self.containerView = container;
    
    self.scrollView.documentView = self.containerView;
    
    
    [[Telegram rightViewController].navigationViewController addDelegate:self];
    
}


-(void)willChangedController:(TMViewController *)controller {
    if([controller isKindOfClass:[GeneralSettingsViewController class]]) {
        [self selectController:self.generalSettings];
        return;
    }
    
    if([controller isKindOfClass:[BlockedUsersViewController class]]) {
        [self selectController:self.blockedUsers];
        return;
    }
    
    if([controller isKindOfClass:[MessagesViewController class]]) {
        if(((MessagesViewController *)controller).dialog.peer.peer_id == [SettingsArchiver supportUserId]) {
            [self selectController:self.askQuestion];
            
            return;
        }
        
    }
    
    [self selectController:nil];
}

-(void)didChangedController:(TMViewController *)controller {
  
}

-(void)setState:(AccountSettingsState)state animated:(BOOL)animated {
    self->_state = state;
    
    
    
    float duration = 0.2;
    
    int defaultY = state == AccountSettingsStateNormal ? 98 : 108;
    
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
    
    [self.statusTextField.layer pop_addAnimation:nameFade forKey:@"opacity"];
    
    
    [self.editButton setStringValue:state == AccountSettingsStateNormal ? NSLocalizedString(@"Edit",nil) : NSLocalizedString(@"Profile.Done",nil)];
    
    [self.editButton sizeToFit];
    
    [self.cancelEditButton setHidden:state == AccountSettingsStateNormal];
    
    [self.editButton setFrameOrigin:NSMakePoint(NSWidth(self.view.frame) - NSWidth(self.editButton.frame) - 17, NSMinY(self.editButton.frame))];
    
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
    
//    self.updateProfileButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.EditProfile",nil) tapBlock:^{
//        
//        [self enterClick];
//        
//    }];
//    
//   
//    
//    [self.updateProfileButton setFrame:NSMakeRect(20, currentY, NSWidth(self.view.frame) - 30, 60)];
//    
//    //   [self.updateProfileButton.textButton setAlignment:NSCenterTextAlignment];
//    [self.updateProfileButton.textButton setFrameSize:NSMakeSize(NSWidth(self.updateProfileButton.frame), NSHeight(self.updateProfileButton.textButton.frame))];
//    [self.updateProfileButton.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.updateProfileButton.textButton.frame))];
//    
//    self.updateProfileButton.autoresizingMask = self.updateProfileButton.textButton.autoresizingMask = self.nameTextField.autoresizingMask = NSViewWidthSizable;
//    
//    [container addSubview:self.updateProfileButton];
//
//    
//     currentY+=42;
    
    self.updatePhotoButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.SetProfilePhoto",nil) tapBlock:^{
        [self.avatarImageView showUpdateChatPhotoBox];
    }];
    
   
    
    
    [self.updatePhotoButton setFrame:NSMakeRect(0, currentY, NSWidth(self.view.frame) - 0, 60)];
    
    // [self.updatePhotoButton.textButton setAlignment:NSCenterTextAlignment];
    [self.updatePhotoButton.textButton setFrameSize:NSMakeSize(NSWidth(self.updatePhotoButton.frame), NSHeight(self.updatePhotoButton.textButton.frame))];
    [self.updatePhotoButton.textButton setFrameOrigin:NSMakePoint(20, NSMinY(self.updatePhotoButton.textButton.frame))];
    
    
    [container addSubview:self.updatePhotoButton];
    
//     currentY+=42;
//    
//    
//    
//    self.exportCard = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.ExportCard",nil) tapBlock:^{
//        
//        NSRect rect = self.exportCard.bounds;
//        
//        rect.origin.y-=10;
//
//        
//        [self.userCardViewController showWithType:UserCardViewTypeExport relativeRect:rect ofView:self.exportCard preferredEdge:CGRectMinYEdge];
//    
//    
//    }];
//    
//    [self.exportCard setFrame:NSMakeRect(20, currentY, NSWidth(self.view.frame) - 30, 60)];
//    
//    [self.exportCard.textButton setFrameSize:NSMakeSize(NSWidth(self.exportCard.frame), NSHeight(self.exportCard.textButton.frame))];
//    [self.exportCard.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.exportCard.textButton.frame))];
//    
//    
//    [container addSubview:self.exportCard];
    
    
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
    
     currentY+=57;
    
    
    self.generalSettings = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.General",nil) tapBlock:^{
        
        if([Telegram rightViewController].navigationViewController.isLocked)
        {
            //NSBeep();
            return;
        }
        
       // [self selectController:self.generalSettings];
        
        [[Telegram rightViewController] showGeneralSettings];
        
    }];
    
    
    [self.generalSettings setFrame:NSMakeRect(0, currentY, NSWidth(self.view.frame) - 0, 60)];
    
    [self.generalSettings.textButton setFrameSize:NSMakeSize(NSWidth(self.generalSettings.frame), NSHeight(self.generalSettings.textButton.frame))];
    [self.generalSettings.textButton setFrameOrigin:NSMakePoint(20, NSMinY(self.generalSettings.textButton.frame))];
    
    
    [container addSubview:self.generalSettings];
    
    
    
    currentY+=42;
    
    self.blockedUsers = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.BlockedUsers",nil) tapBlock:^{
        
        if([Telegram rightViewController].navigationViewController.isLocked)
        {
            //NSBeep();
            return;
        }
        
       // [self selectController:self.blockedUsers];
        
        [[Telegram rightViewController] showBlockedUsers];
    }];
   
    
    [self.blockedUsers setFrame:NSMakeRect(0, currentY, NSWidth(self.view.frame) - 0, 60)];
    
    [self.blockedUsers.textButton setFrameSize:NSMakeSize(NSWidth(self.blockedUsers.frame), NSHeight(self.blockedUsers.textButton.frame))];
    [self.blockedUsers.textButton setFrameOrigin:NSMakePoint(20, NSMinY(self.blockedUsers.textButton.frame))];
    
    
    [container addSubview:self.blockedUsers];
    
    
    currentY+=42;
    
    
    self.userName = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.UserName",nil) tapBlock:^{
        
        if([Telegram rightViewController].navigationViewController.isLocked)
        {
            //NSBeep();
            return;
        }
        
       //  [self selectController:self.userName];
        
        [[Telegram rightViewController] showGeneralSettings];
    }];
    
   
    
    [self.userName setFrame:NSMakeRect(0, currentY, NSWidth(self.view.frame) - 0, 60)];
    
    [self.userName.textButton setFrameSize:NSMakeSize(NSWidth(self.userName.frame), NSHeight(self.userName.textButton.frame))];
    [self.userName.textButton setFrameOrigin:NSMakePoint(20, NSMinY(self.userName.textButton.frame))];
    
    
    [container addSubview:self.userName];
    
    
    
    currentY+=65;
    
    
    
    self.about = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.About",nil) tapBlock:^{
        
        if([Telegram rightViewController].navigationViewController.isLocked)
        {
            //NSBeep();
            return;
        }
        
       // [self selectController:self.about];
        
    }];
    
    
    
    [self.about setFrame:NSMakeRect(0, currentY, NSWidth(self.view.frame) - 0, 60)];
    
    [self.about.textButton setFrameSize:NSMakeSize(NSWidth(self.about.frame), NSHeight(self.about.textButton.frame))];
    [self.about.textButton setFrameOrigin:NSMakePoint(20, NSMinY(self.about.textButton.frame))];
    
    
    
    [container addSubview:self.about];
    
    
    currentY+=42;
    
    self.faq = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.FAQ",nil) tapBlock:^{
        open_link(@"https://telegram.org/faq");
    }];
    
    [self.faq setFrame:NSMakeRect(0, currentY, NSWidth(self.view.frame) - 0, 60)];
    
    [self.faq.textButton setFrameSize:NSMakeSize(NSWidth(self.faq.frame), NSHeight(self.faq.textButton.frame))];
    [self.faq.textButton setFrameOrigin:NSMakePoint(20, NSMinY(self.faq.textButton.frame))];
    
    
    
    [container addSubview:self.faq];
    
    currentY+=42;
    
    self.askQuestion = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Account.AskQuestion",nil) tapBlock:^{
        
        if([Telegram rightViewController].navigationViewController.isLocked)
        {
            //NSBeep();
            return;
        }
        
       // [self selectController:self.askQuestion];
        
        NSUInteger supportUserId = [SettingsArchiver supportUserId];
        
        __block TGUser *supportUser;
        
        
        dispatch_block_t block = ^ {
            TL_conversation *dialog = [[DialogsManager sharedManager] findByUserId:supportUser.n_id];
            
            if(!dialog) {
                dialog = [[DialogsManager sharedManager] createDialogForUser:supportUser];
                [dialog save];
            }
            
            [[Telegram rightViewController] showByDialog:dialog sender:self];
        };
        
        
        
        
        if(supportUserId) {
            supportUser = [[UsersManager sharedManager] find:supportUserId];
            if(supportUser) {
                block();
                return;
            }
        }
        
        [RPCRequest sendRequest:[TLAPI_help_getSupport create] successHandler:^(RPCRequest *request, TL_help_support *response) {
            
            supportUser = response.user;
            [[UsersManager sharedManager] add:@[supportUser]];
            
            [SettingsArchiver setSupportUserId:response.user.n_id];
            block();
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            if(error.error_code == 502) {
                alert(NSLocalizedString(@"App.ConnectionError", nil), NSLocalizedString(error.error_msg, nil));
            }
            
            
        } timeout:5];
    }];
    
    
    
    [self.askQuestion setFrame:NSMakeRect(0, currentY, NSWidth(self.view.frame) - 0, 60)];
    
    [self.askQuestion.textButton setFrameSize:NSMakeSize(NSWidth(self.askQuestion.frame), NSHeight(self.askQuestion.textButton.frame))];
    [self.askQuestion.textButton setFrameOrigin:NSMakePoint(20, NSMinY(self.askQuestion.textButton.frame))];
    
    
    
    [container addSubview:self.askQuestion];
    
    
    self.askQuestion.autoresizingMask = self.faq.autoresizingMask = self.about.autoresizingMask = self.blockedUsers.autoresizingMask = self.blockedUsers.textButton.autoresizingMask = self.updatePhotoButton.autoresizingMask = self.updatePhotoButton.textButton.autoresizingMask = self.nameTextField.autoresizingMask = NSViewWidthSizable;
    
    
    self.askQuestion.textButton.textColor = self.faq.textButton.textColor = self.about.textButton.textColor = self.blockedUsers.textButton.textColor = self.userName.textButton.textColor = self.generalSettings.textButton.textColor = DARK_BLACK;
    
    [container setAutoresizingMask:NSViewWidthSizable];
    
    [container setFrameSize:NSMakeSize(NSWidth(container.frame), currentY+50)];
    
    
    self.userName.rightContainer = imageViewWithImage(image_select());
    self.blockedUsers.rightContainer = imageViewWithImage(image_select());
    self.generalSettings.rightContainer = imageViewWithImage(image_select());
    self.about.rightContainer = imageViewWithImage(image_select());
    self.faq.rightContainer = imageViewWithImage(image_select());
    self.askQuestion.rightContainer = imageViewWithImage(image_select());
    
    self.userName.rightContainerOffset = NSMakePoint(-10, 0);
    self.blockedUsers.rightContainerOffset = NSMakePoint(-10, 0);
    self.generalSettings.rightContainerOffset = NSMakePoint(-10, 0);
    self.about.rightContainerOffset = NSMakePoint(-10, 0);
    self.faq.rightContainerOffset = NSMakePoint(-10, 0);
    self.askQuestion.rightContainerOffset = NSMakePoint(-10, 0);
    
    [self.userName setSelectedColor:BLUE_COLOR_SELECT];
    [self.blockedUsers setSelectedColor:BLUE_COLOR_SELECT];
    [self.generalSettings setSelectedColor:BLUE_COLOR_SELECT];
    [self.about setSelectedColor:BLUE_COLOR_SELECT];
    [self.faq setSelectedColor:BLUE_COLOR_SELECT];
    [self.askQuestion setSelectedColor:BLUE_COLOR_SELECT];
    
    return container;
}

-(void)selectController:(UserInfoShortButtonView *)selectController {
    
    if(self.selectedController != selectController) {
        [self.selectedController.textButton setTextColor:DARK_BLACK];
        self.selectedController.rightContainer = imageViewWithImage(image_select());
        self.selectedController.isSelected = NO;
        
        
        [selectController.textButton setTextColor:[NSColor whiteColor]];
        selectController.rightContainer = imageViewWithImage(image_ArrowWhite());
        selectController.isSelected = YES;
        
        self.selectedController = selectController;
    }
}


- (void)enterClick {
    
    
    if(self.state == AccountSettingsStateEditable) {
        [[UsersManager sharedManager] updateAccount:self.firstNameView.textView.stringValue lastName:self.lastNameView.textView.stringValue completeHandler:^(TGUser *user) {
            
        } errorHandler:^(NSString *description) {
            
        }];
    }
    
    [self setState:self.state == AccountSettingsStateEditable ? AccountSettingsStateNormal : AccountSettingsStateEditable animated:YES];
    
    
}


- (void)cancel {
    [self setState:AccountSettingsStateNormal animated:YES];
}

-(NSView *)editContainerView {
    
    int offsetY = 0;
    
    FlippedView *container = [[FlippedView alloc] initWithFrame:NSMakeRect(100, 0, NSWidth(self.view.frame) - 115, 84)];
    
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
    
    [self.firstNameView.textView setFont:[NSFont fontWithName:@"HelveticaNeue" size:16]];
    [self.lastNameView.textView setFont:[NSFont fontWithName:@"HelveticaNeue" size:16]];
    
    [self.firstNameView.textView setAlignment:NSLeftTextAlignment];
    [self.lastNameView.textView setAlignment:NSLeftTextAlignment];
    
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
