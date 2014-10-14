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
    
    _centerTextField = [TMTextField defaultTextField];
    [self.centerTextField setAlignment:NSCenterTextAlignment];
    [self.centerTextField setAutoresizingMask:NSViewWidthSizable];
    [self.centerTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:16]];
    [self.centerTextField setTextColor:NSColorFromRGB(0x222222)];
    [[self.centerTextField cell] setTruncatesLastVisibleLine:YES];
    [[self.centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.centerTextField setDrawsBackground:NO];
    
    [self.centerTextField setFrameOrigin:NSMakePoint(self.centerTextField.frame.origin.x, -15)];
    
    self.centerNavigationBarView = (TMView *) self.centerTextField;
    
    _backButton = [[TMBackButton alloc] initWithFrame:NSZeroRect string:NSLocalizedString(@"Compose.Back", nil)];
    self.leftNavigationBarView = [[TMView alloc] initWithFrame:self.backButton.bounds];
    [self.leftNavigationBarView addSubview:self.backButton];
    
    
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

@end
