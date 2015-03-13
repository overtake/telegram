//
//  ComposeViewController.m
//  Telegram
//
//  Created by keepcoder on 02.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeViewController.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController

-(void)loadView {
    [super loadView];
    
    
    TMView *rightView = [[TMView alloc] init];
    
    weakify();
    
    _doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:@"Done"];
    [self.doneButton setTapBlock:^{
        [strongSelf.action.behavior composeDidDone];
    }];
    
    [rightView setFrameSize:self.doneButton.frame.size];
    
    
    [rightView addSubview:self.doneButton];
    
    [self setRightNavigationBarView:rightView animated:NO];
    
    [self.doneButton setDisableColor:DARK_GRAY];
    
}

-(void)setAction:(ComposeAction *)action {
    _action = action;
    [self view];
}

@end
