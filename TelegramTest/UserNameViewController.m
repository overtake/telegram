//
//  UserNameViewController.m
//  Telegram
//
//  Created by keepcoder on 15.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserNameViewController.h"
#import "UserInfoShortTextEditView.h"
#import "TGTimer.h"
@interface UserNameViewController ()
@property (nonatomic,strong) TMTextButton *doneButton;
@end


@interface UserNameViewContainer : TMView<NSTextFieldDelegate>
@property (nonatomic,strong) UserInfoShortTextEditView *textView;
@property (nonatomic,strong) TMTextButton *button;
@property (nonatomic,strong) NSTextView *descriptionView;

@property (nonatomic,strong) UserNameViewController *controller;

@property (nonatomic,strong) NSProgressIndicator *progressView;
@property (nonatomic,strong) NSImageView *successView;
@property (nonatomic,strong) TGTimer *timer;
@property (nonatomic,assign) BOOL isSuccessChecked;
@property (nonatomic,assign) BOOL isRemoteChecked;
@property (nonatomic,strong) NSString *lastUserName;
@property (nonatomic,strong) NSString *checkedUserName;
@property (nonatomic,strong) RPCRequest *request;

@property (nonatomic,strong) TMTextField *statusTextField;
@end

#define GC NSColorFromRGB(0x61ad5e)

@implementation UserNameViewContainer

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        self.successView = imageViewWithImage(image_UsernameCheck());
        
        self.progressView = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 15, 15)];
        
        [self.progressView setStyle:NSProgressIndicatorSpinningStyle];
        
        
        self.textView = [[UserInfoShortTextEditView alloc] initWithFrame:NSMakeRect(100, 80, NSWidth(self.frame) - 200, 23)];
        
        [self.successView setFrameOrigin:NSMakePoint(NSWidth(self.textView.frame) - NSWidth(self.successView.frame), 8)];
        
        [self.progressView setFrameOrigin:NSMakePoint(NSWidth(self.textView.frame) - NSWidth(self.progressView.frame), 5)];
        
        self.successView.autoresizingMask = self.progressView.autoresizingMask = NSViewMinXMargin;
        
        [self.progressView setHidden:YES];
        
        [self.successView setHidden:YES];
        
        
        [self.textView addSubview:self.successView];
        
        [self.textView addSubview:self.progressView];
        
        
        self.statusTextField = [TMTextField defaultTextField];
        
        [self.statusTextField setTextColor:[NSColor redColor]];
        
        [self.statusTextField setStringValue:@"error cant set user name"];
        
        [self.statusTextField sizeToFit];
        
        [self.statusTextField setFrameOrigin:NSMakePoint(100, NSMinY(self.textView.frame) + 30)];
        
        [self addSubview:self.statusTextField];
        
        
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        
        [str appendString:NSLocalizedString(@"UserName.placeHolder", nil) withColor:DARK_GRAY];
        [str setAlignment:NSLeftTextAlignment range:str.range];
        [str setFont:TGSystemFont(15) forRange:str.range];
        
        [[self.textView textView].cell setPlaceholderAttributedString:str];
        [[self.textView textView] setPlaceholderPoint:NSMakePoint(0, 0)];
        
        self.textView.textView.delegate = self;
        
        [self addSubview:self.textView];
        
        [self.textView.textView setAction:@selector(performEnter)];
        [self.textView.textView setTarget:self];
        [self.textView.textView setNextKeyView:self];
        [self.textView.textView setFrameOrigin:NSMakePoint(0, NSMinY(self.textView.textView.frame))];
        
        
        self.descriptionView = [[NSTextView alloc] initWithFrame:NSMakeRect(96, 122, NSWidth(self.frame) - 200, 150)];
        
        [self.descriptionView setString:NSLocalizedString(@"UserName.description", nil)];
        
        [self.descriptionView setFont:TGSystemFont(12)];
        [self.descriptionView setTextColor:GRAY_TEXT_COLOR];
        [self.descriptionView sizeToFit];
        [self.descriptionView setSelectable:NO];
        
        [self.descriptionView setTextContainerInset:NSMakeSize(0, 0)];
        
        
        [self addSubview:self.descriptionView];
        

    }
    
    return self;
}


