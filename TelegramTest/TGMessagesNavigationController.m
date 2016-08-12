//
//  TGMessagesNavigationController.m
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGMessagesNavigationController.h"
#import "TGViewMessagesDragging.h"
#import "TGInlineAudioPlayer.h"
#import "TGAudioPlayerWindow.h"
@interface TGMessagesNavigationController ()
@property (nonatomic,strong) TGInlineAudioPlayer *inlineAudioPlayer;
@end

@implementation TGMessagesNavigationController

@synthesize view = _view;

-(void)loadView {
    
    TGViewMessagesDragging *view = [[TGViewMessagesDragging alloc] initWithFrame:self.frameInit];
    
    view.navigationViewController = self;
    [view registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSStringPboardType,NSTIFFPboardType,NSURLPboardType, nil]];

    
    _view = view;
    
    [super loadView];
    
    
}

-(void)pushViewController:(TMViewController *)viewController animated:(BOOL)animated {
    
    [self updateInlinePlayer:viewController];
    
    [super pushViewController:viewController animated:animated];
}

-(void)goBackWithAnimation:(BOOL)animated {

    [super goBackWithAnimation:animated];
    
    [self updateInlinePlayer:self.currentController];

}

-(void)updateInlinePlayer:(TMViewController *)viewController  {
    [_inlineAudioPlayer setStyle:TGAudioPlayerGlobalStyleMini animated:NO];
    [_inlineAudioPlayer setFrameOrigin:NSMakePoint(0, NSHeight(self.view.frame) - (viewController.isNavigationBarHidden ? 0 : self.navigationOffset) - 50)];
}


-(void)showInlinePlayer:(TGAudioGlobalController *)controller {
    if(!_inlineAudioPlayer) {
        _inlineAudioPlayer = [[TGInlineAudioPlayer alloc] initWithFrame:NSMakeRect(0, NSHeight(self.view.frame) - self.navigationOffset - 50, NSWidth(self.view.frame), 50) globalController:controller];
        [self.view addSubview:_inlineAudioPlayer];
    }
    

    [self.inlineAudioPlayer show:controller ? controller.conversation : self.messagesViewController.conversation navigation:self];
    
    [self.currentController.view setFrameSize:NSMakeSize(NSWidth(self.currentController.view.frame), self.view.bounds.size.height - self.navigationOffset - self.viewControllerTopOffset)];
    
    
}

-(TGAudioGlobalController *)inlineController {
    return _inlineAudioPlayer.audioController;
}

-(void)hideInlinePlayer:(TGAudioGlobalController *)controller {
    
    [_inlineAudioPlayer removeFromSuperview];
    _inlineAudioPlayer = nil;
    
    [self.currentController.view setFrameSize:NSMakeSize(NSWidth(self.currentController.view.frame), self.view.bounds.size.height - self.navigationOffset)];
    
    
    if(controller) {
        [TGAudioPlayerWindow showWithController:controller];
    }
}

-(int)viewControllerTopOffset {
    return NSHeight(_inlineAudioPlayer.frame);
}





- (TGView *)view {
    if(!_view)
        [self loadView];
    return (TGView *) _view;
}

@end
