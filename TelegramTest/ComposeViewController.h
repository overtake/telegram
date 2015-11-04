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

@property (nonatomic,strong,readonly) TMTextButton *doneButton;
@property (nonatomic,strong) ComposeAction *action;

@property (nonatomic,assign,setter=setLoading:) BOOL isLoading;


@property (nonatomic,assign, setter=setEditable:) BOOL isEditable;

-(void)updateActionNavigation;

-(void)didUpdatedEditableState;

@end
