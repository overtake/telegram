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

@interface AddContactView ()
@property (nonatomic,strong) TMBlueInputTextField *firstName;
@property (nonatomic,strong) TMBlueInputTextField *lastName;
@property (nonatomic,strong) TMBlueInputTextField *phoneNumber;
@property (nonatomic,strong) TMAvatarImageView *avatarImage;

@property (nonatomic,strong) TGUser *user;
@end

#define ActiveStartingColor BLUE_UI_COLOR
#define InactiveStartingColor NSColorFromRGB(0xdedede)

@implementation AddContactView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        self.user = [TL_userContact createWithN_id:-1 first_name:@"" last_name:@"" access_hash:0 phone:0 photo:[TL_userProfilePhotoEmpty create] status:[TL_userStatusEmpty create]];
        
        int bOfsset = 20;
        
        
        
        self.backgroundColor = NSColorFromRGB(0xffffff);
        
        self.avatarImage = [[TMAvatarImageView alloc] initWithFrame:NSMakeRect(18, 90 + bOfsset, 78, 78)];
        
        self.firstName = [[TMBlueInputTextField alloc] initWithFrame:NSMakeRect(106,134 + bOfsset, 172, 35)];
        
        self.firstName.placeholderTitle = NSLocalizedString(@"AddContact.FirstNamePlaceholder", nil);
        
        self.firstName.font = self.firstName.placeholderFont = [NSFont fontWithName:@"HelveticaNeue" size:13];
        
        self.firstName.fieldXInset = 7.0f;
        self.firstName.placeholderTextColor = NSColorFromRGB(0xc8c8c8);
        [self.firstName setDrawsFocusRing:NO];
    
        
        
        
        self.lastName = [[TMBlueInputTextField alloc] initWithFrame:NSMakeRect(106, 90 + bOfsset, 172, 35)];
        
        self.lastName.fieldXInset = 7.0f;
        self.lastName.font = self.lastName.placeholderFont = [NSFont fontWithName:@"HelveticaNeue" size:13];
        self.lastName.placeholderTitle = NSLocalizedString(@"AddContact.LastNamePlaceholder", nil);
        self.lastName.placeholderTextColor = NSColorFromRGB(0xc8c8c8);
        [self.lastName setDrawsFocusRing:NO];

        
        self.phoneNumber = [[TMBlueInputTextField alloc] initWithFrame:NSMakeRect(18, 43 + bOfsset, frame.size.width-40, 35)];
        
        self.phoneNumber.fieldXInset = 7.0f;
        self.phoneNumber.font = self.phoneNumber.placeholderFont = [NSFont fontWithName:@"HelveticaNeue" size:13];
        self.phoneNumber.placeholderTitle = NSLocalizedString(@"AddContact.PhoneNumberPlaceholder", nil);
        self.phoneNumber.placeholderTextColor = NSColorFromRGB(0xc8c8c8);
        [self.phoneNumber setDrawsFocusRing:NO];
        
        
        
        
        self.phoneNumber.delegate = self;
        self.firstName.delegate = self;
        self.lastName.delegate = self;
        
        [self addSubview:self.firstName];
        [self addSubview:self.lastName];
        [self addSubview:self.phoneNumber];
        
        [self addSubview:self.avatarImage];
        
        
        [self.firstName setActiveFieldColor:ActiveStartingColor];
        [self.firstName setInactiveFieldColor:InactiveStartingColor];
        
        [self.lastName setActiveFieldColor:ActiveStartingColor];
        [self.lastName setInactiveFieldColor:InactiveStartingColor];
        
        [self.phoneNumber setActiveFieldColor:ActiveStartingColor];
        [self.phoneNumber setInactiveFieldColor:InactiveStartingColor];
        
        
        dispatch_block_t separatorDraw = ^ {
            [GRAY_BORDER_COLOR set];
            NSRectFill(NSMakeRect(0, 46, frame.size.width, 1));
        };
        
        
        TMButton *addContactButton = [[TMButton alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, 47)];
        [addContactButton setAutoresizesSubviews:YES];
        [addContactButton setAutoresizingMask:NSViewMinXMargin];
        [addContactButton setTarget:self selector:@selector(actionAddContact)];
        [addContactButton setText:NSLocalizedString(@"AddContact.AddContact", nil)];
        [addContactButton setTextFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
        
        [addContactButton setBackgroundColor:NSColorFromRGB(0xfdfdfd)];
        
        [addContactButton setTextOffset:NSMakeSize(0, 0)];
        
        [addContactButton setDrawBlock:separatorDraw];

        [addContactButton setTextColor:BLUE_UI_COLOR forState:TMButtonNormalState];
        [addContactButton setTextColor:NSColorFromRGB(0x467fb0) forState:TMButtonNormalHoverState];
        [addContactButton setTextColor:NSColorFromRGB(0x2e618c) forState:TMButtonPressedState];
        
        [self addSubview:addContactButton];
        
        
        
        [self.avatarImage setUser:self.user];
    }
    return self;
}


