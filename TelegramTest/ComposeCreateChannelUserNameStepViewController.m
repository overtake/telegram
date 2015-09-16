//
//  ComposeCreateChannelUserNameStepViewController.m
//  Telegram
//
//  Created by keepcoder on 13.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ComposeCreateChannelUserNameStepViewController.h"

#import "TGChangeUserNameContainerView.h"

@interface ComposeCreateChannelUserNameStepViewController ()
@property (nonatomic,strong) TGChangeUserNameContainerView *changeUserNameContainerView;

@property (nonatomic,strong) TGChangeUserObserver *observer;
@end

@implementation ComposeCreateChannelUserNameStepViewController


-(void)loadView {
    [super loadView];
    
    _observer = [[TGChangeUserObserver alloc] initWithDescription:NSLocalizedString(@"Channel.SetChannelLinkDescription", nil) placeholder:NSLocalizedString(@"Channel.SetChannelLinkPlaceholder", nil) defaultUserName:@"wtfmen"];
    
    
    weak();
    
    [_observer setWillNeedSaveUserName:^(NSString *userName) {
        
        if(!(userName.length == 0 && weakSelf.observer.defaultUserName == nil) && ![userName isEqualToString:weakSelf.observer.defaultUserName]) {
            [weakSelf showModalProgress];
            
            [[ChatsManager sharedManager] updateChannelUserName:userName channel:weakSelf.action.result.singleObject completeHandler:^(TL_channel *channel) {
                
                [weakSelf hideModalProgressWithSuccess];
                
                [weakSelf.navigationViewController goBackWithAnimation:YES];
                
            } errorHandler:^(NSString *result) {
                
                [weakSelf hideModalProgress];
                
            }];
        } else {
            [weakSelf.navigationViewController goBackWithAnimation:YES];
        }
 
        
    }];
    
    [_observer setDidChangedUserName:^(NSString *userName, BOOL isAcceptable) {
        
        [weakSelf.doneButton setDisable:!isAcceptable];
        
    }];
    
    [_observer setNeedApiObjectWithUserName:^id(NSString *userName) {
        
        return [TLAPI_channels_checkUsername createWithChannel:[TL_inputChannelEmpty create] username:userName];
    }];
    
    self.view = _changeUserNameContainerView  = [[TGChangeUserNameContainerView alloc] initWithFrame:self.view.bounds observer:_observer];
    
    
    
    
    [self.doneButton setTapBlock:^{
        [weakSelf.changeUserNameContainerView dispatchSaveBlock];
    }];
    
}



-(void)behaviorDidEndRequest:(id)response {
    [self hideModalProgress];
}


-(void)behaviorDidStartRequest {
    [self showModalProgress];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.action.behavior composeDidCancel];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.action.currentViewController = self;
    
    TL_channel *channel = self.action.result.singleObject;
    
    self.observer.defaultUserName = channel.username;
    
    [self setCenterBarViewTextAttributed:self.action.behavior.centerTitle];
    
    
    [_changeUserNameContainerView setOberser:_observer];
    
    [self.doneButton setStringValue:self.action.behavior.doneTitle];
    
    [self.doneButton sizeToFit];
    
    [self.doneButton setDisable:NO];
    
    [self.doneButton.superview setFrameSize:self.doneButton.frame.size];
    self.rightNavigationBarView = (TMView *) self.doneButton.superview;
    
}


-(void)updateCompose {
    
    
}

-(BOOL)becomeFirstResponder {
    
    return YES;
    
    //return [self.headerView becomeFirstResponder];
}

@end
