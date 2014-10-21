//
//  ConnectionStatusViewControllerView.h
//  Telegram
//
//  Created by keepcoder on 03.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@protocol ConnectionStatusDelegate <NSObject>

@required
-(void)showConnectionController:(BOOL)animated;
-(void)hideConnectionController:(BOOL)animated;

@end

@interface ConnectionStatusViewControllerView : TMView

typedef enum {
    ConnectingStatusTypeConnecting,
    ConnectingStatusTypeConnected,
    ConnectingStatusTypeWaitingNetwork,
    ConnectingStatusTypeUpdating,
    ConnectingStatusTypeNormal
} ConnectingStatusType;

@property (nonatomic,assign) ConnectingStatusType state;
@property (nonatomic,strong) id<ConnectionStatusDelegate> delegate;

- (void)hide:(BOOL)animated;
- (void)show:(BOOL)animated;

- (void)startAnimation;
- (void)stopAnimation;
@end
