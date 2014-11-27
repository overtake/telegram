//
//  PhoneChangeController.m
//  Telegram
//
//  Created by keepcoder on 27.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhoneChangeController.h"
#import "LoginCountrySelectorView.h"
@interface PhoneChangeController ()
@property (nonatomic,strong) TMTextField *centerTextField;
@property (nonatomic,strong) LoginCountrySelectorView *changerView;
@property (nonatomic,strong) TMTextField *descriptionField;
@end

@implementation PhoneChangeController

-(void)loadView {
    [super loadView];
    
    
    self.view.isFlipped = YES;
    
    self.centerTextField = [TMTextField defaultTextField];
    [self.centerTextField setAlignment:NSCenterTextAlignment];
    [self.centerTextField setAutoresizingMask:NSViewWidthSizable];
    [self.centerTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
    [self.centerTextField setTextColor:NSColorFromRGB(0x222222)];
    [[self.centerTextField cell] setTruncatesLastVisibleLine:YES];
    [[self.centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.centerTextField setDrawsBackground:NO];
    
    [self.centerTextField setStringValue:NSLocalizedString(@"PhoneChangeController.Header", nil)];
    
    [self.centerTextField setFrameOrigin:NSMakePoint(self.centerTextField.frame.origin.x, -12)];
    
    self.centerNavigationBarView = (TMView *) self.centerTextField;
    
    TMTextButton *doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"PhoneChangeController.Next", nil)];
    
    
    [doneButton setTapBlock:^{
        [[Telegram rightViewController] showPhoneChangeController];
    }];
    
    
    
    [self setRightNavigationBarView:(TMView *)doneButton animated:NO];
    
    
    self.changerView = [[LoginCountrySelectorView alloc] initWithFrame:NSMakeRect(0, 0, 432, 90)];
    
    //[self.changerView setBackgroundColor:[NSColor blueColor]];
    
    [self.view addSubview:self.changerView];
    
    [self.changerView setCenterByView:self.view];
    [self.changerView setFrameOrigin:NSMakePoint(NSMinX(self.changerView.frame) - 50, 50)];
    
    self.changerView.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
    
    weakify();
    
    [self.changerView setNextCallback:^{
        
        [strongSelf sendSmsCode];
        
    }];
    
    
    self.descriptionField = [TMTextField defaultTextField];
    
    [self.descriptionField setStringValue:NSLocalizedString(@"PhoneChangeController.Description", nil)];
    
    [self.descriptionField sizeToFit];
    
    
    [self.descriptionField setFrameOrigin:NSMakePoint(NSMinX(self.changerView.frame) + 110, 150)];
    
    [self.view addSubview:self.descriptionField];
    
    /*
     "PhoneChangeAlertController.Description" = "You can change your phone number here. All your cloud data - messages, files, groups, contacts, etc. will be moved to the new number. \n \n%1$@Important:%2$@ note thet your new number will added to your contact for all your Telegram contacts who have your old number (except when you blocked then im Telegram). Your old number will be disconnected from the Telegram account.\nThis action cannot be undone, please be careful.";
     "PhoneChangeAlertController.ChangePhone" = "Change Number";
     "PhoneChangeController.Header" = "Change Number";
     "PhoneChangeController.Next" = "Next";
     "PhoneChangeController.Description" = "We will send an SMS with a confirmation code to\nyour new number.";
     */
    
}

-(void)sendSmsCode {
    
}

@end
