//
//  ConnectionStatusViewControllerView.h
//  Telegram
//
//  Created by keepcoder on 03.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"
@class MessagesViewController;
@interface ConnectionStatusViewControllerView : TMView

typedef enum {
    ConnectingStatusTypeConnecting,
    ConnectingStatusTypeConnected,
    ConnectingStatusTypeWaitingNetwork,
    ConnectingStatusTypeUpdating,
    ConnectingStatusTypeNormal
} ConnectingStatusType;

@property (nonatomic,assign) ConnectingStatusType state;
@property (nonatomic,strong) MessagesViewController *controller;

- (void)hide:(BOOL)animated;
- (void)show:(BOOL)animated;
@end
