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
    if(self = [super init]) {
        _frameRect = frameRect;
        _internalId = [[TGInternalObject alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    // Do view setup here.
}
- (void)viewWillAppear:(BOOL)animated {
    
}
- (void)viewDidAppear:(BOOL)animated {
    
}
- (void)viewWillDisappear:(BOOL)animated {
    
}
- (void)viewDidDisappear:(BOOL)animated {
    
}


- (void)loadView {
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
