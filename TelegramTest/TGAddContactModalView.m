//
//  TGAddContactModalView.m
//  Telegram
//
//  Created by keepcoder on 09/08/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGAddContactModalView.h"
#import "UserInfoShortTextEditView.h"
#import "RMPhoneFormat.h"
@interface TGAddContactModalView () <NSTextFieldDelegate>
@property (nonatomic,strong) UserInfoShortTextEditView *firstNameView;
@property (nonatomic,strong) UserInfoShortTextEditView *lastNameView;
@property (nonatomic,strong) UserInfoShortTextEditView *phoneNumberView;
@property (nonatomic,strong) TLUser *user;
@end

@implementation TGAddContactModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        
        [self enableCancelAndOkButton];
        [self enableHeader:NSLocalizedString(@"AddContact.NewContact", nil)];
        
        [self setContainerFrameSize:NSMakeSize(360, 280)];

        
         _user = [TL_userContact createWithN_id:-1 first_name:@"" last_name:@"" username:@"" access_hash:0 phone:0 photo:[TL_userProfilePhotoEmpty create] status:[TL_userStatusEmpty create]];
        
        int offsetY = 50 + 30;
        int offsetX = 30;
 
        
       
        _phoneNumberView = [[UserInfoShortTextEditView alloc] initWithFrame:NSMakeRect(offsetX, offsetY, self.containerSize.width-  offsetX * 2, 35)];
        
        
        _lastNameView = [[UserInfoShortTextEditView alloc] initWithFrame:NSZeroRect];
        [_lastNameView setFrameOrigin:NSMakePoint( offsetX, NSMaxY(_phoneNumberView.frame) + 30)];
        [_lastNameView setFrameSize:NSMakeSize(self.containerSize.width - offsetX * 2, 38)];
        [self addSubview:_lastNameView];
        
        
        _firstNameView = [[UserInfoShortTextEditView alloc] initWithFrame:NSZeroRect];
        [_firstNameView setFrameOrigin:NSMakePoint( offsetX, NSMaxY(_lastNameView.frame) + 10)];
        [_firstNameView setFrameSize:NSMakeSize(self.containerSize.width - offsetX * 2, 38)];
        [self addSubview:_firstNameView];

        
        
        NSAttributedString *phoneViewPlaceHolder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AddContact.PhoneNumberPlaceholder", nil) attributes:@{NSFontAttributeName:TGSystemFont(13), NSForegroundColorAttributeName:GRAY_TEXT_COLOR}];
        NSAttributedString *firstNameViewPlaceHolder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AddContact.FirstNamePlaceholder", nil) attributes:@{NSFontAttributeName:TGSystemFont(13), NSForegroundColorAttributeName:GRAY_TEXT_COLOR}];
        NSAttributedString *lastNameViewPlaceHolder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AddContact.LastNamePlaceholder", nil) attributes:@{NSFontAttributeName:TGSystemFont(13), NSForegroundColorAttributeName:GRAY_TEXT_COLOR}];
        
        
        [_phoneNumberView.textView.cell setPlaceholderAttributedString:phoneViewPlaceHolder];
        [_firstNameView.textView.cell setPlaceholderAttributedString:firstNameViewPlaceHolder];
        [_lastNameView.textView.cell setPlaceholderAttributedString:lastNameViewPlaceHolder];
        
        
        
        
        [_firstNameView.textView setNextKeyView:_lastNameView.textView];
        [_firstNameView.textView setTarget:self];
        [_firstNameView.textView setAction:@selector(enterClick:)];
        
        
        
        [_lastNameView.textView setNextKeyView:_phoneNumberView.textView];
        [_lastNameView.textView setTarget:self];
        [_lastNameView.textView setAction:@selector(enterClick:)];
        
        [_firstNameView.textView setFont:TGSystemFont(13)];
        [_lastNameView.textView setFont:TGSystemFont(13)];
        _phoneNumberView.textView.font = TGSystemFont(13);

        
        [_firstNameView.textView setAlignment:NSLeftTextAlignment];
        [_lastNameView.textView setAlignment:NSLeftTextAlignment];
        
        
        
        [_phoneNumberView.textView setNextKeyView:_firstNameView.textView];
        [_phoneNumberView.textView setTarget:self];
        [_phoneNumberView.textView setAction:@selector(enterClick:)];
        
        
        [self addSubview:_phoneNumberView];
        
        
        [_firstNameView.textView setFrameOrigin:NSMakePoint(0, 6)];
        [_lastNameView.textView setFrameOrigin:NSMakePoint(0, 6)];
        [_phoneNumberView.textView setFrameOrigin:NSMakePoint(0, 6)];
        
        
        _firstNameView.textView.delegate = self;
        _lastNameView.textView.delegate = self;
        _phoneNumberView.textView.delegate = self;
        

    }
    
    return self;
}



