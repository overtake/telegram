//
//  TGViewController.m
//  TelegramModern
//
//  Created by keepcoder on 24.06.15.
//  Copyright (c) 2015 telegram. All rights reserved.
//

#import "TGViewController.h"
#import "TGInternalObject.h"
@interface TGViewController ()
{
    NSRect _frameRect;
    TGView *_view;
    id _internalId;
}
@end

@implementation TGViewController


-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _frameRect = frameRect;
        _internalId = [[TGInternalObject alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    // Do view setup here.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (void)loadView {
    if(!_view)
        _view = [[TGView alloc] initWithFrame: _frameRect];
    
}

- (TGView *)view {
    if(!_view)
        [self loadView];
    return _view;
}

-(id)internalId {
    return _internalId;
}

@end
