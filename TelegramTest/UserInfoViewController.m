//
//  UserInfoViewController.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/25/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserInfoViewController.h"
#import "TMAvatarImageView.h"
#import "UserInfoContainerView.h"
#import "UserInfoEditContainerView.h"
#import "TMMediaUserPictureController.h"
#import "TMCollectionViewController.h"
#import "ChatAvatarImageView.h"
@interface UserInfoViewController ()

@property (nonatomic, strong) TMView *containerView;
@property (nonatomic, strong) TMScrollView *scrollView;
@property (nonatomic) UserInfoViewControllerType state;
@property (nonatomic, strong) UserInfoContainerView *normalContainer;
@property (nonatomic, strong) UserInfoEditContainerView *editContainer;

@property (nonatomic,strong) TMTextField *centerTextField;
@property (nonatomic, strong) TMBackButton *backButton;




@end

@interface FlippedClipView : NSClipView
@end

@implementation FlippedClipView

- (BOOL) isFlipped {
    return YES;
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}

@end

@implementation UserInfoViewController

- (IBAction)testAction:(id)sender {
    
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backButton = [[TMBackButton alloc] initWithFrame:NSZeroRect string:NSLocalizedString(@"Conversation.Back", nil)];
        self.leftNavigationBarView = [[TMView alloc] initWithFrame:self.backButton.bounds];
        [self.leftNavigationBarView addSubview:self.backButton];
        
        
        TMButton *center = [[TMButton alloc] initWithFrame:NSMakeRect(0, 0, 400, 200)];
        [center setTarget:self selector:@selector(navigationGoBack)];
        self.centerNavigationBarView = center;
        center.acceptCursor = NO;
        FlippedClipView *flippedClipView = [[FlippedClipView alloc] initWithFrame:self.view.bounds];
        [flippedClipView setAutoresizesSubviews:YES];
        [flippedClipView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        self.containerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 600)];
        [self.containerView setAutoresizingMask:NSViewWidthSizable];
        
        self.normalContainer = [[UserInfoContainerView alloc] initWithFrame:self.containerView.bounds];
        [self.normalContainer setAutoresizesSubviews:YES];
        [self.normalContainer setWantsLayer:YES];
        [self.normalContainer setAutoresizingMask:NSViewWidthSizable];
        [self.containerView addSubview:self.normalContainer];

        self.editContainer = [[UserInfoEditContainerView alloc] initWithFrame:self.containerView.bounds];
        [self.editContainer setAutoresizesSubviews:YES];
        [self.editContainer setWantsLayer:YES];
        [self.editContainer setAutoresizingMask:NSViewWidthSizable];
        [self.editContainer setController:self];
        [self.containerView addSubview:self.editContainer];
        
        
        _centerTextField = [TMTextField defaultTextField];
        [self.centerTextField setAlignment:NSCenterTextAlignment];
        [self.centerTextField setAutoresizingMask:NSViewWidthSizable];
        [self.centerTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:16]];
        [self.centerTextField setTextColor:NSColorFromRGB(0x222222)];
        [[self.centerTextField cell] setTruncatesLastVisibleLine:YES];
        [[self.centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.centerTextField setDrawsBackground:NO];
        
        [self.centerTextField setStringValue:NSLocalizedString(@"Profile.Info", nil)];
        
        [self.centerTextField setFrameOrigin:NSMakePoint(self.centerTextField.frame.origin.x, -12)];
        
        self.centerNavigationBarView = (TMView *) self.centerTextField;

        
        

        _avatarImageView = [ChatAvatarImageView standartUserInfoAvatar];
        
        [_avatarImageView setFrameSize:NSMakeSize(70, 70)];
        [_avatarImageView setFrameOrigin:NSMakePoint(100, self.containerView.bounds.size.height - self.avatarImageView.bounds.size.height - 30)];
        [_containerView addSubview:_avatarImageView];
        
        weakify();
        [_avatarImageView setTapBlock:^{
            PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:0 media:strongSelf.user.photo.photo_big peer_id:strongSelf.user.n_id];
            
            previewObject.reservedObject = strongSelf.avatarImageView;
            
            TMPreviewUserPicture *picture = [[TMPreviewUserPicture alloc] initWithItem:previewObject];
            if(picture) {
                [[TMMediaUserPictureController controller] prepare:strongSelf.user completionHandler:^{
                    [[TMMediaUserPictureController controller] show:picture];
                }];
            }
        }];
        
         [_avatarImageView setSourceType:ChatAvatarSourceUser];
        
        
        self.scrollView = [[TMScrollView alloc] initWithFrame:self.view.bounds];
        [self.scrollView setAutoresizesSubviews:YES];
        [self.scrollView setContentView:flippedClipView];
        [self.scrollView setDocumentView:self.containerView];
        [self.scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self.view addSubview:self.scrollView];
        
        [Notification addObserver:self selector:@selector(userNameChangedNotification:) name:USER_UPDATE_NAME];
    }
    return self;
}


