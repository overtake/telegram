//
//  RegistrationViewController.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface RegistrationViewController : TMViewController<NSTextFieldDelegate>
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *phone_code_hash;
@property (nonatomic, strong) NSString *phone_code;

@end
