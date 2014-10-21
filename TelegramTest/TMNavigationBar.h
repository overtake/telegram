//
//  TMNavigationBar.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/27/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "ConnectionStatusViewControllerView.h"
@interface TMNavigationBar : TMView

- (void) setLeftView:(TMView *)view animated:(BOOL)animated;
- (void) setRightView:(TMView *)view animated:(BOOL)animated;
- (void) setCenterView:(TMView *)view animated:(BOOL)animated;

@property (nonatomic, strong) TMView *leftView;
@property (nonatomic, strong) TMView *centerView;
@property (nonatomic, strong) TMView *rightView;


-(void)setConnectionState:(ConnectingStatusType)state;

@end
