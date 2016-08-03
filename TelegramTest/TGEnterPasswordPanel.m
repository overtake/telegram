//
//  TGEnterPasswordPanel.m
//  Telegram
//
//  Created by keepcoder on 01.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGEnterPasswordPanel.h"
#import <MtProtoKit/MTEncryption.h>
#import "UserInfoShortTextEditView.h"
#import "NSAttributedString+Hyperlink.h"
#import "TGSignalUtils.h"
#import "MessagesUtils.h"
@interface TGEnterPasswordPanel ()<NSTextFieldDelegate>

@property (nonatomic,strong) NSSecureTextField *secureField;
@property (nonatomic,strong) UserInfoShortTextEditView *emailCodeField;

@property (nonatomic,strong) TMTextButton *resetPass;
@property (nonatomic,strong) TMTextButton *logout;
@property (nonatomic,strong) TMTextButton *resetAccount;


@property (nonatomic,strong) TMView *enterPasswordContainer;
@property (nonatomic,strong) TMView *confirmEmailCodeContainer;
@property (nonatomic,strong) TMView *processDeletionView;

@property (nonatomic,strong) TMTextButton *backButton;

@property (nonatomic,strong) BTRButton *enterButton;
@property (nonatomic,strong) TMView *currentController;

@property (nonatomic,strong) TMTextField *resetAccountTimerField;
@property (nonatomic,strong) id <SDisposable> resetDisposable;
@property (nonatomic,strong) TMTextButton *resetWaitButton;

@property (nonatomic,strong) TMTextButton *waitLogoutButton;
@end

@implementation TGEnterPasswordPanel

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.backButton = [TMTextButton standartMessageNavigationButtonWithTitle:@"Back"];
        
        [self.backButton setHidden:YES];
        [self.backButton setFrameOrigin:NSMakePoint(20, NSHeight(frameRect) - NSHeight(self.backButton.frame) - 20)];
        
        weak();
        [self.backButton setTapBlock:^{
            [weakSelf switchControllers];
        }];
        
        _currentController = [self enterPasswordContainer];
        
        [self addSubview:[self enterPasswordContainer]];
        
        
        [self addSubview:self.backButton];
        
        self.backgroundColor = NSColorFromRGB(0xffffff);
    }
    
    return self;
}


-(TMView *)confirmEmailCodeContainer {
    if(_confirmEmailCodeContainer)
        return _confirmEmailCodeContainer;
    
    _confirmEmailCodeContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 300, 250)];
    

    
    _confirmEmailCodeContainer.isFlipped = YES;
    
    [_confirmEmailCodeContainer setCenterByView:self];
    
    
    _emailCodeField = [[UserInfoShortTextEditView alloc] initWithFrame:NSMakeRect(0, 0, 250, 30)];
    
    NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
    
    [attrs appendString:NSLocalizedString(@"Code", nil) withColor:DARK_GRAY];
    
    [attrs setAttributes:@{NSFontAttributeName:TGSystemFont(14)} range:attrs.range];
    
    [attrs setAlignment:NSCenterTextAlignment range:attrs.range];
    
    [_emailCodeField.textView.cell setPlaceholderAttributedString:attrs];
    
    [_emailCodeField.textView setAlignment:NSCenterTextAlignment];
    [_emailCodeField.textView setFrameOrigin:NSZeroPoint];
    
    [_emailCodeField setCenterByView:_confirmEmailCodeContainer];
    
    [_emailCodeField.textView setFont:TGSystemFont(14)];
    [_emailCodeField.textView setTextColor:DARK_BLACK];
    
    
    _emailCodeField.textView.delegate = self;
    
    [_emailCodeField.textView setBordered:NO];
    [_emailCodeField.textView setDrawsBackground:NO];
    [_emailCodeField setFocusRingType:NSFocusRingTypeNone];
    
    [_emailCodeField.textView setAction:@selector(checkCode)];
    [_emailCodeField.textView setTarget:self];
    
    [_emailCodeField setFrameOrigin:NSMakePoint(NSMinX(_emailCodeField.frame), 50)];
    
    [_confirmEmailCodeContainer addSubview:_emailCodeField];
    
    
    
    
    
    TMTextField *codeDescription = [TMTextField defaultTextField];
    
    [[codeDescription cell] setLineBreakMode:NSLineBreakByWordWrapping];
    
    [codeDescription setStringValue:NSLocalizedString(@"EnterPassword.EnterCodeDescription", nil)];
    
    
    [codeDescription setFont:TGSystemFont(13)];
    
    [codeDescription setTextColor:GRAY_TEXT_COLOR];
    
    [codeDescription setFrameSize:NSMakeSize(NSWidth(_emailCodeField.frame), 200)];
    
    [codeDescription setFrameOrigin:NSMakePoint(NSMinX(_emailCodeField.frame),  NSMaxY(_emailCodeField.frame) + 15)];
    
    [_confirmEmailCodeContainer addSubview:codeDescription];
    
    TMTextButton *troubleAccess = [[TMTextButton alloc] initWithFrame:NSZeroRect];
    
    troubleAccess.stringValue = [NSString stringWithFormat:NSLocalizedString(@"EnterPassword.TroubleEmailAccess", nil)];
    troubleAccess.textColor = BLUE_UI_COLOR;
    troubleAccess.font = TGSystemFont(12);
    
    [troubleAccess sizeToFit];
    
    [troubleAccess setCenterByView:_confirmEmailCodeContainer];
    
    
    
    [troubleAccess setFrameOrigin:NSMakePoint(NSMinX(_emailCodeField.frame), NSHeight(_confirmEmailCodeContainer.frame) - NSHeight(self.resetPass.frame) - 90)];
    
    
    [troubleAccess setTapBlock:^ {
        
        alert(NSLocalizedString(@"Alert.Sorry", nil), NSLocalizedString(@"EnterPassword.AlertTroubleEmailAccess", nil));
        
    }];
    
    
    [_confirmEmailCodeContainer addSubview:troubleAccess];

    
    
    return _confirmEmailCodeContainer;
}