- (void)navigationGoBack {
    [[Telegram rightViewController] navigationGoBack];
}

- (void)successDeleteContact {
    [self setState:UserInfoViewControllerNormal];
    [self.normalContainer buildPage];
}

- (TMView *) generateRightHeaderButtons {
    TMView *view = [[TMView alloc] init];
    
    weakify();
    
    if(self.user.type == TGUserTypeSelf) {
        if(self.state == UserInfoViewControllerNormal) {
            TMTextButton *editButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Edit", nil)];
            [editButton setTapBlock:^{
                strongSelf.state = UserInfoViewControllerEdit;
            }];
            [view addSubview:editButton];
            [view setFrameSize:editButton.bounds.size];
            
        } else {
            TMTextButton *saveButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Save", nil)];
            [saveButton setTapBlock:^{
                TL_inputPhoneContact *contact = [self.editContainer newContact];
                
                dispatch_block_t block = ^{
                    
                    [[UsersManager sharedManager] updateAccount:contact.first_name lastName:contact.last_name completeHandler:^(TGUser *user) {
                        
                        [self.normalContainer buildPage];
                        
                        
                        strongSelf.state = UserInfoViewControllerNormal;
                        
                        
                    } errorHandler:^(NSString *description) {
                        
                    }];
                };
                
                if([self.user.first_name isEqualToString:contact.first_name] && [self.user.last_name isEqualToString:contact.last_name])
                    strongSelf.state = UserInfoViewControllerNormal;
                else block();
                
            }];
            [view addSubview:saveButton];
            [view setFrameSize:saveButton.bounds.size];
            
            TMTextButton *cancelButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
            [cancelButton setFrameOrigin:NSMakePoint(saveButton.bounds.size.width + 10, cancelButton.frame.origin.y)];
            [cancelButton setTapBlock:^{
                strongSelf.state = UserInfoViewControllerNormal;
            }];
            [view addSubview:cancelButton];
            
            [view setFrameSize:NSMakeSize(cancelButton.frame.origin.x + cancelButton.bounds.size.width, cancelButton.bounds.size.height)];
            
        }
        return view;
    }
    
    
  
    
    if(self.user.type == TGUserTypeContact) {
        
        if(self.state == UserInfoViewControllerNormal) {
            TMTextButton *editButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Edit", nil)];
            [editButton setTapBlock:^{
//                strongify();
                strongSelf.state = UserInfoViewControllerEdit;
            }];
            [view addSubview:editButton];
            [view setFrameSize:editButton.bounds.size];
            
        } else {
            TMTextButton *saveButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Save", nil)];
            [saveButton setTapBlock:^{
                
                TL_inputPhoneContact *contact = [self.editContainer newContact];
                
                dispatch_block_t block = ^{
//                    strongify();
                    strongSelf.state = UserInfoViewControllerNormal;
                };
                
                if(!contact) {
                    block();
                } else {
                    [[NewContactsManager sharedManager] importContact:contact callback:^(BOOL isAdd, TL_importedContact *contact, TGUser *user) {
                        block();
                    }];
                }
                
            }];
            [view addSubview:saveButton];
            [view setFrameSize:saveButton.bounds.size];
            
            TMTextButton *cancelButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
            [cancelButton setFrameOrigin:NSMakePoint(saveButton.bounds.size.width + 10,  cancelButton.frame.origin.y)];
            [cancelButton setTapBlock:^{
                [self setState:UserInfoViewControllerNormal];
            }];
            [view addSubview:cancelButton];
            
            [view setFrameSize:NSMakeSize(cancelButton.frame.origin.x + cancelButton.bounds.size.width, cancelButton.bounds.size.height)];
        }
        
        
        
    } else if(self.user.type == TGUserTypeRequest) {
        
        if(self.state == UserInfoViewControllerAddContact) {
            TMTextButton *doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Done", nil)];
            [doneButton setTapBlock:^{
                TL_inputPhoneContact *contact = [self.editContainer newContact];
                [[NewContactsManager sharedManager] importContact:contact callback:^(BOOL isAdd, TL_importedContact *contact, TGUser *user) {
                    self.state = UserInfoViewControllerNormal;
                }];
            }];
            doneButton.textColor = NSColorFromRGB(0x2979c5);
            [view addSubview:doneButton];
            
            TMTextButton *cancelButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
            [cancelButton setFrameOrigin:NSMakePoint(doneButton.bounds.size.width + 10, cancelButton.frame.origin.y)];
            [cancelButton setTapBlock:^{
                [self setState:UserInfoViewControllerNormal];
            }];
            [view addSubview:cancelButton];
            [view setFrameSize:NSMakeSize(cancelButton.frame.origin.x + cancelButton.bounds.size.width, cancelButton.bounds.size.height)];
            
        } else {
            TMTextButton *addButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"User.AddToContacts", nil)];
            [addButton setTapBlock:^{
                [self setState:UserInfoViewControllerAddContact];
            }];
            
            [view addSubview:addButton];
            [view setFrameSize:addButton.bounds.size];
        }
    }
    
    if(self.state == UserInfoViewControllerNormal) {
        
//        TGContactBlocked *blocked = [[BlockedUsersManager sharedManager] find:self.user.n_id];
//        
//        TMTextButton *blockButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:blocked ? NSLocalizedString(@"User.Unlock", nil) : NSLocalizedString(@"User.Block", nil)];
//        weakify();
//        [blockButton setTapBlock:^{
//            int user_id = strongSelf.user.n_id;
//            TGContactBlocked *blocked = [[BlockedUsersManager sharedManager] find:user_id];
//            
//            BlockedHandler handlerBlock = ^(BOOL result) {
//                if(result)
//                    [strongSelf setRightNavigationBarView:[strongSelf generateRightHeaderButtons] animated:YES];
//            };
//            
//            if(blocked) {
//                [[BlockedUsersManager sharedManager] unblock:user_id completeHandler:handlerBlock];
//            } else {
//                [[BlockedUsersManager sharedManager] block:user_id completeHandler:handlerBlock];
//            }
//        }];
//        [view addSubview:blockButton];
//        [blockButton setFrameOrigin:NSMakePoint(view.bounds.size.width + 10, blockButton.frame.origin.y)];
//        [view setFrameSize:NSMakeSize(blockButton.frame.origin.x + blockButton.frame.size.width, view.frame.size.height ? view.frame.size.height : blockButton.frame.size.height)];
    }
    
    return view;
}

