//
//  TMBlueAddButtonView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 03.06.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BTRButton.h"

@interface TMBlueAddButtonView : BTRButton

@property (nonatomic,strong) NSString *string;
@property (nonatomic,strong) TLUser *contact;
@property (nonatomic,strong) NSString *phoneNumber;
@end
