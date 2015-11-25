//
//  MesssageInputGrowingTextView.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/15/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMGrowingTextView.h"
#import "SettingsArchiver.h"
#import "MessagesViewController.h"
@interface MessageInputGrowingTextView : TMGrowingTextView<SettingsListener>

@property (nonatomic,weak) MessagesViewController *controller;

@end
