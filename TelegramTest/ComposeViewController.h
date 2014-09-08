//
//  ComposeViewController.h
//  Telegram
//
//  Created by keepcoder on 02.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "ComposeAction.h"
@interface ComposeViewController : TMViewController


@property (nonatomic,strong,readonly) TMBackButton *backButton;
@property (nonatomic,strong,readonly) TMTextField *centerTextField;
@property (nonatomic,strong,readonly) TMTextButton *doneButton;

@property (nonatomic,strong) ComposeAction *action;

@end
