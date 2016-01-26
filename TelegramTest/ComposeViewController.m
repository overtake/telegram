//
//  ComposeViewController.m
//  Telegram
//
//  Created by keepcoder on 02.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeViewController.h"

@interface ComposeViewController ()
@property (nonatomic,strong) NSProgressIndicator *progress;
@end

@implementation ComposeViewController

-(void)loadView {
    [super loadView];
    
    
    _progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
    
    [_progress setStyle:NSProgressIndicatorSpinningStyle];
    
    [_progress setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinYMargin];
    
    TMView *rightView = [[TMView alloc] init];
    
    weak();
    
    _doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:@"Done"];
    [self.doneButton setTapBlock:^{
        [weakSelf.action.behavior composeDidDone];
        
        weakSelf.action.editable = !weakSelf.action.editable;
        [weakSelf updateActionNavigation];
        
        [weakSelf didUpdatedEditableState];
        
    }];
    
    [rightView setFrameSize:self.doneButton.frame.size];
    
    
    [rightView addSubview:self.doneButton];
    
    [self setRightNavigationBarView:rightView animated:NO];
    
    [self.doneButton setDisableColor:DARK_GRAY];
    
}

-(void)setLoading:(BOOL)isLoading {
    _isLoading = isLoading;
    
   if(isLoading)
        [self.view addSubview:_progress];
     else
        [_progress removeFromSuperview];
    
    if(_isLoading)
        [_progress startAnimation:self];
    else
        [_progress stopAnimation:self];
    
    [_progress setCenterByView:_progress.superview];
    
    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [obj setHidden:isLoading];
        
        if(obj == _progress) {
        
            [obj setHidden:!isLoading];
        }
        
    }];
}

-(void)setEditable:(BOOL)isEditable {
    _isEditable = isEditable;
    
    
}

-(void)setAction:(ComposeAction *)action {
    _action = action;
    
    [self loadViewIfNeeded];
}

-(void)updateActionNavigation {
   
    [self setCenterBarViewTextAttributed:self.action.behavior.centerTitle];
    
    [self.doneButton setStringValue:self.action.behavior.doneTitle];
    
    [self.doneButton sizeToFit];
    
    [self.doneButton.superview setFrameSize:self.doneButton.frame.size];
    self.rightNavigationBarView = (TMView *) self.doneButton.superview;
}

-(void)didUpdatedEditableState {
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     _action.currentViewController = self;
    [self updateActionNavigation];
}




@end
