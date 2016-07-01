//
//  TGPopoverHint.m
//  Telegram
//
//  Created by keepcoder on 01/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGPopoverHint.h"
#import "TMMenuPopover.h"
@interface TGMessagesHintViewController : TMViewController
@property (nonatomic,strong) TGMessagesHintView *hintView;

@end

@implementation TGMessagesHintViewController

-(void)loadView {
    [super loadView];
    
    self.view.wantsLayer = YES;
    self.view.layer.cornerRadius = 4;
  //  self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    _hintView = [[TGMessagesHintView alloc] initWithFrame:self.view.bounds];
   // _hintView.wantsLayer = YES;
    
    
    [self.view addSubview:_hintView];
    
}

@end

@implementation TGPopoverHint


static TMMenuPopover *popover;
static TGMessagesHintViewController *hintController;


+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hintController = [[TGMessagesHintViewController alloc] initWithFrame:NSMakeRect(0, 0, 300, 140)];
        
        [hintController loadViewIfNeeded];
        
        popover = [[TMMenuPopover alloc] initWithController:(NSViewController *)hintController];
        popover.animates = NO;
        
    });
}

+(TGMessagesHintView *)showHintViewForView:(NSView *)view ofRect:(NSRect)rect {
    
//    [hintController.hintView setUpdateSizeHandler:^(NSSize newSize) {
//        
//        
//        [hintController.view setFrameSize:newSize];
//        // [popover close];
//        [popover showRelativeToRect:rect ofView:view preferredEdge:CGRectMaxYEdge];
//    }];
    
    [hintController.view setFrameSize:hintController.hintView.frame.size];
    
     [popover showRelativeToRect:rect ofView:view preferredEdge:CGRectMaxYEdge];
    
    return hintController.hintView;
}

+(void)close {
    [popover close];
    [hintController.hintView hide];
}

+(BOOL)isShown {
    return popover.isShown;
}

+(TGMessagesHintView *)hintView {
    return hintController.hintView;
}

@end
