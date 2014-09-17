//
//  NewLoginViewController.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface NewLoginViewController : TMViewController<TMHyperlinkTextFieldDelegate>

- (void)getSMSCode;
- (void)sendCallRequest;
- (void)signIn;
- (void)performBackEditAnimation:(float)duration;

-(void)sendSmsCode;

@end
