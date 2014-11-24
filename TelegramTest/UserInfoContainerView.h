//
//  UserInfoContainerView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/25/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "UserInfoViewController.h"



@interface UserInfoContainerView : TMView<TMStatusTextFieldProtocol>

@property (nonatomic,strong) UserInfoViewController *controller;

@property (nonatomic, strong) TLUser *user;
+ (NSDictionary *)attributsForInfoPlaceholderString;
- (void)setState:(UserInfoViewControllerType)state animation:(BOOL)animation;
- (void)buildPage;

@end
