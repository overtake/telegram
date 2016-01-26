//
//  NewLoginViewController.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NewLoginViewController.h"
#import "LoginCountrySelectorView.h"
#import "TMAttributedString.h"
#import "RMPhoneFormat.h"
#import "LoginButtonAndErrorView.h"
#import "LoginSMSCodeView.h"
#import "RegistrationViewController.h"
#import "LoginBottomView.h"

@interface NewLoginViewController()

@property (nonatomic, strong) TMView *containerView;
@property (nonatomic, strong) NSImageView *logoImageView;

@property (nonatomic, strong) LoginCountrySelectorView *countrySelectorView;
@property (nonatomic, strong) LoginButtonAndErrorView *getSMSCodeView;
@property (nonatomic, strong) LoginSMSCodeView *SMSCodeView;
@property (nonatomic, strong) LoginButtonAndErrorView *startMessagingView;

@property (nonatomic, strong) TMTextField *SMSCodePlaceholder;
@property (nonatomic, strong) TMTextField *numberPlaceholder;
@property (nonatomic, strong) TMTextField *countryPlaceholder;

@property (nonatomic,strong) LoginBottomView *bottomView;

@property (nonatomic) BOOL isCodeExpired;

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *phone_code_hash;
@property (nonatomic) BOOL isPhoneRegistered;


@end

@implementation NewLoginViewController

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isNavigationBarHidden = YES;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self.view setBackgroundColor:[NSColor whiteColor]];
    
    self.containerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 432, 380)];
    [self.containerView setCenterByView:self.view];
    [self.containerView setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin | NSViewMaxXMargin | NSViewMaxYMargin];
    [self.view addSubview:self.containerView];
    
    self.logoImageView = [[NSImageView alloc] init];
    self.logoImageView.image = [NSImage imageNamed:@"TelegramIcon"];
    [self.logoImageView setFrameSize:self.logoImageView.image.size];
    [self.logoImageView setFrameOrigin:NSMakePoint(22, self.containerView.bounds.size.height - self.logoImageView.bounds.size.height)];
    [self.containerView addSubview:self.logoImageView];
    
    TMTextField *applicationNameTextField = [TMTextField defaultTextField];
    applicationNameTextField.stringValue = NSLocalizedString(@"App.Name", nil);
    applicationNameTextField.font = TGSystemLightFont(28);
    applicationNameTextField.textColor = NSColorFromRGB(0x333333);
    [applicationNameTextField sizeToFit];
    applicationNameTextField.wantsLayer = IS_RETINA;
    [applicationNameTextField setFrameOrigin:NSMakePoint(120, self.containerView.bounds.size.height - 8 - applicationNameTextField.bounds.size.height)];
    [self.containerView addSubview:applicationNameTextField];
    
    
    TMHyperlinkTextField *applicationInfoTextField = [TMHyperlinkTextField defaultTextField];
    applicationInfoTextField.wantsLayer = IS_RETINA;
    applicationInfoTextField.url_delegate = self;
    NSMutableAttributedString *applicationInfoAttributedString = [[NSMutableAttributedString alloc] init];
    [applicationInfoAttributedString appendString:NSLocalizedString(@"Login.Label", nil) withColor:NSColorFromRGB(0x9b9b9b)];
    [applicationInfoAttributedString appendString:@" "  withColor:NSColorFromRGB(0x9b9b9b)];
  //  NSRange range = [applicationInfoAttributedString appendString:NSLocalizedString(@"Telegram Messenger", nil) withColor:BLUE_UI_COLOR];
  //  [applicationInfoAttributedString setLink:@"telegram_site" forRange:range];
    
  //  [applicationInfoAttributedString appendString:@".\n"  withColor:NSColorFromRGB(0x9b9b9b)];
   // [applicationInfoAttributedString appendString:NSLocalizedString(@"Login.Description", nil) withColor:NSColorFromRGB(0x9b9b9b)];
    
    [applicationInfoAttributedString setFont:TGSystemFont(13) forRange:applicationInfoAttributedString.range];
    
    NSMutableParagraphStyle *applicationInfoParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [applicationInfoParagraphStyle setLineSpacing:2];
    [applicationInfoAttributedString addAttribute:NSParagraphStyleAttributeName value:applicationInfoParagraphStyle range:applicationInfoAttributedString.range];

    applicationInfoTextField.attributedStringValue = applicationInfoAttributedString;
    [applicationInfoTextField sizeToFit];
    [applicationInfoTextField setFrameOrigin:NSMakePoint(120, applicationNameTextField.frame.origin.y - 8 - applicationInfoTextField.bounds.size.height)];
    
    [self.containerView addSubview:applicationInfoTextField];

    float offsetY = applicationInfoTextField.frame.origin.y - 90 - 60;
    
    //SMSCODEVIew
    self.SMSCodeView = [[LoginSMSCodeView alloc] initWithFrame:NSMakeRect(0, offsetY-32, self.containerView.bounds.size.width, 80)];
    [self.SMSCodeView setLoginController:self];
    [self.SMSCodeView setHidden:YES];
    TMView *SMSCodeViewContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.containerView.bounds.size.width, offsetY + 40)];
