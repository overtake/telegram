//
//  SettingsSecurityViewController.m
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SettingsSecurityViewController.h"
#import "UserInfoShortButtonView.h"
#import "ImageStorage.h"
@interface SettingsSecurityViewController ()
@property (nonatomic,strong) TMTextField *centerTextField;
@property (nonatomic,strong) TMBackButton *backButton;
@property (nonatomic,strong) TMTextButton *logoutButton;
@property (nonatomic,strong) UserInfoShortButtonView *clearCache;
@property (nonatomic,strong) UserInfoShortButtonView *terminate;



@end

@implementation SettingsSecurityViewController

-(void)loadView {
    [super loadView];
    
    self.view.isFlipped = YES;
    
    _centerTextField = [TMTextField defaultTextField];
    [self.centerTextField setAlignment:NSCenterTextAlignment];
    [self.centerTextField setAutoresizingMask:NSViewWidthSizable];
    [self.centerTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:16]];
    [self.centerTextField setTextColor:NSColorFromRGB(0x222222)];
    [[self.centerTextField cell] setTruncatesLastVisibleLine:YES];
    [[self.centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.centerTextField setDrawsBackground:NO];
    
    [self.centerTextField setStringValue:NSLocalizedString(@"GeneralSettings.Security", nil)];
    
    [self.centerTextField setFrameOrigin:NSMakePoint(self.centerTextField.frame.origin.x, -12)];
    
    self.centerNavigationBarView = (TMView *) self.centerTextField;
    
    
    
    TMView *rightView = [[TMView alloc] init];
    
    
    weakify();
    
    _logoutButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Settings.log_out_button",nil)];
    [self.logoutButton setTapBlock:^{
        [strongSelf logOut];
    }];
    
    [rightView setFrameSize:self.logoutButton.frame.size];
    
    
    [rightView addSubview:self.logoutButton];
    
    [self setRightNavigationBarView:rightView animated:NO];
    
    
    int y = 60;
    
    self.clearCache = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Settings.ClearCache", nil) tapBlock:^{
        [[Storage manager] saveEmoji:[NSMutableArray array]];
        [[Storage manager] saveInputTextForPeers:[NSMutableDictionary dictionary]];
        [ImageStorage clearCache];
    }];
    
    [self.clearCache.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.clearCache.textButton.frame))];
    
    
    
    
    [self.clearCache setFrame:NSMakeRect(100, y, NSWidth(self.view.frame) - 200, NSHeight(self.clearCache.frame))];
    
    [self.view addSubview:self.clearCache];
    
    TMTextField *cacheDesc = [TMTextField defaultTextField];
    
    [cacheDesc setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
    
    
    [cacheDesc setStringValue:NSLocalizedString(@"Settings.ClearCacheDescription",nil)];
    
    [cacheDesc sizeToFit];
    
    y+=50;
    
    [cacheDesc setFrameOrigin:NSMakePoint(100, y)];
    
    [self.view addSubview:cacheDesc];
    
    
    y+=50;
    
    
    
    self.terminate = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Settings.TerminateOtherSessions", nil) tapBlock:^{
        [self terminateSessions];
    }];
    
    [self.terminate.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.terminate.textButton.frame))];
    
    
    
    [self.terminate setFrame:NSMakeRect(100, y, NSWidth(self.view.frame) - 200, NSHeight(self.terminate.frame))];
    
    [self.view addSubview:self.terminate];
    
    TMTextField *terminateDesc = [TMTextField defaultTextField];
    
    [terminateDesc setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
    
    
    [terminateDesc setStringValue:NSLocalizedString(@"Settings.TerminateOtherSessionsDescription",nil)];
    
    [terminateDesc sizeToFit];
    
    y+=50;
    
    [terminateDesc setFrameOrigin:NSMakePoint(100, y)];
    
    [self.view addSubview:terminateDesc];

    
}


- (void)terminateSessions {
    
    confirm(NSLocalizedString(@"Confirm", nil), NSLocalizedString(@"Confirm.TerminateSessions", nil), ^ {
        [RPCRequest sendRequest:[TLAPI_auth_resetAuthorizations create] successHandler:^(RPCRequest *request, id response) {
            
            alert(NSLocalizedString(@"Success", nil), NSLocalizedString(@"Confirm.SuccessResetSessions", nil));
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            alert(NSLocalizedString(@"Alert.Error", nil), NSLocalizedString(@"Auth.CheckConnection", nil));
            
        } timeout:5];
    });
    
    
}
- (void)logOut {
    confirm(NSLocalizedString(@"Confirm", nil),NSLocalizedString(@"Confirm.ConfirmLogout", nil), ^ {
        [[Telegram delegate] logoutWithForce:NO];
    });
    
}

@end