-(TMView *)processDeletionView {
    
    if(_processDeletionView)
        return _processDeletionView;
    
    
    
    _processDeletionView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), NSHeight(self.frame))];
    _processDeletionView.isFlipped = YES;

    
    TMView *containerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 300, 240)];
    containerView.isFlipped = YES;
    [containerView setCenterByView:_processDeletionView];
    [_processDeletionView addSubview:containerView];
    
    TMTextField *descriptionField = [TMTextField defaultTextField];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:[NSString stringWithFormat:NSLocalizedString(@"Account.CancelResetDesc", nil),@""] withColor:TEXT_COLOR];
    [attr setAlignment:NSCenterTextAlignment range:attr.range];
    [attr setFont:TGSystemFont(13) forRange:attr.range];
    [attr detectBoldColorInStringWithFont:TGSystemMediumFont(13)];
    NSSize size = [attr sizeForTextFieldForWidth:300];
    
    
    [descriptionField setFrameSize:size];
    [descriptionField setAttributedString:attr];
    
    
    [containerView addSubview:descriptionField];
    
    _resetAccountTimerField = [TMTextField defaultTextField];
    
    [_resetAccountTimerField setFrameOrigin:NSMakePoint(0, NSMaxY(descriptionField.frame) + 10)];
    
    [containerView addSubview:_resetAccountTimerField];
    
    [descriptionField setCenteredXByView:containerView];
    
    
    _resetWaitButton = [self resetAccountButton];
    
    [_resetWaitButton setFrameOrigin:NSMakePoint(0, NSMaxY(descriptionField.frame) + NSHeight(_resetWaitButton.frame) + 20)];
    [_resetWaitButton setCenteredXByView:containerView];
    [containerView addSubview:_resetWaitButton];
    
//    _waitLogoutButton = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Password.logout", nil)];
//    
//    [_waitLogoutButton setFrameOrigin:NSMakePoint(NSWidth(_processDeletionView.frame) - NSWidth(_waitLogoutButton.frame) - 10, 10)];
//    
//    [_processDeletionView addSubview:_waitLogoutButton];
    
    
    [_processDeletionView setCenterByView:self];
    
    
    return _processDeletionView;
    
}