//    [SMSCodeViewContainer setWantsLayer:YES];
    [SMSCodeViewContainer addSubview:self.SMSCodeView];
    [self.containerView addSubview:SMSCodeViewContainer];
    
     weakify();
    
    //COUTRYVIew
    self.countrySelectorView = [[LoginCountrySelectorView alloc] initWithFrame:NSMakeRect(0, offsetY, self.containerView.bounds.size.width, 90)];
    
    [self.countrySelectorView setNextCallback:^{
        [strongSelf getSMSCode];
    }];
    
    [self.countrySelectorView setBackCallback:^{
        [strongSelf performBackEditAnimation:0.08];
    }];
    
    [self.containerView addSubview:self.countrySelectorView];
    
    
   
    
    
    self.startMessagingView = [[LoginButtonAndErrorView alloc] initWithFrame:NSMakeRect(120, 12, self.view.bounds.size.width - 110, 50)];
//    [self.startMessagingView setBackgroundColor:[NSColor redColor]];
    [self.containerView addSubview:self.startMessagingView];
    [self.startMessagingView.textButton setTapBlock:^{
        [strongSelf signIn];
    }];
    
    [self.startMessagingView setHasImage:YES];
    
    [self.startMessagingView setHidden:YES];
    
    self.startMessagingView.textButton.layer.opacity = 0;

    
    self.getSMSCodeView = [[LoginButtonAndErrorView alloc] initWithFrame:NSMakeRect(120, 16, self.view.bounds.size.width - 110, 100)];
    //    [self.getSMSCodeView setBackgroundColor:[NSColor redColor]];
    [self.getSMSCodeView setButtonText:NSLocalizedString(@"Login.GetCode", nil)];
    [self.getSMSCodeView.textButton setTapBlock:^{
        [strongSelf getSMSCode];
    }];
    
    [self.containerView addSubview:self.getSMSCodeView];
    
 //   [self.containerView setBackgroundColor:[NSColor greenColor]];

    
    float offset = 121;
    self.SMSCodePlaceholder = [TMTextField loginPlaceholderTextField];
    self.SMSCodePlaceholder.stringValue = NSLocalizedString(@"Login.SmsCode", nil);
    self.SMSCodePlaceholder.layer.opacity = 0;
    [self.SMSCodePlaceholder sizeToFit];
    
    
    TMView *view = [[TMView alloc] initWithFrame:NSMakeRect(self.containerView.bounds.size.width - self.SMSCodePlaceholder.bounds.size.width - 330, offset, self.SMSCodePlaceholder.bounds.size.width + 100, self.SMSCodePlaceholder.bounds.size.height)];
