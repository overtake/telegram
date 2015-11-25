// DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
// Version 2, December 2004
//
// Copyright (C) 2013 Ilija Tovilo <support@ilijatovilo.ch>
//
// Everyone is permitted to copy and distribute verbatim or modified
// copies of this license document, and changing it is allowed as long
// as the name is changed.
//
// DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
// TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
//
// 0. You just DO WHAT THE FUCK YOU WANT TO.

//
//  ITNavigationView.h
//  ITNavigationView
//
//  Created by Ilija Tovilo on 2/27/13.
//  Copyright (c) 2013 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMNavigationBar.h"
#import "ConnectionStatusViewControllerView.h"

@class MessagesViewController;

@protocol TMNavagationDelegate <NSObject>

-(void)willChangedController:(TMViewController *)controller;
-(void)didChangedController:(TMViewController *)controller;

@end


#ifndef ITNavigationViewTypedef
#define ITNavigationViewTypedef

typedef enum {
    TMNavigationControllerStylePush,
    TMNavigationControllerStylePop,
    TMNavigationControllerStyleNone
} TMNavigationControllerAnimationStyle;

#endif

@interface TMNavigationController : TMViewController

@property (nonatomic, strong) TMNavigationBar *nagivationBarView;

@property (nonatomic, strong) TMViewController *currentController;
@property (nonatomic, strong) NSMutableArray *viewControllerStack;

@property (nonatomic) TMNavigationControllerAnimationStyle animationStyle;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;

@property (nonatomic, readonly) BOOL isLocked;


@property (nonatomic,weak) MessagesViewController *messagesViewController;

-(void)gotoViewController:(TMViewController *)controller;
-(void)gotoViewController:(TMViewController *)controller animated:(BOOL)animated;
-(void)gotoViewController:(TMViewController *)controller back:(BOOL)back;
-(void)gotoViewController:(TMViewController *)controller back:(BOOL)back animated:(BOOL)animated;

-(void)addDelegate:(id<TMNavagationDelegate>)delegate;
-(void)removeDelegate:(id<TMNavagationDelegate>)delegate;
- (void)pushViewController:(TMViewController *)viewController animated:(BOOL)animated;
- (void)goBackWithAnimation:(BOOL)animated;
- (void)clear;

-(void)gotoEmptyController;

-(void)showInfoPage:(TL_conversation *)conversation;
-(void)showMessagesViewController:(TL_conversation *)conversation;
-(void)showMessagesViewController:(TL_conversation *)conversation withMessage:(TL_localMessage *)message;
@end
