//
//  PhoneChangeController.m
//  Telegram
//
//  Created by keepcoder on 27.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhoneChangeController.h"
#import "LoginCountrySelectorView.h"


@interface ControllerView : TMView
@property (nonatomic,strong) LoginCountrySelectorView *changerView;
@property (nonatomic,strong) TMTextField *descriptionField;
@end


@implementation ControllerView


-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.changerView = [[LoginCountrySelectorView alloc] initWithFrame:NSMakeRect(0, 0, 432, 90)];
        
        //[self.changerView setBackgroundColor:[NSColor blueColor]];
        
        
        
        [self addSubview:self.changerView];
        
        //  [self.changerView setCenterByView:self.view];
        
        
        [self.changerView setFrame:self.changerView.frame];
        
        self.descriptionField = [TMTextField defaultTextField];
        
        [self.descriptionField setStringValue:NSLocalizedString(@"PhoneChangeController.Description", nil)];
        
        [self.descriptionField sizeToFit];
        
        
       
        
        self.descriptionField.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
        
        [self addSubview:self.descriptionField];
        
        [self setFrame:self.frame];

    }
    
    return self;
}

-(void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    float x = roundf((NSWidth(self.frame) - NSWidth(self.changerView.frame) - 100) / 2);
    
    [self.changerView setFrameOrigin:NSMakePoint(x, 50)];
    [self.descriptionField setFrameOrigin:NSMakePoint(NSMinX(self.changerView.frame) + 110, 150)];
}

@end


@interface PhoneChangeController ()
@property (nonatomic,strong) TMTextField *centerTextField;

@end

@implementation PhoneChangeController

-(void)loadView {
    
    
    ControllerView *view = [[ControllerView alloc] initWithFrame:self.frameInit];
    
    self.view = view;
    
    self.view.isFlipped = YES;
    

    
    self.centerTextField = [TMTextField defaultTextField];
    [self.centerTextField setAlignment:NSCenterTextAlignment];
    [self.centerTextField setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
    [self.centerTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
    [self.centerTextField setTextColor:NSColorFromRGB(0x222222)];
    [[self.centerTextField cell] setTruncatesLastVisibleLine:YES];
    [[self.centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.centerTextField setDrawsBackground:NO];
    
    [self.centerTextField setStringValue:NSLocalizedString(@"PhoneChangeController.Header", nil)];
    
    TMView *centerView = [[TMView alloc] initWithFrame:NSZeroRect];
    
    
    self.centerNavigationBarView = centerView;
    
    [centerView addSubview:self.centerTextField];
    
    [self.centerTextField sizeToFit];
    
    [self.centerTextField setCenterByView:centerView];
    
    [self.centerTextField setFrameOrigin:NSMakePoint(self.centerTextField.frame.origin.x, 12)];
    
    TMTextButton *doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"PhoneChangeController.Next", nil)];
    
    
    [doneButton setTapBlock:^{
        
        [self showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_account_sendChangePhoneCode createWithPhone_number:view.changerView.phoneNumber] successHandler:^(RPCRequest *request, id response) {
            
             [self hideModalProgress];
            
            [[Telegram rightViewController] showPhoneChangeConfirmController:response phone:view.changerView.phoneNumber];
            
           
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            [self hideModalProgress];
            
            if(error.error_code == 400) {
                
               alert(NSLocalizedString(@"PhoneChangeControlller.AlertHeader", nil), NSLocalizedString(error.error_msg, nil));
            }
            
        } timeout:10];
        
    }];
    
    
    
    [self setRightNavigationBarView:(TMView *)doneButton animated:NO];
    
    
    
}

-(void)_didStackRemoved {
    ControllerView *view = (ControllerView *) self.view;
    
    [view.changerView clear];
}

-(void)sendSmsCode {
    
}

@end