//    [view setBackgroundColor:[NSColor redColor]];
    [view setWantsLayer:YES];
    [view addSubview:self.SMSCodePlaceholder];
    [self.containerView addSubview:view];
    
    
    offset += 55;
    self.numberPlaceholder = [TMTextField loginPlaceholderTextField];
    self.numberPlaceholder.stringValue = NSLocalizedString(@"Login.PhonePlaceholder", nil);
    [self.numberPlaceholder sizeToFit];
    [self.numberPlaceholder setFrameOrigin:NSMakePoint(self.containerView.bounds.size.width - self.numberPlaceholder.bounds.size.width - 330, offset)];
    [self.containerView addSubview:self.numberPlaceholder];

    offset += 50;
    self.countryPlaceholder = [TMTextField loginPlaceholderTextField];
    self.countryPlaceholder.stringValue = NSLocalizedString(@"Login.Country", nil);
    [self.countryPlaceholder sizeToFit];
    [self.countryPlaceholder setFrameOrigin:NSMakePoint(self.containerView.bounds.size.width - self.countryPlaceholder.bounds.size.width - 330, offset)];
    [self.containerView addSubview:self.countryPlaceholder];
    
    
    self.bottomView = [[LoginBottomView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.bounds), 100)];
    
    self.bottomView.loginController = self;
    
    [self.bottomView setHidden:YES];
    
    [self.view addSubview:self.bottomView];
}

- (void)signIn {
    if(self.isCodeExpired) {
        [self performBackEditAnimation:0.00001];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getSMSCodeSendRequest];
            [self.SMSCodeView performBlocking:NO];
        });
        return;
    }
    
    if(![self.SMSCodeView isValidCode]) {
        [self.SMSCodeView performShake];
        return;
    }
    
//    [self.startMessagingView showErrorWithText:nil];
    [self.startMessagingView prepareForLoading];
    
    [self.SMSCodeView performBlocking:YES];
    
    [RPCRequest sendRequest:[TLAPI_auth_signIn createWithPhone_number:self.phoneNumber phone_code_hash:self.phone_code_hash phone_code:self.SMSCodeView.code] successHandler:^(RPCRequest *request, id response) {
        
        [self.bottomView stopTimer];
        [[Telegram sharedInstance] onAuthSuccess];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        if([error.error_msg isEqualToString:@"SESSION_PASSWORD_NEEDED"]) {
            
            return;
        }
        
        
        if([error.error_msg isEqualToString:@"PHONE_CODE_EXPIRED"]) {
            [self.startMessagingView showErrorWithText:NSLocalizedString(@"Login.ExpiredCode", nil)];
            [self.startMessagingView setButtonText:NSLocalizedString(@"Login.GetNewCode", nil)];
            [self.bottomView stopTimer];
            [self.startMessagingView loadingSuccess];
            self.isCodeExpired = YES;
            return;
        }
        
        if(![error.error_msg isEqualToString:@"PHONE_NUMBER_UNOCCUPIED"]) {
            if([error.error_msg isEqualToString:@"PHONE_CODE_INVALID"] || [error.error_msg isEqualToString:@"PHONE_CODE_EMPTY"])
                error.error_msg = NSLocalizedString(@"Login.InvalidCode", nil);
            
            [self.startMessagingView showErrorWithText:error.error_msg];
            [self.SMSCodeView performBlocking:NO];
            [self.startMessagingView loadingSuccess];
            return;
        }
        
//        [self.SMSCodeView performBlocking:NO];
        [self.bottomView stopTimer];

        
        RegistrationViewController *r = [[RegistrationViewController alloc] initWithFrame:self.view.bounds];
        r.phoneNumber = self.phoneNumber;
        r.phone_code_hash = self.phone_code_hash;
        r.phone_code = self.SMSCodeView.code;
        [self.navigationViewController pushViewController:r animated:YES];
    } alwayContinueWithErrorContext:YES];
}

- (void)setIsPhoneRegistered:(BOOL)isPhoneRegistered {
    self->_isPhoneRegistered = isPhoneRegistered;
    
    [self.startMessagingView setButtonText:isPhoneRegistered ? NSLocalizedString(@"Registration.StartMessaging", nil) : NSLocalizedString(@"Registration.Continue", nil)];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.countrySelectorView becomeFirstResponder];
    [self.SMSCodeView performBlocking:NO];
    [self.bottomView stopTimer];
    [self.startMessagingView loadingSuccess];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    if(self.phoneNumber) {
        [self performBackEditAnimation:0];
    }
    [self.bottomView setHidden:YES];
    [self.startMessagingView setHasImage:NO];
    
    
}


