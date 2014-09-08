//
//  AddContactViewController.h
//  Telegram
//
//  Created by keepcoder on 05.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "RBLPopover.h"
@interface AddContactViewController : TMViewController

@property (nonatomic,strong) RBLPopover *rbl;

-(void)clear;
-(void)close;
@end
