//
//  TGModernESGViewController.m
//  Telegram
//
//  Created by keepcoder on 20/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernESGViewController.h"

@interface TGModernESGViewController ()

@end

@implementation TGModernESGViewController

-(void)loadView {
    [super loadView];
    
    self.view.wantsLayer = YES;
    self.view.layer.cornerRadius = 4;
    
    self.navigationViewController = [[TMNavigationController alloc] initWithFrame:self.view.bounds];
    
    self.navigationViewController.view.wantsLayer = YES;
    
    [self.view addSubview:self.navigationViewController.view];
    
    _emojiViewController = [[TGModernEmojiViewController alloc] initWithFrame:self.view.bounds];
    _sgViewController = [[TGModernSGViewController alloc] initWithFrame:self.view.bounds];
    
    _emojiViewController.esgViewController = self;
    _sgViewController.esgViewController = self;
    _emojiViewController.isNavigationBarHidden = YES;
    _sgViewController.isNavigationBarHidden = YES;

    
   
}

-(void)setMessagesViewController:(MessagesViewController *)messagesViewController {
    _messagesViewController = messagesViewController;
    _emojiViewController.messagesViewController = messagesViewController;
}

-(void)show {
    [self.navigationViewController.viewControllerStack removeAllObjects];
    [self.navigationViewController pushViewController:_emojiViewController animated:NO];
}

-(void)showSGController:(BOOL)animated {
    [self.navigationViewController pushViewController:_sgViewController animated:animated];
}

-(void)close {
    [_emojiViewController close];
    [_sgViewController close];
}

-(void)setEpopover:(RBLPopover *)epopover {
    _epopover = epopover;
    _emojiViewController.epopover = epopover;
}

@end