- (void)actionAddContact {
    
    TL_inputPhoneContact *contact = [TL_inputPhoneContact createWithClient_id:rand_long() phone:self.phoneNumber.stringValue first_name:self.firstName.stringValue last_name:self.lastName.stringValue];
    
    

    NSMutableArray *failFields = [[NSMutableArray alloc] init];
    
    if(self.firstName.stringValue.length == 0) {
        [failFields addObject:self.firstName];
    }
    

    if(self.phoneNumber.stringValue.length == 0) {
        [failFields addObject:self.phoneNumber];
    }
    
    
    if(failFields.count == 0) {
        [[NewContactsManager sharedManager] importContact:contact callback:^(BOOL isAdd, TL_importedContact *contact, TGUser *user) {
            
            if(isAdd) {
                
                TGDialog *dialog = user.dialog;
                if(dialog) {
                    [[Telegram sharedInstance] showMessagesFromDialog:dialog sender:self];
                } else {
                    [[Storage manager] dialogByPeer:user.n_id completeHandler:^(TGDialog *dialog, TGMessage *message) {
                       
                        if(dialog) {
                            [[DialogsManager sharedManager] add:@[dialog]];
                        } else {
                            dialog = [[DialogsManager sharedManager] createDialogForUser:user];
                        }
                        
                        if(message)
                           [[MessagesManager sharedManager] add:@[message]];
                        
                        [[Telegram sharedInstance] showMessagesFromDialog:dialog sender:self];
                    }];
                }
                
                
            } else {
                alert(NSLocalizedString(@"AddContact.NotRegistredTitle",nil), NSLocalizedString(@"AddContact.NotRegistredDescription",nil));
            }
            [self.controller close];
            
        }];
    } else {
        NSBeep();
        for (BTRTextField *failField in failFields) {
            [failField setInactiveFieldColor:NSColorFromRGB(0xdd1111)];
            [failField setActiveFieldColor:NSColorFromRGB(0xdd1111)];
        }
      
    }
 
}

-(void)clear {
    [self.firstName setActiveFieldColor:ActiveStartingColor];
    [self.firstName setInactiveFieldColor:InactiveStartingColor];
    
    [self.lastName setActiveFieldColor:ActiveStartingColor];
    [self.lastName setInactiveFieldColor:InactiveStartingColor];
    
    [self.phoneNumber setActiveFieldColor:ActiveStartingColor];
    [self.phoneNumber setInactiveFieldColor:InactiveStartingColor];
    
    self.firstName.stringValue = self.lastName.stringValue = self.phoneNumber.stringValue = @"";
    
    self.user.first_name = self.firstName.stringValue;
    self.user.last_name = self.lastName.stringValue;
    
    [Notification perform:USER_UPDATE_NAME data:@{KEY_USER:self.user}];

}

-(BOOL)becomeFirstResponder {
    return [self.firstName becomeFirstResponder];
}

-(void)controlTextDidChange:(NSNotification *)obj {
    
    BTRTextField *field = obj.object;
    
    [field setActiveFieldColor:ActiveStartingColor];
    [field setInactiveFieldColor:InactiveStartingColor];
    
    
    if(obj.object == self.phoneNumber) {
        DLog(@"%@",self.phoneNumber.stringValue);
        
        
        NSString *inputed = self.phoneNumber.stringValue;
        
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
        
        self.phoneNumber.stringValue = format;
    } else {
        self.user.first_name = self.firstName.stringValue;
        self.user.last_name = self.lastName.stringValue;
        
        [Notification perform:USER_UPDATE_NAME data:@{KEY_USER:self.user}];
    }
    
    
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