- (void)getSMSCode {
//    if(!self.countrySelectorView.isValidPhoneNumber) {
//        [self.getSMSCodeView showErrorWithText:nil];
//        [self.countrySelectorView performShake];
//        return;
//    }
    
    [self.countrySelectorView performBlocking:YES];
    self.phoneNumber = [self.countrySelectorView phoneNumber];
    [self getSMSCodeSendRequest];
}

- (void)performSMSCodeTextFieldShowAnimation {
    [self.countrySelectorView performBlocking:YES];
    [self.countrySelectorView showEditButton:YES];
    
    float duration = 0.08;
//    float duration = 2;
//    [self.startMessagingView setButtonText:@"lah"];
    
    [self.getSMSCodeView performTextToBottomWithDuration:duration];
    
   
   // [self.bottomView setFrameSize:NSMakeSize(NSWidth(self.SMSCodeView.frame), self.bottomView.isAppCodeSent ? 140 : 80)];
    
   // [self.startMessagingView setBackgroundColor:[NSColor orangeColor]];
    
  //  [self.startMessagingView setFrameOrigin:NSMakePoint(NSMinX(self.startMessagingView.frame), self.SMSCodeView.isAppCodeSent ? 0 : 40)];
    
   /// [self.containerView setCenterByView:self.view];
    
    //[self.startMessagingView setFrameOrigin:NSMakePoint(NSMinX(self.startMessagingView.frame), NSMaxY(self.SMSCodeView.frame))];
    
    [self.SMSCodeView setFrameOrigin:NSMakePoint(self.countrySelectorView.frame.origin.x, self.countrySelectorView.frame.origin.y - self.SMSCodeView.frame.size.height + 50)];
    [self.SMSCodeView setHidden:NO];
    
    [self.SMSCodeView prepareForAnimation];
    [self.SMSCodeView.superview prepareForAnimation];
    [self.SMSCodeView performSlideDownWithDuration:duration];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.SMSCodeView setWantsLayer:NO];
        [self.SMSCodeView.superview setWantsLayer:NO];
    });

    CAAnimation *opacityAnimation = [TMAnimations fadeWithDuration:duration * (7 / 13.0) fromValue:0 toValue:1];
    opacityAnimation.beginTime = CACurrentMediaTime() + duration * (3 / 13.0);
    [self.SMSCodePlaceholder setAnimation:opacityAnimation forKey:@"opacity"];
    
    CAAnimation *positionAnimation = [TMAnimations postionWithDuration:duration * (4 / 13.0) fromValue:CGPointMake(100, 0) toValue:CGPointMake(0, 0)];
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    positionAnimation.beginTime = CACurrentMediaTime() + duration * (3 / 13.0);
    [self.SMSCodePlaceholder setAnimation:positionAnimation forKey:@"position"];
    
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        
        [self.startMessagingView.textButton setHidden:NO];
        [self.startMessagingView setHidden:NO];
        
//        [self.startMessagingView setBackgroundColor:[NSColor redColor]];
        
        if(!IS_RETINA) {
            [self.startMessagingView setWantsLayer:NO];
            [self.startMessagingView.textButton setWantsLayer:NO];
        }
    }];
    [self.startMessagingView prepareForAnimation];
    [self.startMessagingView.textButton prepareForAnimation];
    
    self.startMessagingView.textButton.layer.opacity = 0;
    [self.startMessagingView.textButton setHidden:NO];
    
    
    self.bottomView.layer.opacity = 0;
    [self.bottomView setHidden:NO];
    
    CABasicAnimation *animation = (CABasicAnimation *)[TMAnimations fadeWithDuration:duration * (6 / 13.0) fromValue:0.1 toValue:1];
    animation.beginTime = CACurrentMediaTime() + duration * (7 / 13.0);
    [self.startMessagingView.textButton setAnimation:animation forKey:@"opacity"];
    
    
     [self.bottomView setAnimation:animation forKey:@"opacity"];
    
    [CATransaction commit];
    
    
   
    
    
}

