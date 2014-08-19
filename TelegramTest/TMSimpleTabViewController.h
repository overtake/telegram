//
//  TMSimpleTabViewController.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface TMSimpleTabViewController : TMViewController

@property (nonatomic, strong) TMViewController *currentController;


- (void)showController:(TMViewController *)viewController;
- (void)removeController:(TMViewController *)viewController;
- (void)addController:(TMViewController *)viewController;

@end
