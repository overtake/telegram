//
//  TGContextMessagesvViewController.h
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "MessagesViewController.h"
#import "TGModalMessagesViewController.h"
@interface TGContextMessagesvViewController : MessagesViewController
@property (nonatomic,weak) TGModalMessagesViewController *contextModalView;
@end
