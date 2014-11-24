//
//  BlockedUserRowItem.h
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@class BlockedUsersViewController;

@interface BlockedUserRowItem : TMRowItem

@property (nonatomic,strong,readonly) TL_contact *contact;
@property (nonatomic,strong,readonly) TLUser *user;

@end
