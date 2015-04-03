//
//  TGPasswordSetViewController.h
//  Telegram
//
//  Created by keepcoder on 27.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "TGSetPasswordAction.h"
@interface TGPasswordSetViewController : TMViewController

@property (nonatomic,strong) TGSetPasswordAction *action;

-(void)performShake;

@end
