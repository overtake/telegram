//
//  UserInfoEditContainerView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "UserInfoViewController.h"

@interface UserInfoEditContainerView : TMView

@property (nonatomic, strong) TLUser *user;

@property (nonatomic) UserInfoViewControllerType type;
@property (nonatomic, strong) UserInfoViewController *controller;
- (TL_inputPhoneContact *)newContact;
- (void)buildPage;
@end
