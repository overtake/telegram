//
//  TMViewController.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/15/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMView.h"

@class TMPopover;
@class TMNavigationController;
@interface TMViewController : NSViewController
@property (nonatomic) NSRect frameInit;

@property (nonatomic, strong) TMView *leftNavigationBarView;
@property (nonatomic, strong) TMView *centerNavigationBarView;
@property (nonatomic, strong) TMView *rightNavigationBarView;

@property (nonatomic, strong) TMPopover *popover;

@property (nonatomic, strong) TMNavigationController *navigationViewController;
@property (nonatomic) BOOL isNavigationBarHidden;

- (id)initWithFrame:(NSRect)frame;
- (TMView *)view;
- (void)setHidden:(BOOL)isHidden;

- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;

- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (void)setLeftNavigationBarView:(TMView *)leftNavigationBarView animated:(BOOL)animation;
- (void)setRightNavigationBarView:(TMView *)rightNavigationBarView animated:(BOOL)animation;

- (void)rightButtonAction;


-(void)showModalProgress;
-(void)hideModalProgress;


@end
