//
//  TMViewController.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/15/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "TMView.h"
#import "TMProgressModalView.h"
#import "HackUtils.h"
#import "TGPasslockModalView.h"
#import "TGPasslock.h"
#import "TGModalSetCaptionView.h"
#import "TGModalView.h"
#import "TGHeadChatPanel.h"
@interface TMViewController ()
@property (nonatomic,strong) TMProgressModalView *progressView;
@property (nonatomic,strong) TMBackButton *backButton;

@end

@implementation TMViewController

- (id)initWithFrame:(NSRect)frame {
    self = [super init];
    if(self) {
        self.frameInit = frame;
    }
    return self;
}

-(instancetype)init {
    if(self = [super init]) {
        self.frameInit = NSZeroRect;
    }
    
    return self;
}

- (void) setHidden:(BOOL)isHidden {
    [self.view setHidden:isHidden];
}

- (void)setCenterNavigationBarView:(TMView *)centerNavigationBarView {
    [self setCenterNavigationBarView:centerNavigationBarView animated:NO];
}

- (void)setCenterNavigationBarView:(TMView *)centerNavigationBarView animated:(BOOL)animation {
    self->_centerNavigationBarView = centerNavigationBarView;
    
    if(self.navigationViewController && self.navigationViewController.currentController == self)
        [self.navigationViewController.nagivationBarView setCenterView:centerNavigationBarView animated:animation];
}

- (void)setLeftNavigationBarView:(TMView *)leftNavigationBarView {
    [self setLeftNavigationBarView:leftNavigationBarView animated:NO];
}

- (void)setLeftNavigationBarView:(TMView *)leftNavigationBarView animated:(BOOL)animation {
    self->_leftNavigationBarView = leftNavigationBarView;
    
    [self.navigationViewController.nagivationBarView setLeftView:leftNavigationBarView animated:animation];
}

- (void)setRightNavigationBarView:(TMView *)rightNavigationBarView {
    [self setRightNavigationBarView:rightNavigationBarView animated:NO];
}

- (void)setRightNavigationBarView:(TMView *)rightNavigationBarView animated:(BOOL)animation {
    self->_rightNavigationBarView = rightNavigationBarView;
    
    if(self.navigationViewController && self.navigationViewController.currentController == self)
        [self.navigationViewController.nagivationBarView setRightView:rightNavigationBarView animated:animation];
}

-(TMView *)standartLeftBarView {
    
//    if([Telegram isSingleLayout] && [Telegram rightViewController].navigationViewController.viewControllerStack.count == 1)
//    {
//        return nil;
//    }
    
    if(self.backButton)
    {
        [self.backButton updateBackButton];
        
    } else {
        self.backButton = [[TMBackButton alloc] initWithFrame:NSZeroRect string:NSLocalizedString(@"Compose.Back", nil)];
        // self.leftNavigationBarView = [[TMView alloc] initWithFrame:self.backButton.bounds];
        
        self.backButton.controller = self;
        
        [self.backButton updateBackButton];
    }
    
    return (TMView *) self.backButton;
}