- (void)performEnter {
    if(self.isRemoteChecked && ![[self defaultUsername] isEqualToString:self.checkedUserName]) {
        [self.textView.textView resignFirstResponder];
        self.controller.doneButton.tapBlock();
    }
}

-(void)updateSaveButton {
    
    if([[self defaultUsername] isEqualToString:self.textView.textView.stringValue]) {
        [self.controller.doneButton setDisable:YES];
        
        return;
    }
    
    [self.controller.doneButton setDisable:(self.textView.textView.stringValue.length < 5) || (!self.isRemoteChecked || !self.isSuccessChecked)];
    
    if(self.textView.textView.stringValue.length == 0) {
        [self.controller.doneButton setDisable:NO];
    }
}

- (void)controlTextDidChange:(NSNotification *)obj {
    
    
    [self updateSaveButton];
    
    
    if((self.textView.textView.stringValue.length >= 5 && [self isNumberValid]) || self.textView.textView.stringValue.length == 0) {
         [self updateChecker];
    } else {
        [self.progressView setHidden:YES];
        [self.progressView stopAnimation:self];
        [self.successView setHidden:YES];
        
       
        if(![self isNumberValid]) {
            [self setState:NSLocalizedString(@"USERNAME_CANT_FIRST_NUMBER", nil) color:[NSColor redColor]];
        } else {
            [self setState:NSLocalizedString(@"USERNAME_MIN_SYMBOLS_ERROR", nil) color:[NSColor redColor]];
        }
        
    }
   
}

-(BOOL)isNumberValid {
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [self.textView.textView.stringValue rangeOfCharacterFromSet: nonNumbers];
    
    return r.location == 0;
}

-(NSString *)defaultUsername {
    return self.controller.channel ? self.controller.channel.username : [UsersManager currentUser].username;
}

-(id)checkUsernameRequest:(NSString *)userNameToCheck {
    id request = [TLAPI_account_checkUsername createWithUsername:userNameToCheck];
    
    if(self.controller.channel) {
        request = [TLAPI_channels_checkUsername createWithChannel:[self.controller.channel inputPeer] username:userNameToCheck];
    }
    
    return request;
}

-(void)updateChecker {
    
    if([self.textView.textView.stringValue isEqualToString:[self defaultUsername]]) {
        [self.progressView setHidden:YES];
        [self.progressView stopAnimation:self];
        [self.successView setHidden:NO];
        
        [self setState:nil color:nil];
        
    } else if(![self.lastUserName isEqualToString:self.textView.textView.stringValue] && self.textView.textView.stringValue.length != 0) {
        
        if(!self.timer) {
            
            self.isSuccessChecked = NO;
            self.isRemoteChecked = [self.textView.textView.stringValue isEqualToString:[self defaultUsername]];
            [self updateSaveButton];
            
            self.timer = [[TGTimer alloc] initWithTimeout:0.2 repeat:NO completion:^{
                
               
                
                [self.successView setHidden:YES];
                [self.progressView setHidden:NO];
                [self.progressView startAnimation:self];
                
                if(self.request)
                    [self.request cancelRequest];
                
                NSString *userNameToCheck = self.textView.textView.stringValue;
                
               
                
                self.request = [RPCRequest sendRequest:[self checkUsernameRequest:userNameToCheck] successHandler:^(RPCRequest *request, id response) {
                    
                    self.isSuccessChecked = [response isKindOfClass:[TL_boolTrue class]];
                    self.isRemoteChecked = YES;
                    self.checkedUserName = userNameToCheck;
                    
                    
                    if(self.isSuccessChecked) {
                        [self setState:self.checkedUserName.length > 0 ? [NSString stringWithFormat:NSLocalizedString(@"UserName.avaiable", nil),self.checkedUserName] : nil color:GC];
                    } else {
                        [self setState:[NSString stringWithFormat:NSLocalizedString(@"USERNAME_IS_ALREADY_TAKEN", nil)] color:[NSColor redColor]];
                    }
                    
                    
                    
                    [self updateSaveButton];
                    
                    [self.progressView setHidden:YES];
                    [self.progressView stopAnimation:self];
                    
                    [self.successView setHidden:!self.isSuccessChecked];
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    
                    [self.progressView setHidden:YES];
                    [self.progressView stopAnimation:self];
                    
                    [self.successView setHidden:YES];
                    
                    [self setState:NSLocalizedString(error.error_msg, nil) color:[NSColor redColor]];
                    
                }];
                
                
            } queue:dispatch_get_current_queue()];
            
            [self.timer start];
            
        } else {
            [self.timer invalidate];
            self.timer = nil;
            [self updateChecker];
        }

        
    } else {
        [self setState:nil color:nil];
        [self updateSaveButton];
    }
    
    self.lastUserName = self.textView.textView.stringValue;
    
}