-(TMView *)enterPasswordContainer {
    
    if(_enterPasswordContainer)
        return _enterPasswordContainer;
    
    _enterPasswordContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 300, 340)];
    
    
    _enterPasswordContainer.isFlipped = YES;
    
    [_enterPasswordContainer setCenterByView:self];
    
    
    TMTextField *titleField = [TMTextField defaultTextField];
    
    
    [titleField setStringValue:NSLocalizedString(@"Password.EnterYourPassword", nil)];
    
    
    
    [titleField setFont:TGSystemFont(14)];
    
    [titleField setTextColor:DARK_BLACK];
    
    [titleField sizeToFit];
    
    
    [titleField setCenterByView:_enterPasswordContainer];
    
    [titleField setFrameOrigin:NSMakePoint(NSMinX(titleField.frame),  0)];
    
    [_enterPasswordContainer addSubview:titleField];
    
    
    self.secureField = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 250, 30)];
    
    NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
    
    [attrs appendString:NSLocalizedString(@"Password.password", nil) withColor:DARK_GRAY];
    
    [attrs setAttributes:@{NSFontAttributeName:TGSystemFont(14)} range:attrs.range];
    
    [attrs setAlignment:NSCenterTextAlignment range:attrs.range];
    
    [self.secureField.cell setPlaceholderAttributedString:attrs];
    
    [self.secureField setAlignment:NSCenterTextAlignment];
    
    [self.secureField setCenterByView:_enterPasswordContainer];
    
    [self.secureField setFont:TGSystemFont(14)];
    [self.secureField setTextColor:DARK_BLACK];
    
    [self.secureField setBordered:NO];
    [self.secureField setDrawsBackground:NO];
    [self.secureField setFocusRingType:NSFocusRingTypeNone];
    
    [self.secureField setAction:@selector(checkPassword)];
    [self.secureField setTarget:self];
    
    [self.secureField setFrameOrigin:NSMakePoint(NSMinX(self.secureField.frame), NSMaxY(titleField.frame) + 30)];
    
    [_enterPasswordContainer addSubview:self.secureField];
    
    
    
    self.enterButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_PasslockEnter().size.width, image_PasslockEnter().size.height)];
    
    [self.enterButton setImage:image_PasslockEnter() forControlState:BTRControlStateNormal];
    [self.enterButton setImage:image_PasslockEnterHighlighted() forControlState:BTRControlStateHover];
    
    weak();
    
    [self.enterButton addBlock:^(BTRControlEvents events) {
        
        strongWeak();
        
        if(strongSelf == weakSelf) {
            [strongSelf checkPassword];
        }
        
        
    } forControlEvents:BTRControlEventClick];
    
    
    [self.enterButton setFrameOrigin:NSMakePoint(NSMaxX(self.secureField.frame) - NSWidth(self.enterButton.frame), NSMinY(self.secureField.frame) - 3)];
    
    [self.enterPasswordContainer addSubview:self.enterButton];

    
    
    TMView *separator = [[TMView alloc] initWithFrame:self.secureField.frame];
    
    [separator setFrame:NSMakeRect(NSMinX(separator.frame), NSMinY(separator.frame) + NSHeight(self.secureField.frame) + 1, NSWidth(separator.frame), 1)];
    
    separator.backgroundColor = GRAY_BORDER_COLOR;
    
    [_enterPasswordContainer addSubview:separator];
    
    
    
    
    TMTextField *passwordDescription = [TMTextField defaultTextField];
    
    [[passwordDescription cell] setLineBreakMode:NSLineBreakByWordWrapping];
    
    [passwordDescription setStringValue:NSLocalizedString(@"EnterPassword.EnterPasswordDescription", nil)];
    
    
    [passwordDescription setFont:TGSystemFont(13)];
    
    [passwordDescription setTextColor:GRAY_TEXT_COLOR];
    
    [passwordDescription setFrameSize:NSMakeSize(NSWidth(separator.frame), 200)];
    
    [passwordDescription setFrameOrigin:NSMakePoint(NSMinX(separator.frame),  NSMaxY(separator.frame) + 15)];
    
    [_enterPasswordContainer addSubview:passwordDescription];
    
    
    
    self.resetPass = [[TMTextButton alloc] initWithFrame:NSZeroRect];
    
    self.resetPass.stringValue = NSLocalizedString(@"EnterPassword.forgotPassword", nil);
    self.resetPass.textColor = BLUE_UI_COLOR;
    self.resetPass.font = TGSystemFont(12);
    
    [self.resetPass sizeToFit];
    
    [self.resetPass setCenterByView:_enterPasswordContainer];
    
    
    [self.resetPass setFrameOrigin:NSMakePoint(NSMinX(self.resetPass.frame), NSHeight(_enterPasswordContainer.frame) - NSHeight(self.resetPass.frame) - 140)];
    
    
    [self.resetPass setTapBlock:^ {
        
        [TMViewController showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_auth_requestPasswordRecovery create] successHandler:^(RPCRequest *request, TL_auth_passwordRecovery *response) {
            
            
            [TMViewController hideModalProgressWithSuccess];
            
            alert(appName(), [NSString stringWithFormat:NSLocalizedString(@"Password.SentRecoryCode", nil),[response email_pattern]]);
            
            [weakSelf switchControllers];
            
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            [TMViewController hideModalProgress];
            
            if(error.error_code == 400) {
                alert(NSLocalizedString(@"Alert.Sorry", nil), NSLocalizedString(error.error_msg, nil));
                [weakSelf enableReset];
            }
            
            
            
        }  alwayContinueWithErrorContext:YES];
        
    }];
    
    
    [_enterPasswordContainer addSubview:self.resetPass];
    
    TMView *s2 = [[TMView alloc] initWithFrame:self.secureField.frame];
    
    [s2 setFrame:NSMakeRect(NSMinX(s2.frame), NSMaxY(self.resetPass.frame) + 15, NSWidth(s2.frame), 1)];
    
    s2.backgroundColor = GRAY_BORDER_COLOR;
    
    [_enterPasswordContainer addSubview:s2];
    
    self.resetAccount = [self resetAccountButton];
    [self.resetAccount setCenterByView:_enterPasswordContainer];
    [self.resetAccount setFrameOrigin:NSMakePoint(NSMinX(self.resetAccount.frame),  NSMaxY(self.resetPass.frame) + 30)];

    [_enterPasswordContainer addSubview:self.resetAccount];
    
    
    TMTextField *resetDescription = [TMTextField defaultTextField];
    
    [[resetDescription cell] setLineBreakMode:NSLineBreakByWordWrapping];
    
    [resetDescription setStringValue:NSLocalizedString(@"EnterPassword.ResetAccountDescription", nil)];
    
    
    [resetDescription setFont:TGSystemFont(13)];
    
    [resetDescription setTextColor:GRAY_TEXT_COLOR];
    
    [resetDescription setFrameSize:NSMakeSize(NSWidth(separator.frame), 200)];
    
    [resetDescription setFrameOrigin:NSMakePoint(NSMinX(separator.frame),  NSMaxY(self.resetAccount.frame) + 15)];
    
    [_enterPasswordContainer addSubview:resetDescription];
    
    [resetDescription setHidden:YES];
    [self.resetAccount setHidden:YES];
    
    
    [self.secureField setFrame:NSMakeRect(50, NSMinY(self.secureField.frame), NSWidth(self.secureField.frame) - 50, NSHeight(self.secureField.frame))];
    
    return _enterPasswordContainer;
}

