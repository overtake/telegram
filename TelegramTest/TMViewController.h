//
//  TMViewController.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/15/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMView.h"
#import "TMTextField.h"
#import "TMNavigationBar.h"
#import "RBLPopover.h"
@class MessagesViewController;
@class TGAttachObject;
@class TMPopover;
@class TMNavigationController;
@interface TMViewController : NSObject
@property (nonatomic) NSRect frameInit;
@property (nonatomic,strong) TMView *view;
@property (nonatomic, strong) TMView *leftNavigationBarView;
@property (nonatomic, strong) TMView *centerNavigationBarView;
@property (nonatomic, strong) TMView *rightNavigationBarView;

@property (nonatomic,assign) BOOL isDisclosureController;

@property (nonatomic, strong) TMPopover *popover;

@property (nonatomic,strong,readonly) TMTextField *centerTextField;

@property (nonatomic, strong) TMNavigationController *navigationViewController;
@property (nonatomic,strong,readonly) TMNavigationBar *navigationBarView;

@property (nonatomic) BOOL isNavigationBarHidden;

- (id)initWithFrame:(NSRect)frame;
- (TMView *)view;
- (void)setHidden:(BOOL)isHidden;

-(TMNavigationController *)rightNavigationController;



- (void)setLeftNavigationBarView:(TMView *)leftNavigationBarView animated:(BOOL)animation;
- (void)setRightNavigationBarView:(TMView *)rightNavigationBarView animated:(BOOL)animation;

- (void)rightButtonAction;

+(void)showModalProgressWithDescription:(NSString *)description;
+(void)showModalProgress;
+(void)hideModalProgress;


-(void)showModalProgressWithWindow:(NSWindow *)window;

-(void)showModalProgress;
-(void)hideModalProgress;

-(void)hideModalProgressWithSuccess;
+(void)hideModalProgressWithSuccess;


+(void)showPasslock:(passlockCallback)callback;
+(void)hidePasslock;

-(void)showPasslock:(passlockCallback)callback;
-(void)hidePasslock;


+(void)showCreatePasslock:(passlockCallback)callback;
-(void)showCreatePasslock:(passlockCallback)callback;

+(void)showChangePasslock:(passlockCallback)callback;
-(void)showChangePasslock:(passlockCallback)callback;


+(void)showBlockPasslock:(passlockCallback)callback;
-(void)showBlockPasslock:(passlockCallback)callback;

+(void)closeAllModals;

+(POPBasicAnimation *)popAnimationForProgress:(float)from to:(float)to;

+(void)showAttachmentCaption:(NSArray *)attachments onClose:(dispatch_block_t)onClose;
+(void)hideAttachmentCaption;

+(BOOL)isModalActive;
+(NSArray *)modalsView;

+(void)hideAllModals;

+(TMView *)modalView;
+(void)becomeFirstResponderToModalView;

+(void)becomePasslock;

-(void)_didStackRemoved;

-(BOOL)becomeFirstResponder;
-(BOOL)resignFirstResponder;
- (void)loadViewIfNeeded;
- (void)loadView;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;

- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

-(TMView *)standartLeftBarView;

-(TMView *)standartRightBarView;

-(BOOL)proccessEnterAction;
-(BOOL)proccessEscAction;

-(void)setCenterBarViewText:(NSString *)text;
-(void)setCenterBarViewTextAttributed:(NSAttributedString *)text;

-(MessagesViewController *)messagesViewController;

-(void)becomeFirstResponder:(BOOL)force;

-(void)addSubview:(NSView *)subview;


@end