- (void) setState:(UserInfoViewControllerType)state {
    self->_state = state;
 //   [self setRightNavigationBarView:[self generateRightHeaderButtons] animated:YES];
    
    [self.normalContainer.layer removeAllAnimations];
    [self.editContainer.layer removeAllAnimations];
    
    [self.editContainer setUser:self.user];
    [self.editContainer setType:state];

    [self.normalContainer setHidden:NO];
    [self.editContainer setHidden:NO];
    
    if(self.state != UserInfoViewControllerNormal) {
        [self.editContainer buildPage];
    }
    
    DLog(@"norma %f %d, edit %f %d", self.normalContainer.layer.opacity, self.normalContainer.isHidden, self.editContainer.layer.opacity, self.editContainer.isHidden);
    
    if(state != UserInfoViewControllerNormal) {
        [self.normalContainer setHidden:YES];
        [self.editContainer setHidden:NO];
        [self.editContainer becomeFirstResponder];
    } else {
        [self.normalContainer setHidden:NO];
        [self.editContainer setHidden:YES];
        [self.view.window makeFirstResponder:nil];
        [self.editContainer buildPage];
    }
    
    [self setRightNavigationBarView:[self generateRightHeaderButtons] animated:YES];
}

- (void)userNameChangedNotification:(NSNotification *)notify {
    TGUser *user = [notify.userInfo objectForKey:KEY_USER];
    if(user.n_id == self.user.n_id) {
        [self setRightNavigationBarView:[self generateRightHeaderButtons] animated:YES];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
}

- (BOOL)becomeFirstResponder {
    return YES;
}

- (void) setUser:(TGUser *)user {
    [self setUser:user conversation:nil];
}

-(void)setUser:(TGUser *)user conversation:(TL_conversation *)conversation  {
    
    
    
    self->_state = UserInfoViewControllerNormal;
    self->_user = user;
    self->_conversation = conversation;
    self->_isSecretProfile = self.conversation && self.conversation.type == DialogTypeSecretChat;
    
    [self.avatarImageView setUser:user];
    
    //Old Controller
    if(self.navigationViewController.currentController != [Telegram rightViewController].chatInfoViewController) {
        [self.backButton setStringValue:NSLocalizedString(@"Conversation.Back", nil)];
    } else {
        [self.backButton setStringValue:NSLocalizedString(@"Conversation.BackToInfo", nil)];
    }
    [self.backButton sizeToFit];
    
    self.leftNavigationBarView = self.backButton;
    
    [[TMMediaUserPictureController controller] prepare:user completionHandler:nil];
    
    
    [self.editContainer setHidden:YES];
    [self.normalContainer setHidden:NO];
    
    self.normalContainer.layer.opacity = 1;
    self.normalContainer.controller = self;
    
    [self.normalContainer setUser:user];
    
    
    
    [self.editContainer setUser:user];
    [self.avatarImageView setUser:user];
    [self setRightNavigationBarView:[self generateRightHeaderButtons]];
}

@end
