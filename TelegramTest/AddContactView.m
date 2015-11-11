//
//  AddContactView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 22.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "AddContactView.h"
#import "TMBlueInputTextField.h"
#import "RMPhoneFormat.h"
#import "UserInfoShortTextEditView.h"
@interface AddContactView ()
@property (nonatomic,strong) UserInfoShortTextEditView *firstNameView;
@property (nonatomic,strong) UserInfoShortTextEditView *lastNameView;
@property (nonatomic,strong) UserInfoShortTextEditView *phoneNumberView;
@property (nonatomic,strong) TMAvatarImageView *avatarImage;

@property (nonatomic,strong) TLUser *user;
@end

@implementation AddContactView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isFlipped = YES;
        
        
        TMView *rightView = [[TMView alloc] init];
        
        
        TMTextButton *doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:@"Done"];
        [doneButton setTapBlock:^{
            [self actionAddContact];
        }];
        
        [rightView setFrameSize:doneButton.frame.size];
        
        
        [rightView addSubview:doneButton];
        
        [self.controller setRightNavigationBarView:rightView animated:NO];
        
        
        
        self.user = [TL_userContact createWithN_id:-1 first_name:@"" last_name:@"" username:@"" access_hash:0 phone:0 photo:[TL_userProfilePhotoEmpty create] status:[TL_userStatusEmpty create]];
        
        
        int offsetY = 30;
        
        
        
        self.firstNameView = [[UserInfoShortTextEditView alloc] initWithFrame:NSZeroRect];
        [self.firstNameView setFrameOrigin:NSMakePoint(190, offsetY)];
        [self.firstNameView setFrameSize:NSMakeSize(self.frame.size.width-290, 38)];
        
        
        
        [self addSubview:self.firstNameView];
        
        
        
        self.lastNameView = [[UserInfoShortTextEditView alloc] initWithFrame:NSZeroRect];
        [self.lastNameView setFrameOrigin:NSMakePoint(190, offsetY + self.firstNameView.bounds.size.height)];
        [self.lastNameView setFrameSize:NSMakeSize(self.frame.size.width-290, 38)];
        [self addSubview:self.lastNameView];
        
        [self.firstNameView.textView setNextKeyView:self.lastNameView.textView];
        [self.firstNameView.textView setTarget:self];
        [self.firstNameView.textView setAction:@selector(enterClick)];
        
        
        
        [self.lastNameView.textView setNextKeyView:self.phoneNumberView.textView];
        [self.lastNameView.textView setTarget:self];
        [self.lastNameView.textView setAction:@selector(enterClick)];
        
        [self.firstNameView.textView setFont:TGSystemFont(14)];
        [self.lastNameView.textView setFont:TGSystemFont(14)];
        
        [self.firstNameView.textView setAlignment:NSLeftTextAlignment];
        [self.lastNameView.textView setAlignment:NSLeftTextAlignment];
        
       
        
        [self.phoneNumberView.textView setNextKeyView:self.firstNameView.textView];
        [self.phoneNumberView.textView setTarget:self];
        [self.phoneNumberView.textView setAction:@selector(enterClick)];
        
        
        self.phoneNumberView = [[UserInfoShortTextEditView alloc] initWithFrame:NSMakeRect(100, 115 + offsetY, frame.size.width-200, 35)];
        
        
        self.phoneNumberView.textView.font = TGSystemFont(13);
        
        NSAttributedString *phoneViewPlaceHolder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AddContact.PhoneNumberPlaceholder", nil) attributes:@{NSFontAttributeName:TGSystemFont(13), NSForegroundColorAttributeName:GRAY_TEXT_COLOR}];
        
        
        [self.phoneNumberView.textView.cell setPlaceholderAttributedString:phoneViewPlaceHolder];
        
        
        NSAttributedString *firstNameViewPlaceHolder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AddContact.FirstNamePlaceholder", nil) attributes:@{NSFontAttributeName:TGSystemFont(13), NSForegroundColorAttributeName:GRAY_TEXT_COLOR}];
        
        
        [self.phoneNumberView.textView.cell setPlaceholderAttributedString:phoneViewPlaceHolder];

        
        NSAttributedString *lastNameViewPlaceHolder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AddContact.LastNamePlaceholder", nil) attributes:@{NSFontAttributeName:TGSystemFont(13), NSForegroundColorAttributeName:GRAY_TEXT_COLOR}];
        
        
        [self.phoneNumberView.textView.cell setPlaceholderAttributedString:phoneViewPlaceHolder];
        [self.firstNameView.textView.cell setPlaceholderAttributedString:firstNameViewPlaceHolder];
        [self.lastNameView.textView.cell setPlaceholderAttributedString:lastNameViewPlaceHolder];
        
        
        [self addSubview:self.phoneNumberView];
        
        
        [self.firstNameView.textView setFrameOrigin:NSMakePoint(0, 8)];
        [self.lastNameView.textView setFrameOrigin:NSMakePoint(0, 8)];
        [self.phoneNumberView.textView setFrameOrigin:NSMakePoint(0, 8)];
        
        
        self.firstNameView.textView.delegate = self;
        self.lastNameView.textView.delegate = self;
        self.phoneNumberView.textView.delegate = self;
        
        
        

        self.avatarImage = [[TMAvatarImageView alloc] initWithFrame:NSMakeRect(100, 35, 75, 75)];
        
        [self addSubview:self.avatarImage];
        
        [self.avatarImage setUser:self.user];
    }
    return self;
}

-(void)enterClick {
    
}

- (void)actionAddContact {
    
    TL_inputPhoneContact *contact = [TL_inputPhoneContact createWithClient_id:rand_long() phone:self.phoneNumberView.textView.stringValue first_name:self.firstNameView.textView.stringValue last_name:self.lastNameView.textView.stringValue];
    
    

    NSMutableArray *failFields = [[NSMutableArray alloc] init];
    
    if(self.firstNameView.textView.stringValue.length == 0) {
        [failFields addObject:self.firstNameView];
    }
    

    if(self.phoneNumberView.textView.stringValue.length == 0) {
        [failFields addObject:self.phoneNumberView];
    }
    
    
    if(failFields.count == 0) {
        [[NewContactsManager sharedManager] importContact:contact callback:^(BOOL isAdd, TL_importedContact *contact, TLUser *user) {
            
            if(isAdd) {
                
                TL_conversation *dialog = user.dialog;
                if(dialog) {
                    [appWindow().navigationController showMessagesViewController:dialog];
                }
                
                
                
            } else {
                alert(NSLocalizedString(@"AddContact.NotRegistredTitle",nil), NSLocalizedString(@"AddContact.NotRegistredDescription",nil));
            }
            [self.controller close];
            
        }];
    } else {
        NSBeep();
        
      
    }
 
}

-(void)clear {
    
    self.firstNameView.textView.stringValue = self.lastNameView.textView.stringValue = self.phoneNumberView.textView.stringValue = @"";
    
    self.user.first_name = self.firstNameView.textView.stringValue;
    self.user.last_name = self.lastNameView.textView.stringValue;
    
    [Notification perform:USER_UPDATE_NAME data:@{KEY_USER:self.user}];

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


@end
