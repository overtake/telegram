//
//  UserNameViewController.m
//  Telegram
//
//  Created by keepcoder on 15.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserNameViewController.h"
#import "UserInfoShortTextEditView.h"
@interface UserNameViewController ()<NSTextFieldDelegate>
@property (nonatomic,strong) UserInfoShortTextEditView *textView;
@property (nonatomic,strong) TMTextButton *button;
@end

@implementation UserNameViewController

-(void)loadView {
    [super loadView];
    
    self.view.isFlipped = YES;
    
    TMTextField* centerTextField = [TMTextField defaultTextField];
    [centerTextField setAlignment:NSCenterTextAlignment];
    [centerTextField setAutoresizingMask:NSViewWidthSizable];
    [centerTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:16]];
    [centerTextField setTextColor:NSColorFromRGB(0x222222)];
    [[centerTextField cell] setTruncatesLastVisibleLine:YES];
    [[centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [centerTextField setDrawsBackground:NO];
    
    [centerTextField setStringValue:NSLocalizedString(@"Profile.Username", nil)];
    
    [centerTextField setFrameOrigin:NSMakePoint(centerTextField.frame.origin.x, -12)];
    
    
    self.centerNavigationBarView = (TMView *) centerTextField;
    
    TMBackButton *backButton = [[TMBackButton alloc] initWithFrame:NSZeroRect string:NSLocalizedString(@"Compose.Back", nil)];
    self.leftNavigationBarView = [[TMView alloc] initWithFrame:backButton.bounds];
    [self.leftNavigationBarView addSubview:backButton];
    
    self.textView = [[UserInfoShortTextEditView alloc] initWithFrame:NSMakeRect(100, 80, NSWidth(self.view.frame) - 200, 23)];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    
    [str appendString:NSLocalizedString(@"UserName.placeHolder", nil) withColor:DARK_GRAY];
    [str setAlignment:NSLeftTextAlignment range:str.range];
    [str setFont:[NSFont fontWithName:@"HelveticaNeue" size:16] forRange:str.range];
    
    [[self.textView textView].cell setPlaceholderAttributedString:str];
    [[self.textView textView] setPlaceholderPoint:NSMakePoint(2, 0)];
    
    self.textView.textView.delegate = self;
    
    
    [self.view addSubview:self.textView];
    
    [self.textView.textView setFrameOrigin:NSMakePoint(0, NSMinY(self.textView.textView.frame))];
  
    
    TMTextField *description = [TMTextField defaultTextField];
    
    
    [description setStringValue:NSLocalizedString(@"UserName.description", nil)];
    
    [description setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
    
    [description sizeToFit];
    
    
    [description setFrame:NSMakeRect(100, 110, NSWidth(description.frame), NSHeight(description.frame))];
    
    [self.view addSubview:description];
    
    
    
    TMTextButton *button = [[TMTextButton alloc] initWithFrame:NSMakeRect(100, 110+NSHeight(description.frame)+10, 150, 20)];
    

    
    [button setStringValue:NSLocalizedString(@"Username.setName", nil)];
    
    [button setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
    
    [button setTextColor:BLUE_UI_COLOR];
    
    [button setDisableColor:NSColorFromRGB(0x999999)];
    
    [button sizeToFit];
    
    [button setTapBlock:^{
        
    }];
    
    self.button = button;
    
    [self.view addSubview:button];
    
}

- (void)controlTextDidChange:(NSNotification *)obj {
    [self.button setDisable:self.textView.textView.stringValue.length < 5];
}


-(void)viewDidAppear:(BOOL)animated {
    [self.textView.textView setStringValue:@""];
    [self.textView becomeFirstResponder];
    [self controlTextDidChange:nil];
}

@end
