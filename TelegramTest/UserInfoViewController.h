//
//  UserInfoViewController.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/25/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "ChatAvatarImageView.h"
typedef enum {
    UserInfoViewControllerNormal,
    UserInfoViewControllerEdit,
    UserInfoViewControllerAddContact
} UserInfoViewControllerType;

@interface UserInfoViewController : TMViewController
@property (nonatomic,assign, readonly) BOOL isSecretProfile;
@property (nonatomic, strong, readonly) TGUser *user;
@property (nonatomic, strong, readonly) TL_conversation *conversation;
@property (nonatomic,strong, readonly) ChatAvatarImageView *avatarImageView;
-(void)setUser:(TGUser *)user conversation:(TL_conversation *)conversation;

- (void)successDeleteContact;

@end
