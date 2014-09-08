//
//  LeftViewController.h
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RightViewController.h"
#import "DialogsViewController.h"
#import "TelegramPopover.h"
#import "NewConversationViewController.h"
#import "TGWindowArchiver.h"
@interface LeftViewController : TMViewController<TMSearchTextFieldDelegate>



@property (nonatomic,strong) TGWindowArchiver *archiver;
@property (nonatomic,strong) NSView *buttonContainer;
@property (nonatomic, strong) TMSearchTextField *searchTextField;
- (BOOL)isSearchActive;

-(NSResponder *)firstResponder;

-(void)onWriteMessageButtonClick;

-(void)updateSize;
-(BOOL)canMinimisize;

- (void)showNewConversationPopover:(NewConversationAction)action;
- (void)showNewConversationPopover:(NewConversationAction)action toButton:(id)button;
- (void)showNewConversationPopover:(NewConversationAction)action filter:(NSArray *)filter target:(id)target selector:(SEL)selector toButton:(id)button title:(NSString *)title;
@end
