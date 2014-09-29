//
//  RBLViewController.m
//  Rebel
//
//  Created by Colin Wheeler on 10/29/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLViewController.h"
#import "NSView+RBLViewControllerAdditions.h"

@interface RBLViewController ()

@property (nonatomic, strong) NSView *currentView;

@end

@implementation RBLViewController

+ (instancetype)viewController {
	return [[self alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)dealloc {
	if (_currentView.rbl_viewController == self) {
		_currentView.rbl_viewController = nil;
	}
	_currentView = nil;
}

- (void)loadView {
	[super loadView];
	[self viewDidLoad];
}

- (void)setView:(NSView *)view {
	super.view = view;
	self.view.rbl_viewController = self;

	if (_currentView.rbl_viewController == self) {
		_currentView.rbl_viewController = nil;
	}
	_currentView = view;
}

- (void)viewDidLoad {
}

- (void)viewWillAppear {
}

- (void)viewDidAppear {
}

- (void)viewWillDisappear {
}

- (void)viewDidDisappear {
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
}

- (void)viewDidMoveToSuperview {
}

- (void)viewWillBeRemovedFromSuperview {
}

- (void)viewWasRemovedFromSuperview {
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
}

- (void)viewDidMoveToWindow {
}

- (void)viewWillBeRemovedFromWindow {
}

- (void)viewWasRemovedFromWindow {
}

@end
