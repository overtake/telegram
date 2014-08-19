//
//  LoginCountrySelectorView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@class NewLoginViewController;

@interface LoginCountrySelectorView : TMView<NSTextFieldDelegate, NSMenuDelegate>

@property (nonatomic, strong) NewLoginViewController *loginController;

- (void)performShake;

- (void)performBlocking:(BOOL)isBlocking;
- (void)showEditButton:(BOOL)isShow;

- (BOOL)isValidPhoneNumber;
- (NSString *)phoneNumber;

@end
