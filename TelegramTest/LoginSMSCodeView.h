//
//  LoginSMSCodeView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"
@class NewLoginViewController;

@interface LoginSMSCodeView : TMView<NSTextFieldDelegate>

- (void)performSlideDownWithDuration:(float)duration;
- (void)performShake;


- (void)changeCallTextFieldString:(NSString *)string;
- (NSString *)code;
- (BOOL)isValidCode;

- (void)performBlocking:(BOOL)isBlocking;

@property (nonatomic, strong) NewLoginViewController *loginController;

@end
