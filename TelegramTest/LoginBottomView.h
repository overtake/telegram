//
//  LoginBottomView.h
//  Telegram
//
//  Created by keepcoder on 19.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "NewLoginViewController.h"
@interface LoginBottomView : TMView

@property (nonatomic,assign) BOOL isAppCodeSent;
@property (nonatomic,assign) int timeToCall;

- (void)startTimer:(int)timer;
- (void)stopTimer;


@property (nonatomic, strong) NewLoginViewController *loginController;

@end
