//
//  TGShareContactModalView.h
//  Telegram
//
//  Created by keepcoder on 23.10.15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGModalView.h"

@interface TGShareContactModalView : TGModalView
@property (nonatomic,weak) MessagesViewController *messagesViewController;

@property (nonatomic,strong) TLUser *user;

@end
