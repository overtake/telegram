//
//  PhoneChangeConfirmController.m
//  Telegram
//
//  Created by keepcoder on 29.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhoneChangeConfirmController.h"
#import "UserInfoShortTextEditView.h"
#import "TGTimer.h"
@interface PhoneChangeConfirmController ()<NSTextFieldDelegate>
@property (nonatomic,strong) TMTextField *centerTextField;
@property (nonatomic,strong) TL_account_sentChangePhoneCode *params;
@property (nonatomic,strong) UserInfoShortTextEditView *smsCodeView;
@property (nonatomic,strong) TGTimer *callTimer;
@property (nonatomic,strong) TMTextField *callTextField;
@property (nonatomic,strong) TMTextField *descTextField;


@end

@implementation PhoneChangeConfirmController

- (void)loadView {
    [super loadView];
    
    self.view.isFlipped = YES;
    
    [self setCenterBarViewText:NSLocalizedString(@"PhoneChangeController.Header", nil)];

    self.smsCodeView = [[UserInfoShortTextEditView alloc] initWithFrame:NSMakeRect(100, 30, self.view.frame.size.width-200, 35)];
    
    
    self.smsCodeView.textView.font = TGSystemFont(13);
    
    NSAttributedString *smsCodePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PhoneChangeController.SmsPlaceholder", nil) attributes:@{NSFontAttributeName:TGSystemFont(13), NSForegroundColorAttributeName:GRAY_TEXT_COLOR}];
    
    
    [self.smsCodeView.textView.cell setPlaceholderAttributedString:smsCodePlaceholder];
    
    [self.smsCodeView.textView setFrameOrigin:NSMakePoint(0, NSMinY(self.smsCodeView.textView.frame))];
    
    [self.smsCodeView.textView setDelegate:self];
    
    
    [self.view addSubview:self.smsCodeView];
    
    
    self.descTextField = [TMTextField defaultTextField];
    
    [self.descTextField setStringValue:NSLocalizedString(@"PhoneChangeConfirmController.SentCodeDescription", nil)];
    
    
    [self.descTextField sizeToFit];
    
    [self.descTextField setFrameOrigin:NSMakePoint(100, 70)];
    
    [self.view addSubview:self.descTextField];
    
    
    self.callTextField = [TMTextField defaultTextField];
    
    [self.callTextField setStringValue:NSLocalizedString(@"PhoneChangeConfirmController.SentCodeDescription", nil)];
    
    [self.callTextField setTextColor:GRAY_TEXT_COLOR];
    
    [self.callTextField sizeToFit];
    
    [self.callTextField setFrameOrigin:NSMakePoint(100, 90)];
    
    [self.view addSubview:self.callTextField];
    

    TMTextButton *doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"PhoneChangeController.Next", nil)];
    [doneButton setTapBlock:^{
        
        [self showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_account_changePhone createWithPhone_number:self.centerTextField.stringValue phone_code_hash:self.params.phone_code_hash phone_code:self.smsCodeView.textView.stringValue] successHandler:^(RPCRequest *request, id response) {
            
            [self hideModalProgress];
            
            if([response isKindOfClass:[TL_userSelf class]]) {
                
                [[UsersManager sharedManager] add:@[response]];
                
                [[Telegram rightViewController] showAboveController:[Telegram rightViewController].phoneChangeAlertController];
            } else {
                alert(@"Error", @"Please try again.");
            }
            
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            if(error.error_code == 400) {
                alert(NSLocalizedString(@"PhoneChangeControlller.AlertHeader", nil), NSLocalizedString(error.error_msg, nil));
            }
            
            [self hideModalProgress];
            
        } timeout:10];
        
    }];
    
    
    [self setRightNavigationBarView:(TMView *)doneButton animated:NO];
    
}

- (void)setChangeParams:(TL_account_sentChangePhoneCode *)params phone:(NSString *)phone {
    if(!self.view)
        [self loadView];
    
    _params = params;
    
    [self.centerTextField setStringValue:phone];
    [self.smsCodeView.textView setStringValue:@""];
    
    [self startTimer];
    
}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.callTimer invalidate];
    self.callTimer = nil;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.view.window makeFirstResponder:self.smsCodeView.textView];
    
    [self.smsCodeView.textView becomeFirstResponder];
}




-(void)startTimer {
    
    self.callTimer = [[TGTimer alloc] initWithTimeout:1.0 repeat:YES completion:^{
        
        --self.params.send_call_timeout;
        
        if(self.params.send_call_timeout == 0) {
           [self.callTimer invalidate];
            self.callTimer = nil;
        }
        
        [self updateCallTime];
        
    } queue:[ASQueue mainQueue].nativeQueue];
    
    [self.callTimer start];
    
    [self updateCallTime];
}

-(void)updateCallTime {
    
    if(self.params.send_call_timeout > 0) {
         [self.callTextField setStringValue:[NSString stringWithFormat:NSLocalizedString(@"PhoneChangeConfirmController.sendCall", nil), [NSString durationTransformedValue:self.params.send_call_timeout]]];
    } else {
        [self.callTextField setStringValue:NSLocalizedString(@"PhoneChangeConfirmController.phoneDialed", nil)];
    }
    
}

-(void)controlTextDidChange:(NSNotification *)obj {
    self.smsCodeView.textView.stringValue = [self.smsCodeView.textView.stringValue stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.smsCodeView.textView.stringValue.length)];
    
    self.smsCodeView.textView.stringValue = [self.smsCodeView.textView.stringValue substringWithRange:NSMakeRange(0, MIN(5,self.smsCodeView.textView.stringValue.length))];
}


@end