-(void)setCenterBarViewText:(NSString *)text {
    
    
    if(!_centerTextField) {
        _centerTextField = [TMTextField defaultTextField];
        [_centerTextField setAlignment:NSCenterTextAlignment];
        [_centerTextField setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
        [_centerTextField setFont:TGSystemFont(15)];
        [_centerTextField setTextColor:NSColorFromRGB(0x222222)];
        [[_centerTextField cell] setTruncatesLastVisibleLine:YES];
        [[_centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [_centerTextField setDrawsBackground:NO];
        
        
        TMView *centerView = [[TMView alloc] initWithFrame:NSZeroRect];
        
        
        self.centerNavigationBarView = centerView;
        
        [centerView addSubview:_centerTextField];
    }
    
    [_centerTextField setStringValue:text];
    
    
    [_centerTextField sizeToFit];
    
    [_centerTextField setCenterByView:self.centerNavigationBarView];
    
    [_centerTextField setFrameOrigin:NSMakePoint(_centerTextField.frame.origin.x, 13)];
}


-(void)setCenterBarViewTextAttributed:(NSAttributedString *)text {
    [self setCenterBarViewText:@""];
    
    [_centerTextField setAttributedStringValue:text];
    
    [_centerTextField sizeToFit];
    
    [_centerTextField setCenterByView:self.centerNavigationBarView];
    
    [_centerTextField setFrameOrigin:NSMakePoint(_centerTextField.frame.origin.x, 13)];
}


- (void)viewWillAppear:(BOOL)animated {
    
    [self becomeFirstResponder];
    
    self.leftNavigationBarView = [self standartLeftBarView];
    
    if(self.navigationViewController == [Telegram rightViewController].navigationViewController)
    {
        if([Telegram isSingleLayout] && [Telegram rightViewController].currentEmptyController == [Telegram rightViewController].navigationViewController.currentController && ![[Telegram rightViewController] isModalViewActive])
        {
            self.leftNavigationBarView = nil;
        }
    }
    
}



- (void)viewDidAppear:(BOOL)animated {
    [[Telegram sharedInstance] makeFirstController:self];
}
- (void)viewWillDisappear:(BOOL)animated {
    
}
- (void)viewDidDisappear:(BOOL)animated {

}

- (void)rightButtonAction {
    
}

- (IBAction)backOrClose:(NSMenuItem *)sender {
    if(self.popover) {
        [self.popover close];
        self.popover = nil;
        return;
    }
    
    if([[Telegram rightViewController] isModalViewActive] && ![Telegram isSingleLayout]) {
        [[Telegram rightViewController] hideModalView:YES animation:YES];
    } else {
        [[Telegram rightViewController] navigationGoBack];
    }
}


static TMProgressModalView *progressView;
static TGPasslockModalView *passlockView;
static TGModalSetCaptionView *setCaptionView;

+(void)showModalProgress {
    
    if(!progressView) {
        progressView = [[TMProgressModalView alloc] initWithFrame:[appWindow().contentView bounds]];
        
        progressView.layer.opacity = 0;
        
        [progressView setCenterByView:appWindow().contentView];
        
         [appWindow().contentView addSubview:progressView];
    }
    
   
    
    [[[Telegram delegate] mainWindow] setAcceptEvents:NO];
    
    POPBasicAnimation *anim = [TMViewController popAnimationForProgress:progressView.layer.opacity to:0.8];
    
    [progressView.layer pop_addAnimation:anim forKey:@"fade"];
    
}

+(void)showModalProgressWithDescription:(NSString *)description {
    [self showModalProgress];
    
    [progressView setDescription:description];
}

+(void)hideModalProgress {
    
    //  progressView.layer.opacity = 0.8;
    
    [(MainWindow *)[[Telegram delegate] window] setAcceptEvents:YES];
    
    POPBasicAnimation *anim = [TMViewController popAnimationForProgress:progressView.layer.opacity to:0];
    
    [anim setCompletionBlock:^(POPAnimation *anim, BOOL success) {
        [progressView removeFromSuperview];
        progressView = nil;
    }];
    
    [progressView.layer pop_addAnimation:anim forKey:@"fade"];
    
}

+(POPBasicAnimation *)popAnimationForProgress:(float)from to:(float)to {
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.fromValue = @(from);
    anim.toValue = @(to);
    anim.duration = 0.2;
    anim.removedOnCompletion = YES;
    
    return anim;
}


+(void)showAttachmentCaption:(NSArray *)attachments onClose:(dispatch_block_t)onClose {
    
    if(!setCaptionView) {
        
        setCaptionView = [[TGModalSetCaptionView alloc] initWithFrame:[[[Telegram delegate] window].contentView bounds]];
        
        setCaptionView.layer.opacity = 0;
        
        
        
        [setCaptionView setCenterByView:[[Telegram delegate] window].contentView];
        
        [[[Telegram delegate] window].contentView addSubview:setCaptionView];
    } else {
        return;
    }
    
    setCaptionView.onClose = onClose;
    
    [setCaptionView prepareAttachmentViews:attachments];
    
    [setCaptionView becomeFirstResponder];
    
    POPBasicAnimation *anim = [TMViewController popAnimationForProgress:setCaptionView.layer.opacity to:1];
    
    [setCaptionView.layer pop_addAnimation:anim forKey:@"fade"];
    
}

+(void)hideAttachmentCaption {
    
    
    POPBasicAnimation *anim = [TMViewController popAnimationForProgress:progressView.layer.opacity to:0];
    
    [anim setCompletionBlock:^(POPAnimation *anim, BOOL success) {
                
        [setCaptionView removeFromSuperview];
        setCaptionView = nil;
    }];
    
    if(setCaptionView.layer.pop_animationKeys.count == 0)
        [setCaptionView.layer pop_addAnimation:anim forKey:@"fade"];
    
    
}

+(BOOL)isModalActive {
    __block BOOL res = NO;
    
    NSView *view = [[Telegram delegate] window].contentView;
    
    [view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if(obj == progressView || obj == passlockView || obj == setCaptionView || [obj isKindOfClass:[TGModalView class]]) {
            res = YES;
            *stop = YES;
        }
        
    }];
    
    return res;
}


+(NSArray *)modalsView {
    
    NSView *view = [[Telegram delegate] window].contentView;
    
    NSMutableArray *modals = [[NSMutableArray alloc] init];
    
    
    [view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([obj isKindOfClass:[TGModalView class]]) {
            [modals addObject:obj];
        }
        
    }];
    
    return modals;
}

+(TMView *)modalView {
    __block TMView *res;
    
    NSView *view = [[Telegram delegate] window].contentView;
    
    [view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if(obj == progressView || obj == passlockView || obj == setCaptionView || [obj isKindOfClass:[TGModalView class]]) {
            res = obj;
            *stop = YES;
        }
        
    }];
    
    return res;
}

