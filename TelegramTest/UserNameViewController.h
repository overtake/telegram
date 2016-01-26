//
//  UserNameViewController.h
//  Telegram
//
//  Created by keepcoder on 15.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface UserNameViewController : TMViewController

@property (nonatomic,strong) TL_channel *channel;

@property (nonatomic,strong) dispatch_block_t completionHandler;

@end
