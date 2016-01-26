//
//  RegistrationViewController.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "RegistrationViewController.h"
#import "RegistrationAvatarView.h"
#import "LoginButtonAndErrorView.h"
#import "NSString+Extended.h"
#import "UsersManager.h"

@interface RegistrationContainerViewController : TMView
@end

@implementation RegistrationContainerViewController

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    int width = 322;
    
    [NSColorFromRGB(0xe6e6e6) set];
    NSRectFill(NSMakeRect(self.bounds.size.width - width, 120, width, 1));
    NSRectFill(NSMakeRect(self.bounds.size.width - width, 170, width, 1));
}

@end

@interface RegistrationViewController ()
@property (nonatomic, strong) RegistrationContainerViewController *containerView;
@property (nonatomic, strong) TMTextField *firstNameTextField;
@property (nonatomic, strong) TMTextField *lastNameTextField;
@property (nonatomic, strong) TMTextField *titleTextField;
@property (nonatomic, strong) RegistrationAvatarView *avatarImageView;
@property (nonatomic, strong) LoginButtonAndErrorView *registerButtonAndErrorView;
@end

@implementation RegistrationViewController

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.isNavigationBarHidden = YES;
    }
    return self;
}

- (void)backButtonClick {
    [self.navigationViewController goBackWithAnimation:YES];
}

- (void)loadView {
    [super loadView];
    
    self.containerView = [[RegistrationContainerViewController alloc] initWithFrame:NSMakeRect(0, 0, 450, 300)];
    [self.containerView setCenterByView:self.view];
    [self.containerView setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin | NSViewMaxXMargin | NSViewMaxYMargin];
//    [self.containerView setBackgroundColor:[NSColor redColor]];
    [self.view addSubview:self.containerView];
    
    
    TMBackButton *backButton = [[TMBackButton alloc] initWithFrame:NSZeroRect string:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"Profile.Back", nil)]];
    [backButton.field setFont:TGSystemLightFont(15)];
    [backButton.imageView setFrameOrigin:NSMakePoint(0, 4)];
    [backButton sizeToFit];
    [backButton setFrameOrigin:NSMakePoint(4, 260)];
    [backButton setTarget:self selector:@selector(backButtonClick)];
    [backButton setBackgroundColor:[NSColor blueColor]];
    //[backButton updateBackButton];
    [self.containerView addSubview:backButton];
    
    self.avatarImageView = [[RegistrationAvatarView alloc] initWithFrame:NSMakeRect(6, 120, 100, 100)];
    [self.avatarImageView setNeedsDisplay:YES];
    [self.containerView addSubview:self.avatarImageView];

    
    self.titleTextField = [[TMTextField alloc] init];
    self.titleTextField.stringValue = NSLocalizedString(@"Registration", nil);
    [self.titleTextField setEditable:NO];
    [self.titleTextField setBordered:NO];
    self.titleTextField.font = TGSystemLightFont(28);
//    self.titleTextField.wantsLayer = IS_RETINA;
    [self.titleTextField sizeToFit];
    
    [self.titleTextField setCenterByView:self.containerView];
    [self.titleTextField setFrameOrigin:NSMakePoint(self.titleTextField.frame.origin.x, 250)];
    [self.containerView addSubview:self.titleTextField];
    
    self.firstNameTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(140, 185, self.containerView.bounds.size.width - 160, 20)];
    self.firstNameTextField.drawsBackground = NO;
    self.firstNameTextField.delegate = self;
    
    NSAttributedString *placeHolder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Registartion.FirstName", nil) attributes:@{NSFontAttributeName: TGSystemLightFont(15), NSForegroundColorAttributeName: NSColorFromRGB(0xc8c8c8)}];
    [self.firstNameTextField.cell setPlaceholderAttributedString:placeHolder];
  //  [self.firstNameTextField setPlaceholderAttributedString:placeHolder];
    [self.firstNameTextField setPlaceholderPoint:NSMakePoint(2, 1)];
    
    [[self.firstNameTextField cell] setTruncatesLastVisibleLine:YES];
    [[self.firstNameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];

    self.firstNameTextField.font = TGSystemLightFont(15);
    self.firstNameTextField.focusRingType = NSFocusRingTypeNone;
    [self.firstNameTextField setBordered:NO];
    [self.containerView addSubview:self.firstNameTextField];
    
    
    self.lastNameTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(140, 135, self.containerView.bounds.size.width - 160, 20)];
    self.lastNameTextField.drawsBackground = NO;
   self.lastNameTextField.delegate = self;
    
    placeHolder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Registration.LastName", nil) attributes:@{NSFontAttributeName: TGSystemLightFont(15), NSForegroundColorAttributeName: NSColorFromRGB(0xc8c8c8)}];
    [self.lastNameTextField.cell setPlaceholderAttributedString:placeHolder];
