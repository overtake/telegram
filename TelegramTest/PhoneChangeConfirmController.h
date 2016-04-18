//
//  PhoneChangeConfirmController.h
//  Telegram
//
//  Created by keepcoder on 29.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface PhoneChangeConfirmController : TMViewController
- (void)setChangeParams:(TL_auth_sentCode *)params phone:(NSString *)phone;
@end
