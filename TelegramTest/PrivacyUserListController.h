//
//  PrivacyUserListController.h
//  Telegram
//
//  Created by keepcoder on 20.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "PrivacyUserListItemView.h"
@class PrivacySettingsViewController;

@interface PrivacyUserListController : TMViewController

@property (nonatomic,strong) NSString *arrayKey;

@property (nonatomic,strong) PrivacyArchiver *privacy;

@property (nonatomic,strong) dispatch_block_t addCallback;

@property (nonatomic,strong) NSString *title;
-(void)_didRemoveItem:(PrivacyUserListItem *)item;
@end
