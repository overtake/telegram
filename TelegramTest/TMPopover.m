//
//  TMPopover.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMPopover.h"

@implementation TMPopover

- (id)initWithViewController:(TMViewController *)viewController {
    self = [super init];
    if(self) {
        self.viewController = viewController;
        self.viewController.popover = self;
        [self setBehavior:NSPopoverBehaviorTransient];
        [self setContentSize:viewController.view.frame.size];
        [self setContentViewController:viewController];
        [self setContentSize:viewController.view.frame.size];
    }
    return self;
}

- (void)showRelativeToView:(NSView *)view {
    [self.viewController viewWillAppear:NO];
    [self showRelativeToRect:[view bounds] ofView:view preferredEdge:NSMinYEdge];
    [self.viewController viewDidAppear:YES];
}

- (void)close {
    [self.viewController viewWillDisappear:NO];
    [super close];
    [self.viewController viewDidDisappear:NO];
}

@end
