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


- (void)showControllerByIndex:(NSUInteger)index;

- (void)showController:(TMViewController *)viewController;
- (void)removeController:(TMViewController *)viewController;
- (void)addController:(TMViewController *)viewController;
- (void)insertController:(TMViewController *)viewController atIndex:(int)index;
- (TMViewController *)contollerAtIndex:(int)index;

@end
