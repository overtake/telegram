//
//  TMBottomScrollView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 24.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BTRButton.h"

@interface TMBottomScrollView : BTRControl

@property (nonatomic, copy) dispatch_block_t callback;
@property (nonatomic) int messagesCount;

- (void)sizeToFit;

@end