-(void)setState:(NSString *)state color:(NSColor *)color {
    [self.statusTextField setHidden:state.length == 0 || color == nil];
    self.statusTextField.stringValue = state;
    [self.statusTextField sizeToFit];
    self.statusTextField.textColor = color;
    
    [self.descriptionView setFrameOrigin:NSMakePoint(96, !self.statusTextField.isHidden ? 130 : 110)];
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    NSSize size = [self.descriptionView.attributedString sizeForTextFieldForWidth:newSize.width - 200];
    
   
    
    [self.descriptionView setFrameSize:size];
}

@end


@implementation UserNameViewController

-(void)loadView {
    
    self.view = [[UserNameViewContainer alloc] initWithFrame:self.frameInit];
    
    self.view.isFlipped = YES;
    
    [self setCenterBarViewText:NSLocalizedString(@"Profile.ChangeUserName", nil)];
    
    
    weakify();
    self.doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"Username.setName", nil)];
    [self.doneButton setTapBlock:^{
        
        
        [strongSelf showModalProgress];
        
        if(self.channel != nil) {
            [[ChatsManager sharedManager] updateChannelUserName:((UserNameViewContainer *)strongSelf.view).checkedUserName channel:strongSelf.channel completeHandler:^(TL_channel *channel) {
                [strongSelf hideModalProgress];
                
                
                [((UserNameViewContainer *)strongSelf.view) controlTextDidChange:nil];
                
                if(strongSelf.completionHandler != nil) {
                    strongSelf.completionHandler();
                }

            } errorHandler:^(NSString *error) {
                alert(error, error);
                [strongSelf hideModalProgress];
            }];
        } else {
            [[UsersManager sharedManager] updateUserName:((UserNameViewContainer *)strongSelf.view).checkedUserName completeHandler:^(TLUser *user) {
                
                [strongSelf hideModalProgress];
                
                
                [((UserNameViewContainer *)strongSelf.view) controlTextDidChange:nil];
            } errorHandler:^(NSString *error) {
                alert(error, error);
                [strongSelf hideModalProgress];
            }];

        }
        
    }];
    
    [self.doneButton setDisableColor:GRAY_TEXT_COLOR];
    
    TMView *rightView = [[TMView alloc] init];
    
    [rightView setFrameSize:self.doneButton.frame.size];
    
    
    [rightView addSubview:self.doneButton];
    
    [self setRightNavigationBarView:rightView animated:NO];
    
    ((UserNameViewContainer *)self.view).controller = self;
    
}





-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [((UserNameViewContainer *)self.view).textView.textView setStringValue:[(UserNameViewContainer *)self.view defaultUsername]];
    [((UserNameViewContainer *)self.view) controlTextDidChange:nil];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [((UserNameViewContainer *)self.view).textView becomeFirstResponder];
    [((UserNameViewContainer *)self.view).textView.textView setSelectionRange:NSMakeRange(((UserNameViewContainer *)self.view).textView.textView.stringValue.length, 0)];
    
}

@end
