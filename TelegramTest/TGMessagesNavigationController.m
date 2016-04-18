//
//  TGMessagesNavigationController.m
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGMessagesNavigationController.h"
#import "TGViewMessagesDragging.h"
@implementation TGMessagesNavigationController

@synthesize view = _view;

-(void)loadView {
    
    TGViewMessagesDragging *view = [[TGViewMessagesDragging alloc] initWithFrame:self.frameInit];
    
    view.navigationViewController = self;
    [view registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSStringPboardType,NSTIFFPboardType, nil]];

    
    _view = view;
    
    [super loadView];
    
    
    
}



- (TGView *)view {
    if(!_view)
        [self loadView];
    return (TGView *) _view;
}

@end
