//
//  NSView+NSView_RBLViewControllerAdditions.m
//  Rebel
//
//  Created by Colin Wheeler on 10/29/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSView+RBLViewControllerAdditions.h"
#import "RBLViewController.h"
#import "NSObject+RBObjectSizzlingAdditions.h"
#import <objc/runtime.h>

void *kRBLViewControllerKey = &kRBLViewControllerKey;

@implementation NSView (NSView_RBLViewControllerAdditions)

#pragma mark - ViewController

- (id)rbl_viewController {
	return objc_getAssociatedObject(self, kRBLViewControllerKey);
}

- (void)setRbl_viewController:(id)newViewController {
	[NSView loadSupportForRBLViewControllers];

	if (self.rbl_viewController) {
		NSResponder *controllerNextResponder = [self.rbl_viewController nextResponder];
		[self custom_setNextResponder:controllerNextResponder];
		[self.rbl_viewController setNextResponder:nil];
	}

	objc_setAssociatedObject(self, kRBLViewControllerKey, newViewController, OBJC_ASSOCIATION_ASSIGN);

	if (newViewController) {
		NSResponder *ownResponder = [self nextResponder];
		[self custom_setNextResponder:self.rbl_viewController];
		[self.rbl_viewController setNextResponder:ownResponder];
	}
}

#pragma mark - View Controller Methods

+ (void)loadSupportForRBLViewControllers {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		//swizzle swizzle...
		[self rbl_swapMethod:@selector(viewWillMoveToSuperview:) with:@selector(custom_viewWillMoveToSuperview:)];
		[self rbl_swapMethod:@selector(viewDidMoveToSuperview) with:@selector(custom_viewDidMoveToSuperview)];

		[self rbl_swapMethod:@selector(viewWillMoveToWindow:) with:@selector(custom_viewWillMoveToWindow:)];
		[self rbl_swapMethod:@selector(viewDidMoveToWindow) with:@selector(custom_viewDidMoveToWindow)];

		[self rbl_swapMethod:@selector(setNextResponder:) with:@selector(custom_setNextResponder:)];
	});
}

- (void)custom_viewWillMoveToSuperview:(NSView *)newSuperview {
	[self custom_viewWillMoveToSuperview:newSuperview];
	
	if ([self.rbl_viewController isKindOfClass:[RBLViewController class]]) {
		if (newSuperview == nil) {
			[(RBLViewController *)self.rbl_viewController viewWillBeRemovedFromSuperview];
			
			if ((self.superview != nil) && (self.window != nil)) {
				[(RBLViewController	*)self.rbl_viewController viewWillDisappear];
			}
		} else {
			[(RBLViewController *)self.rbl_viewController viewWillMoveToSuperview:newSuperview];
			
			if (self.window != nil) {
				[(RBLViewController *)self.rbl_viewController viewWillAppear];
			}
		}
	}
}

- (void)custom_viewDidMoveToSuperview {
	[self custom_viewDidMoveToSuperview];
	
	if ([self.rbl_viewController isKindOfClass:[RBLViewController class]]) {
		if (self.superview == nil) {
			[(RBLViewController *)self.rbl_viewController viewWasRemovedFromSuperview];
			
			if (self.window == nil) {
				[(RBLViewController *)self.rbl_viewController viewDidDisappear];
			}
		} else {
			[(RBLViewController *)self.rbl_viewController viewDidMoveToSuperview];
			
			if (self.window != nil) {
				[(RBLViewController *)self.rbl_viewController viewDidAppear];
			}
		}
	}
}

- (void)custom_viewWillMoveToWindow:(NSWindow *)newWindow {
	[self custom_viewWillMoveToWindow:newWindow];
	
	if ([self.rbl_viewController isKindOfClass:[RBLViewController class]]) {
		if (newWindow == nil) {
			[(RBLViewController *)self.rbl_viewController viewWillBeRemovedFromWindow];
			
			if ((self.superview != nil) && (self.window != nil)) {
				[(RBLViewController *)self.rbl_viewController viewWillDisappear];
			}
		} else {
			[(RBLViewController *)self.rbl_viewController viewWillMoveToWindow:newWindow];
			
			if (self.superview != nil) {
				[(RBLViewController *)self.rbl_viewController viewWillAppear];
			}
		}
	}
}

- (void)custom_viewDidMoveToWindow {
	[self custom_viewDidMoveToWindow];
	
	if ([self.rbl_viewController isKindOfClass:[RBLViewController class]]) {
		if (self.window == nil) {
			[(RBLViewController *)self.rbl_viewController viewWasRemovedFromWindow];
			
			if (self.superview == nil) {
				[(RBLViewController *)self.rbl_viewController viewDidDisappear];
			}
		} else {
			[(RBLViewController *)self.rbl_viewController viewDidMoveToWindow];
			
			if (self.superview != nil) {
				[(RBLViewController *)self.rbl_viewController viewDidAppear];
			}
		}
	}
}

- (void)custom_setNextResponder:(NSResponder *)newNextResponder {
	if (self.rbl_viewController != nil) {
		[self.rbl_viewController setNextResponder:newNextResponder];
		return;
	}
	
	[self custom_setNextResponder:newNextResponder];
}

@end