-(TMTextButton *)resetAccountButton {
    TMTextButton *resetAccount = [[TMTextButton alloc] initWithFrame:NSZeroRect];
    
    resetAccount.stringValue = NSLocalizedString(@"EnterPassword.ResetAccount", nil);
    resetAccount.textColor = [NSColor redColor];
    resetAccount.font = TGSystemFont(14);
    
    [resetAccount sizeToFit];
    
    
    
    weak();
    
    [resetAccount setTapBlock:^ {
        
        confirm(NSLocalizedString(@"Alert.Warning", nil), NSLocalizedString(@"Password.ResetAlertDescription", nil), ^{
            
            [TMViewController showModalProgress];
            
            NSString *reason = @"Forgot password";
            
            if(isTestServer()) {
                reason = @"confirm";
            }
            
            [RPCRequest sendRequest:[TLAPI_account_deleteAccount createWithReason:reason] successHandler:^(RPCRequest *request, id response) {
                
                [[[MTNetwork instance] context] updatePasswordInputRequiredForDatacenterWithId:[[MTNetwork instance] currentDatacenter] required:NO];
                
                [[Telegram delegate] logoutWithForce:YES];
                
                
                [weakSelf hide];
                
                [TMViewController hideModalProgress];
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
                if([error.error_msg hasPrefix:@"2FA_RECENT_CONFIRM"]) {
                    alert(appName(), NSLocalizedString(error.error_msg, nil));
                } else if([error.error_msg hasPrefix:@"2FA_CONFIRM_WAIT"]) {
                    [weakSelf showResetWait:[[error.error_msg substringFromIndex:@"2FA_CONFIRM_WAIT_".length] intValue]];
                }
                
                
                [TMViewController hideModalProgress];
                
            } timeout:10];
            
        },nil);
        //
        
    }];
    
    return resetAccount;

}

