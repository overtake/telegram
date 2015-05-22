//
//  TGSAppManager.m
//  Telegram
//
//  Created by keepcoder on 19.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSAppManager.h"
#import "TGSNoAuthModalView.h"
#import "TGSEnterPasscodeView.h"
#import "ShareViewController.h"
@implementation TGSAppManager


static NSView *mainView;
static TGSNoAuthModalView *noAuthView;
static TGSEnterPasscodeView *passcodeView;

+(void)setMainView:(NSView *)view {
    mainView = view;
}

+(void)showNoAuthView {
    [ASQueue dispatchOnMainQueue:^{
        noAuthView = [[TGSNoAuthModalView alloc] initWithFrame:[mainView bounds]];
        
        [mainView addSubview:noAuthView];
    }];
}
+(void)closeNoAuthView {
    [ASQueue dispatchOnMainQueue:^{
        [noAuthView removeFromSuperview];
    }];
}


+(void)showPasslock:(passlockCallback)callback {
    [ASQueue dispatchOnMainQueue:^{
        passcodeView = [[TGSEnterPasscodeView alloc] initWithFrame:[mainView bounds]];
        passcodeView.passlockResult = callback;
        [mainView addSubview:passcodeView];
    }];
    
}


+(void)hidePasslock {
    [ASQueue dispatchOnMainQueue:^{
        [passcodeView removeFromSuperview];
    }];
}

+(void)initializeContacts {
    [ShareViewController loadContacts];
}


+(NSUserDefaults *)standartUserDefaults {
    
    static NSUserDefaults *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSUserDefaults alloc] initWithSuiteName:@"group.ru.keepcoder.Telegram"];
    });
    
    return instance;
}
@end