- (void)getSMSCodeSendRequest {
    [self.getSMSCodeView prepareForLoading];
    
    self.isCodeExpired = NO;
    
    
    [TMViewController showModalProgress];
    
    [RPCRequest sendRequest:[TLAPI_auth_sendCode createWithPhone_number:self.phoneNumber sms_type:5 api_id:API_ID api_hash:API_HASH lang_code:@"en"] successHandler:^(RPCRequest *request, TL_auth_sentCode *response) {
        
        
        [self.bottomView setIsAppCodeSent:[response isKindOfClass:[TL_auth_sentAppCode class]]];
            
        self.bottomView.timeToCall = response.send_call_timeout;
     
        self.phone_code_hash = response.phone_code_hash;
        self.isPhoneRegistered = response.phone_registered;
        
        [self.startMessagingView setHasImage:YES];
        [self.getSMSCodeView loadingSuccess];
        
        if(!self.bottomView.isAppCodeSent) {
            [self startTimer:self.bottomView.timeToCall];
        }
        
        [self performSMSCodeTextFieldShowAnimation];
        
         [TMViewController hideModalProgressWithSuccess];
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if(error.error_code == PHONE_MIGRATE_X) {
            [self getSMSCodeSendRequest];
        } else {
            if([error.error_msg isEqualToString:@"PHONE_NUMBER_INVALID"]) {
                error.error_msg = NSLocalizedString(@"Login.InvalidPhoneNumber", nil);
            }
            
             [TMViewController hideModalProgress];
            
            [self.getSMSCodeView loadingSuccess];
            [self.getSMSCodeView showErrorWithText:error.error_msg];
            [self.countrySelectorView performBlocking:NO];
        }
    } alwayContinueWithErrorContext:YES];
}

-(void)sendSmsCode {
    
    self.bottomView.isAppCodeSent = NO;
    [self startTimer:self.bottomView.timeToCall];
    
   [RPCRequest sendRequest:[TLAPI_auth_sendSms createWithPhone_number:self.phoneNumber phone_code_hash:self.phone_code_hash] successHandler:^(RPCRequest *request, id response) {
       
       
       if([response isKindOfClass:[TL_boolTrue class]])
       {
           
       }
   } errorHandler:^(RPCRequest *request, RpcError *error) {
       
   } alwayContinueWithErrorContext:YES];
}

- (void)startTimer:(int)time {
    
    [self.bottomView startTimer:time];
}


