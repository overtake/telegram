//
//  TGModernSGViewController.m
//  Telegram
//
//  Created by keepcoder on 20/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernSGViewController.h"
#import "TGStickerPackEmojiController.h"
#import "TGModernESGViewController.h"
@interface TGModernSGViewController ()
@property (nonatomic,strong) TGStickerPackEmojiController *stickersView;
@property (nonatomic,strong) BTRButton *showGSControllerView;
@end

@implementation TGModernSGViewController

-(void)loadView {
    [super loadView];
    
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = NSViewHeightSizable;
    
    _stickersView = [[TGStickerPackEmojiController alloc] initWithFrame:self.view.bounds packHeight:_esgViewController.isLayoutStyle ? 58 : 44];
    _stickersView.stickers.messagesViewController = _esgViewController.messagesViewController;
    
  //  [_stickersView.stickers load:NO]; 
    
  
    [self.view addSubview:_stickersView];
    
    
    _showGSControllerView = [[BTRButton alloc] initWithFrame:NSZeroRect];
    
    [_showGSControllerView setTitle:NSLocalizedString(@"EGS.Emoji", nil) forControlState:BTRControlStateNormal];
    [_showGSControllerView setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
    [_showGSControllerView setTitleFont:TGSystemMediumFont(13) forControlState:BTRControlStateNormal];
    
    [_showGSControllerView.titleLabel sizeToFit];
    
    [_showGSControllerView setFrame:NSMakeRect(NSWidth(self.view.frame) - NSWidth(_showGSControllerView.titleLabel.frame) - 10, NSHeight(self.view.frame) - NSHeight(_showGSControllerView.titleLabel.frame) - 8, NSWidth(_showGSControllerView.titleLabel.frame), 20)];
    
    _showGSControllerView.autoresizingMask = NSViewMinYMargin;
    
    weak();
    
    [_showGSControllerView addBlock:^(BTRControlEvents events) {
        
        [weakSelf.esgViewController.navigationViewController goBackWithAnimation:YES];
        
    } forControlEvents:BTRControlEventClick];
    [self.view addSubview:_showGSControllerView];
}

-(void)reloadStickers {
    [_stickersView.stickers load:YES];
}

-(void)setEsgViewController:(TGModernESGViewController *)esgViewController {
    _esgViewController = esgViewController;
    _stickersView.stickers.messagesViewController = _esgViewController.messagesViewController;
    _stickersView.esgViewController = esgViewController;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self show];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self close];
}

-(void)show {

    [_stickersView reload];

}

-(void)close {
    [_stickersView removeAllItems];
}

@end
