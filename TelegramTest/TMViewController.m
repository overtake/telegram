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
    
    if(self.navigationViewController && self.navigationViewController.currentController == self)
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


- (void)viewWillAppear:(BOOL)animated {
    
    self.leftNavigationBarView = [self standartLeftBarView];
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
    
    if([[Telegram rightViewController] isModalViewActive]) {
        [[Telegram rightViewController] hideModalView:YES animation:YES];
    } else {
        [[Telegram rightViewController] navigationGoBack];
    }
}


static TMProgressModalView *progressView;
static TGPasslockModalView *passlockView;

+(void)showModalProgress {
    
    if(!progressView) {
        progressView = [[TMProgressModalView alloc] initWithFrame:[[[Telegram delegate] mainWindow].contentView bounds]];
        
        progressView.layer.opacity = 0;
        
        [progressView setCenterByView:[[Telegram delegate] mainWindow].contentView];
        
         [[[Telegram delegate] mainWindow].contentView addSubview:progressView];
    }
    
   
    
    [[[Telegram delegate] mainWindow] setAcceptEvents:NO];
    
    POPBasicAnimation *anim = [TMViewController popAnimationForProgress:progressView.layer.opacity to:0.8];
    
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


+(void)hideModalProgress {
    
    progressView.layer.opacity = 0.8;
    
    [(MainWindow *)[[Telegram delegate] mainWindow] setAcceptEvents:YES];
    
    POPBasicAnimation *anim = [TMViewController popAnimationForProgress:progressView.layer.opacity to:0];
    
    [anim setCompletionBlock:^(POPAnimation *anim, BOOL success) {
        [progressView removeFromSuperview];
        progressView = nil;
    }];
    
    [progressView.layer pop_addAnimation:anim forKey:@"fade"];

}

-(void)showModalProgress {
    [TMViewController showModalProgress];
}
-(void)hideModalProgress {
    [TMViewController hideModalProgress];
}

+(void)showPasslock:(passlockCallback)callback animated:(BOOL)animated {
    
    
    assert([NSThread isMainThread]);
    
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


+(void)hidePasslock {
    
    
    
    assert([NSThread isMainThread]);
    
    passlockView.layer.opacity = 0.8;
    
    
    POPBasicAnimation *anim = [TMViewController popAnimationForProgress:passlockView.layer.opacity to:0];
    
    [anim setCompletionBlock:^(POPAnimation *anim, BOOL success) {
        [passlockView removeFromSuperview];
        passlockView = nil;
    }];
    
    [passlockView.layer pop_addAnimation:anim forKey:@"fade"];
    
    [TGPasslock setVisibility:NO];
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

- (void)loadView {
    self.view = [[TMView alloc] initWithFrame: self.frameInit];

}

- (TMView *)view {
    if(!_view)
        [self loadView];
    return _view;
}

@end