-(void)hideModalProgressWithSuccess {
    [TMViewController hideModalProgressWithSuccess];
}

+(void)hideModalProgressWithSuccess {
    
    [progressView successAction];
    
    dispatch_after_seconds(0.5, ^{
        
        [self hideModalProgress];
        
    });
    
}

-(void)showModalProgress {
    if(!progressView) {
        progressView = [[TMProgressModalView alloc] initWithFrame:[self.view.window.contentView bounds]];
        
        progressView.layer.opacity = 0;
        
        [progressView setCenterByView:self.view.window.contentView];
        
        [self.view.window.contentView addSubview:progressView];
    }
    
    
    
    [(TelegramWindow *)self.view.window setAcceptEvents:NO];
    
    POPBasicAnimation *anim = [TMViewController popAnimationForProgress:progressView.layer.opacity to:0.8];
    
    [progressView.layer pop_addAnimation:anim forKey:@"fade"];
}
-(void)hideModalProgress {
    [TMViewController hideModalProgress];
}

+(void)showPasslock:(passlockCallback)callback animated:(BOOL)animated {
    
    [TGHeadChatPanel lockAllControllers];
    assert([NSThread isMainThread]);
    
    if(passlockView.window)
        return;
    
    if(!passlockView) {
        passlockView = [[TGPasslockModalView alloc] initWithFrame:[[[Telegram delegate] mainWindow].contentView bounds]];
        
        if(animated)
            passlockView.layer.opacity = 0;
        
        [passlockView setCenterByView:[[Telegram delegate] mainWindow].contentView];
        
        [[[Telegram delegate] mainWindow].contentView addSubview:passlockView];
    }
    
    passlockView.passlockResult = callback;
    passlockView.type = TGPassLockViewConfirmType;
    
    if(animated) {
        POPBasicAnimation *anim = [TMViewController popAnimationForProgress:passlockView.layer.opacity to:1];
        
        [passlockView.layer pop_addAnimation:anim forKey:@"fade"];
    }
    
    [TGPasslock setVisibility:YES];
    
    
    [passlockView becomeFirstResponder];
}


+(void)showPasslock:(passlockCallback)callback {
    [self showPasslock:callback animated:YES];
}

+(void)showCreatePasslock:(passlockCallback)callback {
    [self showPasslock:callback];
    passlockView.type = TGPassLockViewCreateType;
}

-(void)showCreatePasslock:(passlockCallback)callback {
    [TMViewController showCreatePasslock:callback];
}

+(void)showChangePasslock:(passlockCallback)callback {
    [self showPasslock:callback];
    passlockView.type = TGPassLockViewChangeType;
}
-(void)showChangePasslock:(passlockCallback)callback {
    [TMViewController showChangePasslock:callback];
}

+(void)showBlockPasslock:(passlockCallback)callback {
     [self showPasslock:callback animated:NO];
     [passlockView setClosable:NO];
}
-(void)showBlockPasslock:(passlockCallback)callback {
    [TMViewController showBlockPasslock:callback];
}
+(void)becomePasslock {
    [passlockView becomeFirstResponder];
}

+(void)hidePasslock {
    
    [TGHeadChatPanel unlockAllControllers];
    
    assert([NSThread isMainThread]);
    
    passlockView.layer.opacity = 0.8;
    
    
    POPBasicAnimation *anim = [TMViewController popAnimationForProgress:passlockView.layer.opacity to:0];
    
    [anim setCompletionBlock:^(POPAnimation *anim, BOOL success) {
        [passlockView removeFromSuperview];
        passlockView = nil;
    }];
    
    [passlockView.layer pop_addAnimation:anim forKey:@"fade"];
    
    [TGPasslock setVisibility:NO];
    
    [[Telegram rightViewController].navigationViewController.currentController viewWillAppear:NO];
}

-(void)showPasslock:(passlockCallback)callback {
    [TMViewController showPasslock:callback];
}

-(void)hidePasslock {
    [TMViewController hidePasslock];
}


-(void)_didStackRemoved {
    
}

-(BOOL)becomeFirstResponder {
    
    return [TGPasslock isVisibility] ? [passlockView becomeFirstResponder] : [self.view becomeFirstResponder];
}

-(BOOL)resignFirstResponder {
    return [self.view resignFirstResponder];
}

- (void)loadView {
    if(!_view)
        self.view = [[TMView alloc] initWithFrame: self.frameInit];

}

- (void)loadViewIfNeeded {
    [self view];
}

- (TMView *)view {
    if(!_view)
        [self loadView];
    return _view;
}

-(MessagesViewController *)messagesViewController {
    return self.navigationViewController.messagesViewController;
}

@end
