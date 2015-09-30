//
//  TGPasswordSetViewController.m
//  Telegram
//
//  Created by keepcoder on 27.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGPasswordSetViewController.h"
#import "UserInfoShortTextEditView.h"




@interface TGPasswordEmailViewController ()<NSTextFieldDelegate>

@property (nonatomic,strong) UserInfoShortTextEditView *textView;
@property (nonatomic,strong) TMTextField *descriptionField;
@property (nonatomic,strong) TMTextButton *skipButton;
@end

@implementation TGPasswordEmailViewController



-(void)loadView {
    [super loadView];
    
    
    self.view.isFlipped = YES;
    
    
    
    
    TMTextButton *doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"PasswordSettings.Next", nil)];
    
    
    weak();
    
    [doneButton setTapBlock:^{
        
        BOOL res = weakSelf.action.callback(self.textView.textView.stringValue);
        
        
        if(!res)
        {
            [self performShake];
        }
        
    }];
    
    
    
    [self setRightNavigationBarView:(TMView *)doneButton animated:NO];
    
    
    self.textView = [[UserInfoShortTextEditView alloc] initWithFrame:NSMakeRect(100, 80, NSWidth(self.view.frame) - 200, 23)];
    
    
    self.textView.textView.delegate = self;
    
    [self.view addSubview:self.textView];
    
    [self.textView.textView setAction:@selector(performEnter)];
    [self.textView.textView setTarget:self];
    [self.textView.textView setFrameOrigin:NSMakePoint(0, NSMinY(self.textView.textView.frame))];
    
    self.descriptionField = [TMTextField defaultTextField];
    
    
    [self.descriptionField setFrame:NSMakeRect(100, 110, NSWidth(self.view.frame) - 200, 300)];
    [[self.descriptionField cell] setLineBreakMode:NSLineBreakByWordWrapping];
    
    [self.view addSubview:self.descriptionField];
    
    
    self.skipButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"PasswordSettings.Skip", nil)];

    [self.skipButton setTapBlock:^{
       
        confirm(NSLocalizedString(@"PasswordSettings.SkipAlert", nil), NSLocalizedString(@"PasswordSettings.SkipAlertDescription", nil), ^{
            
            weakSelf.action.callback(nil);
            
        },^{
            
            
        });
        
    }];
    
    [self.skipButton sizeToFit];
    
    [self.skipButton setFrameOrigin:NSMakePoint(NSWidth(self.view.frame) - NSWidth(self.skipButton.frame) - 15, NSHeight(self.view.frame) - NSHeight(self.skipButton.frame) - 60)];
    
    [self.view addSubview:self.skipButton];
}

-(void)performEnter {
    
    BOOL res = self.action.callback(self.textView.textView.stringValue);
    
    
    if(!res)
    {
        [self performShake];
    }
}

-(void)performShake {
    [self.textView.textView performShake:^{
        [self.textView.textView setWantsLayer:NO];
        [self.textView.textView.window makeFirstResponder:self.textView.textView];
        [self.textView.textView setSelectionRange:NSMakeRange(0, self.textView.textView.stringValue.length)];
    }];
}

-(void)setAction:(TGSetPasswordAction *)action {
    _action = action;
    
    
    if(!self.view)
    {
        [self loadView];
    }
    
    
    [self.skipButton setHidden:!action.hasButton];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    
    [str appendString:action.title withColor:DARK_GRAY];
    [str setAlignment:NSLeftTextAlignment range:str.range];
    [str setFont:TGSystemFont(15) forRange:str.range];
    
    [[self.textView textView].cell setPlaceholderAttributedString:str];
    
    if(action.defaultValue) {
        
        [self.textView.textView setStringValue:action.defaultValue];
        
    }
    
    [self.descriptionField setStringValue:action.desc];
    
    [self setCenterBarViewText:action.header ?: action.title];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView.textView becomeFirstResponder];
    [self.textView.textView setSelectionRange:NSMakeRange(0, self.textView.textView.stringValue.length)];
    
}

@end
