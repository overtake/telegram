//
//  LoginBottomView.m
//  Telegram
//
//  Created by keepcoder on 19.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "LoginBottomView.h"

@interface LoginBottomView ()<TMHyperlinkTextFieldDelegate>
@property (nonatomic,strong) TMHyperlinkTextField *callTextField;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation LoginBottomView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.callTextField = [[TMHyperlinkTextField alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.bounds), 53)];
        [self.callTextField setBordered:NO];
        self.callTextField.wantsLayer = YES;
        [self.callTextField setEditable:NO];
        [self.callTextField setAlignment:NSCenterTextAlignment];
        [self.callTextField setDrawsBackground:NO];
        [self.callTextField setTextColor:NSColorFromRGB(0xaeaeae)];
        [self.callTextField setFont:TGSystemFont(13)];
        [self addSubview:self.callTextField];
        [self.callTextField setUrl_delegate:self];
        
    }
    return self;
}

-(void)textField:(id)textField handleURLClick:(NSString *)url {
    [self.loginController sendSmsCode];
}

-(void)setIsAppCodeSent:(BOOL)isAppCodeSent {
    self->_isAppCodeSent = isAppCodeSent;
    
    if(self.isAppCodeSent) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        
        [str appendString:NSLocalizedString(@"Login.EnterCodeFromApp", nil) withColor:NSColorFromRGB(0xaeaeae)];
        
        [str appendString:@"\n"];
        
        NSRange range = [str appendString:NSLocalizedString(@"Login.SendSmsIfNotReceivedAppCode", nil) withColor:BLUE_UI_COLOR];
        [str setLink:@"sendSms" forRange:range];
        
        [str setAlignment:NSCenterTextAlignment range:str.range];
        
        self.callTextField.attributedStringValue = str;
    }
}



- (void)startTimer:(int)timer {
    [self.timer invalidate];
    self.timeToCall = timer + 1;
    
    self.timer = [NSTimer timerWithTimeInterval: 1.0
                                         target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    
    
    [[NSRunLoop currentRunLoop] addTimer: self.timer forMode:NSRunLoopCommonModes];
    [self timerTick];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerTick {
    self.timeToCall--;
    
    if(self.timeToCall <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        [self.loginController sendCallRequest];
    } else {
        int minutes = self.timeToCall / 60;
        int sec = self.timeToCall % 60;
        NSString *secStr = sec > 9 ? [NSString stringWithFormat:@"%d", sec] : [NSString stringWithFormat:@"0%d", sec];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        
        [str appendString:NSLocalizedString(@"Login.WeSendSms", nil) withColor:NSColorFromRGB(0xaeaeae)];
        
        [str appendString:@"\n"];
        
        [str appendString:[NSString stringWithFormat:NSLocalizedString(@"Login.willCallYou", nil), minutes, secStr] withColor:NSColorFromRGB(0xaeaeae)];
        
        [str setAlignment:NSCenterTextAlignment range:str.range];
        
        self.callTextField.attributedStringValue = str;
        
        self.callTextField.attributedStringValue = str;
        
        
    }
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