-(BOOL)becomeFirstResponder {
    return [self.firstNameView.textView becomeFirstResponder];
}

-(void)controlTextDidChange:(NSNotification *)obj {
    
    if(obj.object == self.phoneNumberView.textView) {
        NSString *inputed = self.phoneNumberView.textView.stringValue;
        
        if([inputed rangeOfString:@"("].location != NSNotFound && [inputed rangeOfString:@")"].location == NSNotFound) {
            int i = 1;
            while([inputed characterAtIndex:inputed.length-i] == ' ')
                i++;
            inputed = [inputed substringToIndex:inputed.length-i];
        }
        
        NSString *str = [[inputed componentsSeparatedByCharactersInSet:
                          [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                         componentsJoinedByString:@""];
        
        
        
        
        if(str.length > 15)
            str = [str substringToIndex:15];
        
        
        BOOL isPlus = [str isEqualToString:@"+"];
        
        NSString *format = [RMPhoneFormat formatPhoneNumber:str];
        
        if([format isEqualToString:@"+"] && !isPlus) {
            format = @"";
        }
        
        self.phoneNumberView.textView.stringValue = format;
    } else {
        self.user.first_name = self.firstNameView.textView.stringValue;
        self.user.last_name = self.lastNameView.textView.stringValue;
        
        [Notification perform:USER_UPDATE_NAME data:@{KEY_USER:self.user}];
    }
    
    
}

- (void)enterClick:(TMTextField *)responder {
    if(responder != self.phoneNumberView.textView) {
        [[responder nextKeyView] becomeFirstResponder];
    } else {
        if(self.firstNameView.textView.stringValue.length == 0 || self.phoneNumberView.textView.stringValue.length == 0) {
            [[self.phoneNumberView.textView nextKeyView] becomeFirstResponder];
        } else {
            [responder resignFirstResponder];
            [self okAction];
        }
    }
    
}

-(void)keyUp:(NSEvent *)theEvent {
    if(theEvent.keyCode == 53) {
        [self close:YES];
    } 
}

- (void)okAction {

    
    TL_inputPhoneContact *contact = [TL_inputPhoneContact createWithClient_id:rand_long() phone:self.phoneNumberView.textView.stringValue first_name:self.firstNameView.textView.stringValue last_name:self.lastNameView.textView.stringValue];
    
    
    
    NSMutableArray *failFields = [[NSMutableArray alloc] init];
    
    if(self.firstNameView.textView.stringValue.length == 0) {
        [failFields addObject:self.firstNameView];
    }
    
    
    if(self.phoneNumberView.textView.stringValue.length == 0) {
        [failFields addObject:self.phoneNumberView];
    }
    
    
    
    if(failFields.count == 0) {
        
        [self close:NO];
        
        [TMViewController showModalProgress];
        
        [[NewContactsManager sharedManager] importContact:contact callback:^(BOOL isAdd, TL_importedContact *contact, TLUser *user) {
            
            [TMViewController hideModalProgress];
            
            if(isAdd) {
                
                TL_conversation *dialog = user.dialog;
                if(dialog) {
                    [appWindow().navigationController showMessagesViewController:dialog];
                }
                
                
            } else {
                alert(NSLocalizedString(@"AddContact.NotRegistredTitle",nil), NSLocalizedString(@"AddContact.NotRegistredDescription",nil));
            }
            
            
            
        }];
    } else {
        NSBeep();
        
    }
    
}


@end