//    [self.lastNameTextField setPlaceholderAttributedString:placeHolder];
    [self.lastNameTextField setPlaceholderPoint:NSMakePoint(2, 1)];
    [[self.lastNameTextField cell] setTruncatesLastVisibleLine:YES];
    [[self.lastNameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    
    self.lastNameTextField.font = TGSystemLightFont(15);
    self.lastNameTextField.focusRingType = NSFocusRingTypeNone;
    [self.lastNameTextField setBordered:NO];
    [self.containerView addSubview:self.lastNameTextField];
    
    
    [self.firstNameTextField setNextKeyView:self.lastNameTextField];
    [self.lastNameTextField setNextKeyView:self.firstNameTextField];
    
    weakify();
    self.registerButtonAndErrorView = [[LoginButtonAndErrorView alloc] initWithFrame:NSMakeRect(140, 40, self.containerView.bounds.size.width - 100, 40)];
    [self.registerButtonAndErrorView setButtonText:NSLocalizedString(@"Registration.StartMessaging", nil)];
    [self.registerButtonAndErrorView.textButton setTapBlock:^{
        [strongSelf signUp];
    }];
    [self.containerView addSubview:self.registerButtonAndErrorView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.firstNameTextField.window makeFirstResponder:self.firstNameTextField];
}

- (void)signUp {
    NSString *firstName = [[[self.firstNameTextField.stringValue trim] htmlentities] singleLine];
//    NSString *lastName = [[[self.firstNameTextField.stringValue trim] htmlentities] singleLine];
    if(firstName.length == 0) {
        float a = 3;
        float duration = 0.04;
        
        [self.firstNameTextField prepareForAnimation];
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.firstNameTextField setWantsLayer:NO];
        }];
        
        [self.firstNameTextField setAnimation:[TMAnimations shakeWithDuration:duration fromValue:CGPointMake(-a + self.firstNameTextField.layer.position.x, self.firstNameTextField.layer.position.y) toValue:CGPointMake(a + self.firstNameTextField.layer.position.x, self.firstNameTextField.layer.position.y)] forKey:@"position"];
        [CATransaction commit];
        return;
    }
    
    [RPCRequest sendRequest:[TLAPI_auth_signUp createWithPhone_number:self.phoneNumber phone_code_hash:self.phone_code_hash phone_code:self.phone_code first_name:self.firstNameTextField.stringValue last_name:self.lastNameTextField.stringValue] successHandler:^(RPCRequest *request, id response) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"icloudsync"];
        
        [[Telegram sharedInstance] onAuthSuccess];
        
        if(self.avatarImageView.photo) {
            [[UsersManager sharedManager] updateAccountPhotoByNSImage:self.avatarImageView.photo completeHandler:^(TLUser *user) {
                
            } progressHandler:^(float progress) {
                
            } errorHandler:^(NSString *description) {
                
            }];
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        [self.registerButtonAndErrorView showErrorWithText:error.error_msg];
    }];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    
    if(control == self.firstNameTextField) {
        if(commandSelector == @selector(insertNewline:)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.lastNameTextField.window makeFirstResponder:self.lastNameTextField];
                [self.lastNameTextField setCursorToEnd];
            });
            return YES;
        }
    }
    
    if(control == self.lastNameTextField) {
        if(commandSelector == @selector(insertNewline:)) {
            [self signUp];
            return YES;
        }
    }
    
    return NO;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *object = notification.object;
    object.stringValue = object.stringValue;
    if(object == self.firstNameTextField) {
        self.firstNameTextField.stringValue = self.firstNameTextField.stringValue;
    }
}


@end
