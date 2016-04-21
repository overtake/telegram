

#import <Cocoa/Cocoa.h>
#import "TMNavigationBar.h"
#import "ConnectionStatusViewControllerView.h"
#import "TGSplitViewController.h"
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

@interface TMNavigationController : TGSplitViewController

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
-(void)showInfoPage:(TL_conversation *)conversation animated:(BOOL)animated;
-(void)showInfoPage:(TL_conversation *)conversation animated:(BOOL)animated isDisclosureController:(BOOL)isDisclosureController;
-(void)showMessagesViewController:(TL_conversation *)conversation;
-(void)showMessagesViewController:(TL_conversation *)conversation withMessage:(TL_localMessage *)message;
@end