-(void)showResetWait:(int)delayTime {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setHidden:YES];
    }];
    
    [self.processDeletionView setCenterByView:self];
    [self addSubview:self.processDeletionView];
    
    [self.processDeletionView setHidden:NO];
    _resetWaitButton.textColor = RED_COLOR;
    _resetWaitButton.disableColor = GRAY_TEXT_COLOR;

    _resetWaitButton.disable = YES;
    
    _resetDisposable = [[TGSignalUtils countdownSignal:delayTime delay:1] startWithNext:^(id next) {
        
        int until = [next intValue];
        
        NSString *timer = [MessagesUtils timerString:until];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        [attr appendString:timer withColor:TEXT_COLOR];
        [attr setFont:TGSystemFont(15) forRange:attr.range];
        [attr detectBoldColorInStringWithFont:TGSystemMediumFont(15)];
        
        [_resetAccountTimerField setAttributedString:attr];
        
        [_resetAccountTimerField sizeToFit];
        [_resetAccountTimerField setCenteredXByView:_resetAccountTimerField.superview];
        
        
        
    } completed:^{
        
        _resetWaitButton.disable = NO;
        
    }];
}


-(void)getHint {
    
    [RPCRequest sendRequest:[TLAPI_account_getPassword create] successHandler:^(id request, TL_account_password *response) {
        
        if([response isKindOfClass:[TL_account_password class]]) {
            NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
            
            [attrs appendString:response.hint.length > 0 ? response.hint : NSLocalizedString(@"Password.password", nil) withColor:DARK_GRAY];
            
            [attrs setAttributes:@{NSFontAttributeName:TGSystemFont(14)} range:attrs.range];
            
            [attrs setAlignment:NSCenterTextAlignment range:attrs.range];
            
            [self.secureField.cell setPlaceholderAttributedString:attrs];
        }
        
       
        
    } errorHandler:^(id request, RpcError *error) {
        
    } alwayContinueWithErrorContext:YES];
    
}

