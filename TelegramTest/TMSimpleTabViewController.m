//
//  TMSimpleTabViewController.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMSimpleTabViewController.h"

@interface TMSimpleTabViewController ()
@property (nonatomic, strong) NSMutableArray *controllers;
@end

@implementation TMSimpleTabViewController

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)init {
    self = [super init];
    if(self) {
        [self initialize];
    }
    return self;
}



- (void)initialize {
    self.controllers = [[NSMutableArray alloc] init];
    self.currentController = nil;
}

- (void)loadView {
    [super loadView];
    
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
}

- (void)addController:(TMViewController *)viewController {
    [self.controllers addObject:viewController];
}

- (void)insertController:(TMViewController *)viewController atIndex:(int)index {
     [self.controllers insertObject:viewController atIndex:index];
}

- (TMViewController *)contollerAtIndex:(int)index {
    return self.controllers[index];
}

- (void)removeController:(TMViewController *)viewController {
    [self.controllers removeObject:viewController];
}

- (void)showControllerByIndex:(NSUInteger)index {
    
    if( index >= self.controllers.count )
        return;
    
    [self showController:self.controllers[index]];
}

- (void)showController:(TMViewController *)viewController {
    
    
    if(self.currentController) {
        [self.currentController viewWillDisappear:NO];
        [self.currentController.view removeFromSuperview];
        [self.currentController viewDidDisappear:NO];
    }
    
    self.currentController = viewController;
    
    [self.currentController.view setFrame:self.view.bounds];
    [self.currentController viewWillAppear:NO];
    [self.view addSubview:self.currentController.view];
    [self.currentController viewDidAppear:NO];
}

@end
