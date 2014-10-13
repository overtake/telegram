//
//  BlockedUsersViewController.h
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "BlockedUserRowView.h"
@interface BlockedUsersViewController : TMViewController

-(void)unblockUser:(BlockedUserRowItem *)item;


@end
