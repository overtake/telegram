//
//  TGEnterPasswordPanel.m
//  Telegram
//
//  Created by keepcoder on 01.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGEnterPasswordPanel.h"
#import <MtProtoKit/MTEncryption.h>
@interface TGEnterPasswordPanel ()<NSTextFieldDelegate>
@property (nonatomic,strong) NSSecureTextField *secureField;
@property (nonatomic,strong) TMTextField *titleField;
@property (nonatomic,strong) TMView *contentView;
@property (nonatomic,strong) TMTextButton *resetPass;
@property (nonatomic,strong) TMTextButton *logout;
@property (nonatomic,strong) TMTextButton *confirm;
@end

@implementation TGEnterPasswordPanel

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        self.contentView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 300, 250)];
        
     //   self.contentView.backgroundColor = [NSColor blueColor];
        
        self.contentView.isFlipped = YES;
        
        [self.contentView setCenterByView:self];
        
        [self addSubview:self.contentView];
        
        self.backgroundColor = NSColorFromRGB(0xffffff);
        
        
        self.secureField = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 30)];
        
        NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
        
        [attrs appendString:NSLocalizedString(@"Password.password", nil) withColor:NSColorFromRGB(0x999999)];
        
        [attrs setAttributes:@{NSFontAttributeName:[NSFont fontWithName:@"HelveticaNeue" size:14]} range:attrs.range];
        
        [attrs setAlignment:NSCenterTextAlignment range:attrs.range];
        
        [[self.secureField cell] setPlaceholderAttributedString:attrs];
        
        [self.secureField setAlignment:NSCenterTextAlignment];
        
        [self.secureField setCenterByView:[self contentView]];
        
        [self.secureField setBordered:NO];
        [self.secureField setDrawsBackground:NO];
        [self.secureField setFocusRingType:NSFocusRingTypeNone];
        
        [self.secureField setAction:@selector(checkPassword)];
        [self.secureField setTarget:self];
        
        [self.secureField setFrameOrigin:NSMakePoint(NSMinX(self.secureField.frame), 90)];
        
        [self.contentView addSubview:self.secureField];
        
        
        TMView *separator = [[TMView alloc] initWithFrame:self.secureField.frame];
        
        [separator setFrame:NSMakeRect(NSMinX(separator.frame), NSMinY(separator.frame) + NSHeight(self.secureField.frame) + 1, NSWidth(separator.frame), 1)];
        
        separator.backgroundColor = GRAY_BORDER_COLOR;
        
        [self.contentView addSubview:separator];
        
        
        self.titleField = [TMTextField defaultTextField];
        
        
        [self.titleField setStringValue:NSLocalizedString(@"Password.EnterYourPassword", nil)];
        
       
        
        [self.titleField setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
        
        [self.titleField setTextColor:NSColorFromRGB(0x999999)];
        
        [self.titleField sizeToFit];
        
        
        [self.titleField setCenterByView:self.contentView];
        
        [self.titleField setFrameOrigin:NSMakePoint(NSMinX(self.titleField.frame),  40)];
        
        [self.contentView addSubview:self.titleField];
        
        
        self.resetPass = [[TMTextButton alloc] initWithFrame:NSZeroRect];
        
        self.resetPass.stringValue = NSLocalizedString(@"Password.ResetPassword", nil);
        self.resetPass.textColor = BLUE_UI_COLOR;
        self.resetPass.font = [NSFont fontWithName:@"HelveticaNeue" size:12];
        
        [self.resetPass sizeToFit];
        
        [self.resetPass setFrameOrigin:NSMakePoint(NSMinX(separator.frame), NSHeight(self.contentView.frame) - NSHeight(self.resetPass.frame) - 5)];
        
        weakify();
        
        [self.resetPass setTapBlock:^ {
            
            
            confirm(NSLocalizedString(@"ALERT", nil), NSLocalizedString(@"Password.resetAlert", nil), ^{
                
                [TMViewController showModalProgress];
                
                [RPCRequest sendRequest:[TLAPI_account_deleteAccount createWithReason:@"Forgot password"] successHandler:^(RPCRequest *request, id response) {
                    
                   [[Telegram delegate] logoutWithForce:YES];
                    
                    [strongSelf hide];
                    
                    [TMViewController hideModalProgress];
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    
                     [TMViewController hideModalProgress];
                    
                } timeout:10];
                
            },nil);
            
            
           
        }];
        
        
        [self.contentView addSubview:self.resetPass];
        
        
        self.logout = [[TMTextButton alloc] initWithFrame:NSZeroRect];
        
        self.logout.stringValue = NSLocalizedString(@"Password.logout", nil);
        self.logout.textColor = BLUE_UI_COLOR;
        self.logout.font = [NSFont fontWithName:@"HelveticaNeue" size:12];
        
        [self.logout sizeToFit];
        
        [self.logout setFrameOrigin:NSMakePoint(NSMaxX(separator.frame) - NSWidth(self.logout.frame),  NSHeight(self.contentView.frame) - NSHeight(self.resetPass.frame) - 5)];
        
        
        [self.logout setTapBlock:^ {
            [[Telegram delegate] logoutWithForce:YES];
        }];
        
        
        [self.contentView addSubview:self.logout];
        
        
        
        self.confirm = [[TMTextButton alloc] initWithFrame:NSZeroRect];
        
        self.confirm = [[TMTextButton alloc] initWithFrame:NSZeroRect];
        
        self.confirm.stringValue = NSLocalizedString(@"Password.confirm", nil);
        self.confirm.textColor = BLUE_UI_COLOR;
        self.confirm.font = [NSFont fontWithName:@"HelveticaNeue" size:14];
        
        [self.confirm sizeToFit];
        
        [self.confirm setCenterByView:self.contentView];
        
        [self.confirm setFrameOrigin:NSMakePoint(NSMinX(self.confirm.frame),  NSMaxY(separator.frame) + 15)];
        
        [self.confirm setTapBlock:^ {
            [strongSelf checkPassword];
        }];
        
        
        [self.contentView addSubview:self.confirm];
        
    }
    
    return self;
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
               
                [TMViewController hideModalProgress];
                [self hide];
                [[[MTNetwork instance] context] updatePasswordInputRequiredForDatacenterWithId:[[MTNetwork instance] currentDatacenter] required:NO];
                [[Telegram sharedInstance] onAuthSuccess];
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
                if(error.error_code == 400) {
                    alert(NSLocalizedString(@"Password.error", nil), NSLocalizedString(error.error_msg, nil));
                }
                
                [TMViewController hideModalProgress];
            } timeout:10];
            
        }
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        [TMViewController hideModalProgress];
        
    } timeout:10];
}

-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(void)mouseUp:(NSEvent *)theEvent {
    
}

-(void)mouseEntered:(NSEvent *)theEvent {
    
}

-(void)mouseExited:(NSEvent *)theEvent {
    
}

-(void)prepare {
    [self.secureField setStringValue:@""];
    [self.window makeFirstResponder:self.secureField];
}

-(void)hide {
    [self removeFromSuperview];
}


/*

 */

@end