- (void)performBackEditAnimation:(float)duration {
    [self.countrySelectorView performBlocking:NO];
    [self.countrySelectorView showEditButton:NO];
    [self.bottomView stopTimer];
    
    [self.getSMSCodeView loadingSuccess];
    
//    float duration = 2;
    
    if(duration == 0) {
        [self.getSMSCodeView setHidden:NO];
        self.getSMSCodeView.layer.opacity = 1;
        [self.getSMSCodeView.textButton setHidden:NO];
        [self.getSMSCodeView.errorTextField setHidden:NO];

        [self.getSMSCodeView.errorTextField setStringValue:@""];
        [self.getSMSCodeView.errorTextField.layer setOpacity:0];
        [self.getSMSCodeView setButtonText:self.getSMSCodeView.textButton.stringValue];
        
        self.getSMSCodeView.textButton.layer.opacity  = 1;
        
        self.getSMSCodeView.layer.opacity = 1;
        [self.SMSCodeView setHidden:YES];
        [self.getSMSCodeView.textButton setHidden:self.getSMSCodeView.layer.opacity == 0];
        
//        [self.getSMSCodeView setBackgroundColor:[NSColor redColor]];
        
        self.SMSCodePlaceholder.layer.opacity = 0;
        [self.startMessagingView.errorTextField setHidden:YES];
        [self.startMessagingView.textButton setHidden:YES];
        return;
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.getSMSCodeView.layer.opacity = 1;
        [self.SMSCodeView setHidden:YES];
        [self.getSMSCodeView.textButton setHidden:self.getSMSCodeView.layer.opacity == 0];
        [self.getSMSCodeView setHidden:NO];
        [self.startMessagingView.errorTextField setHidden:YES];
        
        [self.startMessagingView.textButton setHidden:YES];
        [self.startMessagingView setHidden:YES];
        [self.bottomView setHidden:YES];
        
        
        if(!IS_RETINA) {
            [self.getSMSCodeView.errorTextField setWantsLayer:NO];
            [self.getSMSCodeView.textButton setWantsLayer:NO];
            self.getSMSCodeView.wantsLayer = NO;
            self.startMessagingView.wantsLayer = NO;
            self.startMessagingView.textButton.wantsLayer = NO;
            self.startMessagingView.errorTextField.wantsLayer = NO;

            self.SMSCodeView.wantsLayer = NO;
        }
    }];
    
    [self.SMSCodeView prepareForAnimation];
    [self.SMSCodeView setAnimation:[TMAnimations fadeWithDuration:duration fromValue:1 toValue:0] forKey:@"opacity"];
    
    [self.startMessagingView prepareForAnimation];
    [self.startMessagingView.errorTextField prepareForAnimation];
    [self.startMessagingView.textButton prepareForAnimation];
    
//    [self.startMessagingView showErrorWithText:nil];
    [self.startMessagingView.textButton setAnimation:[TMAnimations fadeWithDuration:duration fromValue:1 toValue:0] forKey:@"opacity"];
    [self.startMessagingView.errorTextField setAnimation:[TMAnimations fadeWithDuration:duration fromValue:1 toValue:0] forKey:@"opacity"];
    

    [self.SMSCodePlaceholder setAnimation:[TMAnimations fadeWithDuration:duration fromValue:1 toValue:0] forKey:@"opacity"];
    
    
    [self.getSMSCodeView prepareForAnimation];
    [self.getSMSCodeView.errorTextField prepareForAnimation];
    [self.getSMSCodeView.textButton prepareForAnimation];

    [self.getSMSCodeView setHidden:NO];
    [self.getSMSCodeView.textButton setHidden:NO];
    [self.getSMSCodeView.errorTextField setHidden:NO];
    
//    [self.getSMSCodeView setBackgroundColor:[NSColor redColor]];
    [self.getSMSCodeView.errorTextField setStringValue:@""];
    [self.getSMSCodeView.errorTextField.layer setOpacity:0];
    [self.getSMSCodeView setButtonText:self.getSMSCodeView.textButton.stringValue];
    [self.getSMSCodeView.textButton setAnimation:[TMAnimations fadeWithDuration:duration fromValue:0.3 toValue:1] forKey:@"opacity"];
    [self.bottomView setAnimation:[TMAnimations fadeWithDuration:duration fromValue:1 toValue:0] forKey:@"opacity"];
    
  
    
    [CATransaction commit];
}

- (void)sendCallRequest {
    
    __block NSString *phone_code_hash = self.phone_code_hash;
    weakify();
    [RPCRequest sendRequest:[TLAPI_auth_sendCall createWithPhone_number:self.phoneNumber phone_code_hash:self.phone_code_hash] successHandler:^(RPCRequest *request, id response) {
        if([strongSelf.phone_code_hash isEqualToString:phone_code_hash])
            [self.SMSCodeView changeCallTextFieldString:NSLocalizedString(@"Registration.PhoneDialed", nil)];
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        if([strongSelf.phone_code_hash isEqualToString:phone_code_hash])
            [self.SMSCodeView changeCallTextFieldString:NSLocalizedString(@"Login.Error", nil)];
    } alwayContinueWithErrorContext:YES];
}

- (void)textField:(id)textField handleURLClick:(NSString *)url {
    if([url isEqualToString:@"telegram_site"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://telegram.org"]];
    }
}

@end
