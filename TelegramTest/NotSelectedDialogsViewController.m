//
//  NotSelectedDialogsViewController.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/28/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NotSelectedDialogsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TGCTextView.h"
@interface NotSelectedDialogsViewController()
@property (nonatomic,strong) NSTextView *hiddenView;
@end

@implementation NotSelectedDialogsViewController

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.isNavigationBarHidden = YES;
        
        
    }
    return self;
}

- (void) loadView {
    [super loadView];
    
    [self.view setWantsLayer:YES];
    
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    NSView *containerView = [[NSView alloc] init];
    [self.view addSubview:containerView];

    
    _hiddenView = [[NSTextView alloc] init];

    [self.view addSubview:_hiddenView];
    
    
    
    weak();
    
    [self.view setDrawBlock:^{
       [containerView setCenterByView:weakSelf.view];
    }];
    
    TMTextField *textField = [TMTextField defaultTextField];
    
    
    NSMutableParagraphStyle *mutParaStyle=[[NSMutableParagraphStyle alloc] init];
    [mutParaStyle setAlignment:NSCenterTextAlignment];
    [mutParaStyle setLineSpacing:3];
    [textField setAttributedStringValue:[[NSAttributedString alloc] initWithString:self.customTextCap.length > 0 ? self.customTextCap : NSLocalizedString(@"Conversation.SelectConversation", nil) attributes:@{NSForegroundColorAttributeName: DARK_GRAY, NSFontAttributeName: TGSystemFont(14)}]];
    [textField sizeToFit];
    
    [textField setDrawsBackground:NO];
    

    [containerView addSubview:textField];
    
    [containerView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinYMargin];
    [self.view setAutoresizesSubviews:YES];
    
    
    [containerView setFrameSize:textField.frame.size];
    
    [containerView setCenterByView:self.view];
    
}

- (CGSize)  fixSize:(CGSize) forSize{
    NSInteger w = (NSInteger) forSize.width;
    NSInteger h = (NSInteger) forSize.height;
    return CGSizeMake(w, h);
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
  //  [self.view.window makeFirstResponder:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecomeNotification:) name:NSWindowDidBecomeKeyNotification object:self.view.window];
    
   // [[Telegram leftViewController] becomeFirstResponder];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.view.window makeFirstResponder:nil];
//    });
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)windowBecomeNotification:(NSNotification *)notification {
  //  [self.view.window makeFirstResponder:self.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Telegram leftViewController].conversationsViewController resignFirstResponder];

    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view.window makeFirstResponder:nil];
    

}


@end
