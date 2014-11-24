//
//  PrivacyUserListItem.h
//  Telegram
//
//  Created by keepcoder on 20.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@class PrivacyUserListController;

@interface PrivacyUserListItem : TMRowItem
@property (nonatomic,strong,readonly) TLUser *user;

@property (nonatomic,weak) PrivacyUserListController *controller;
@end
