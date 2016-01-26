//
//  LeftViewController.h
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RightViewController.h"
#import "TelegramPopover.h"
#import "TGWindowArchiver.h"

#import "TGConversationsViewController.h"
#import "TGSplitViewController.h"
@interface LeftViewController : TGSplitViewController<TMSearchTextFieldDelegate,TMNavagationDelegate>


@property (nonatomic,strong) TGWindowArchiver *archiver;
@property (nonatomic,strong) NSView *buttonContainer;
@property (nonatomic, strong) TMSearchTextField *searchTextField;


@property (nonatomic, strong,readonly) TGConversationsViewController *conversationsViewController;

- (BOOL)isSearchActive;

-(NSResponder *)firstResponder;

-(void)onWriteMessageButtonClick;

-(void)updateSize;
-(BOOL)canMinimisize;
-(BOOL)isChatOpened;

-(TMViewController *)viewControllerAtTabIndex:(int)index;

-(TMViewController *)currentTabController;

-(void)showTabControllerAtIndex:(int)index;

-(void)setUnreadCount:(int)count;

-(void)showUserSettings;


-(void)updateForwardActionView;

-(void)didChangedLayout:(NSNotification *)notification;


@end
