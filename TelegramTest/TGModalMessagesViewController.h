//
//  TGModalMessagesViewController.h
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModalView.h"
@class TGContextMessagesvViewController;
@interface TGModalMessagesViewController : TGModalView

@property (nonatomic,strong,readonly) TGContextMessagesvViewController *messagesViewController;

@property (nonatomic,strong) ComposeAction *action;

@end