-(void)checkPassword {
    
    [TMViewController showModalProgress];
    
    [RPCRequest sendRequest:[TLAPI_account_getPassword create] successHandler:^(RPCRequest *request, id response) {
        
        
        if([response isKindOfClass:[TL_account_password class]]) {
            
            NSData *currentSalt = [response current_salt];
            
            NSMutableData *hashData = [NSMutableData dataWithData:currentSalt];
            
            [hashData appendData:[self.secureField.stringValue dataUsingEncoding:NSUTF8StringEncoding]];
            
            [hashData appendData:currentSalt];
            
            NSData *passhash =  MTSha256(hashData);
        
            
            [RPCRequest sendRequest:[TLAPI_auth_checkPassword createWithPassword_hash:passhash] successHandler:^(RPCRequest *request, id response) {
               
                [TMViewController hideModalProgressWithSuccess];
                
                [[[MTNetwork instance] context] updatePasswordInputRequiredForDatacenterWithId:[[MTNetwork instance] currentDatacenter] required:NO];
                [[Telegram sharedInstance] onAuthSuccess];
                
                [self hide];
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
                if(error.error_code == 400) {
                    [self.secureField performShake:^{
                        
                        [self.secureField setWantsLayer:NO];
                        [self.secureField.window makeFirstResponder:self.secureField];
                        [self.secureField setSelectionRange:NSMakeRange(0, self.secureField.stringValue.length)];
                        
                    }];
                }
                
                [TMViewController hideModalProgress];
                
            } timeout:10];
            
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        [TMViewController hideModalProgress];
        
    } alwayContinueWithErrorContext:YES];
}

-(void)checkCode {
    
    
    if(self.emailCodeField.textView.stringValue.length < 6)
        return;
    
    [TMViewController showModalProgress];
    
    [RPCRequest sendRequest:[TLAPI_auth_recoverPassword createWithCode:self.emailCodeField.textView.stringValue] successHandler:^(RPCRequest *request, id response) {
        
        [TMViewController hideModalProgressWithSuccess];
        [[[MTNetwork instance] context] updatePasswordInputRequiredForDatacenterWithId:[[MTNetwork instance] currentDatacenter] required:NO];
        [[Telegram sharedInstance] onAuthSuccess];
        
        [self hide];
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if(error.error_code == 400) {
            alert(appName(), NSLocalizedString(@"EnterPassword.BadEmailCode", nil));
        }
        
        [self.emailCodeField performShake:^{
            
            [self.emailCodeField.textView becomeFirstResponder];
            [self.emailCodeField.textView setSelectionRange:NSMakeRange(0, self.emailCodeField.textView.textView.string.length)];
            
        }];
        
        [TMViewController hideModalProgress];
        
    }  alwayContinueWithErrorContext:YES];
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(void)mouseUp:(NSEvent *)theEvent {
    
}

-(void)mouseEntered:(NSEvent *)theEvent {
    
}

-(void)mouseExited:(NSEvent *)theEvent {
    
}

-(void)keyDown:(NSEvent *)theEvent {
    [super keyDown:theEvent];
}

-(void)showEnterPassword {
    if(_currentController != [self enterPasswordContainer]) {
        [self switchControllers];
    }
}

-(void)prepare {
    [self.secureField setStringValue:@""];
    [self.window makeFirstResponder:self.secureField];
    
    [self getHint];
}

-(void)hide {
    [self removeFromSuperview];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    
    NSString *res = [[self.emailCodeField.textView.stringValue componentsSeparatedByCharactersInSet:
                      [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                     componentsJoinedByString:@""];
    
    res = [res substringWithRange:NSMakeRange(0, MIN(6, res.length))];
    
    [self.emailCodeField.textView setStringValue:res];
    
    if(res.length == 6) {
        [self checkCode];
    }
}

-(void)enableReset {
    [_enterPasswordContainer.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [obj setHidden:NO];
        
    }];
}

-(void)switchControllers {
    
    static BOOL locked = NO;
    
    [self enableReset];
    
    
    if(!locked) {
        
        locked = YES;
        
        TMView *nextController;
        
        BOOL next = NO;
        
        if(_currentController != [self enterPasswordContainer]) {
            nextController = [self enterPasswordContainer];
            next = YES;
        } else {
            nextController = [self confirmEmailCodeContainer];
            
        }
        
        [self.backButton setHidden:NO];
        [self.backButton setAlphaValue:next];
        
        [nextController setFrameOrigin:NSMakePoint(!next ? NSMaxX(_currentController.frame) : 0, NSMinY(nextController.frame))];
        
        [self addSubview:nextController];
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            [context setDuration:0.2];
            
            [[_currentController animator] setFrameOrigin:NSMakePoint(next ? NSMaxX(_currentController.frame) : 0, NSMinY(_currentController.frame))];
            
            [[_currentController animator] setAlphaValue:0];
            
            [[nextController animator] setFrameOrigin:NSMakePoint(roundf((NSWidth(self.frame) - NSWidth(nextController.frame)) / 2), NSMinY(nextController.frame))];
            
            [[nextController animator] setAlphaValue:1];
            
            [[self.backButton animator] setAlphaValue:!next];
            
        } completionHandler:^{
            
            [_currentController removeFromSuperview];
            
            [_currentController setAlphaValue:1];
            [nextController setAlphaValue:1];
            
            [self.backButton setHidden:next];
            _currentController = nextController;
            locked = NO;
            
            if(_currentController == [self enterPasswordContainer]) {
                [self.secureField becomeFirstResponder];
            } else {
                [self.emailCodeField becomeFirstResponder];
            }
            
        }];
    }
    
   
    
}

@end
