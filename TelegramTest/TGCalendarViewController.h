//
//  TGCalendarViewController.h
//  Telegram
//
//  Created by keepcoder on 29/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface TGCalendarViewController : TMViewController
@property (nonatomic,weak) MessagesViewController *messagesViewController;
@property (nonatomic,weak) RBLPopover *rblpopover;
@end
