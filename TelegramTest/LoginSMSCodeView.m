//
//  LoginSMSCodeView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "LoginSMSCodeView.h"
#import "NewLoginViewController.h"

@interface LoginSMSCodeView()
@property (nonatomic, strong) TMTextField *smsCodeTextField;
@property (nonatomic, strong) TMTextField *callTextField;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int timeToCall;
@property (nonatomic, strong) NSString *oldValue;
@end

@implementation LoginSMSCodeView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.smsCodeTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(120, 45, self.bounds.size.width, 20)];
        self.smsCodeTextField.drawsBackground = NO;
        self.smsCodeTextField.delegate = self;
        [self.smsCodeTextField setPlaceholderPoint:NSMakePoint(2, 1)];
        self.smsCodeTextField.font = [NSFont fontWithName:@"Helvetica-Light" size:15];
        self.smsCodeTextField.focusRingType = NSFocusRingTypeNone;
        [self.smsCodeTextField setBordered:NO];
        [self addSubview:self.smsCodeTextField];
        
        
        self.callTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(120, 0, self.bounds.size.width, 0)];
        [self.callTextField setBordered:NO];
        self.callTextField.wantsLayer = YES;
        [self.callTextField setEditable:NO];
        [self.callTextField setDrawsBackground:NO];
        [self.callTextField setTextColor:NSColorFromRGB(0xaeaeae)];
        [self.callTextField setFont:[NSFont fontWithName:@"Helvetica" size:13]];
        [self addSubview:self.callTextField];
    }
    return self;
}

- (void)controlTextDidChange:(NSNotification *)obj {
    
   NSString *str = [[self.smsCodeTextField.stringValue componentsSeparatedByCharactersInSet:
                                              [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                             componentsJoinedByString:@""];

    
    if(str.length > 5) {
        str = [str substringToIndex:5];
    }
    
    if(str.length == 5) {
        if(![str isEqualToString:self.oldValue]) {
            self.oldValue = str;
            [self.loginController signIn];
        }
    }
    
    [self.smsCodeTextField setStringValue:str];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if(control == self.smsCodeTextField) {
        if(commandSelector == @selector(insertNewline:)) {
            [self.loginController signIn];
            return YES;
        }
    }
    
    return NO;
}

- (void)performShake {
    float a = 3;
    float duration = 0.04;
    
    NSBeep();
    
    __block NSRange selectionRange = self.smsCodeTextField.selectedRange;
    [self.smsCodeTextField prepareForAnimation];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.smsCodeTextField setWantsLayer:NO];
        [self.smsCodeTextField.window makeFirstResponder:self.smsCodeTextField];
        [self.smsCodeTextField setSelectionRange:selectionRange];
    }];
    
    [self.smsCodeTextField setAnimation:[TMAnimations shakeWithDuration:duration fromValue:CGPointMake(-a + self.smsCodeTextField.layer.position.x, self.smsCodeTextField.layer.position.y) toValue:CGPointMake(a + self.smsCodeTextField.layer.position.x, self.smsCodeTextField.layer.position.y)] forKey:@"position"];
    [CATransaction commit];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xe6e6e6) set];
    NSRectFill(NSMakeRect(self.bounds.size.width - 322, 32, 322, 1));
}

- (NSString *)code {
    return self.smsCodeTextField.stringValue;
}

- (void)performSlideDownWithDuration:(float)duration {
    
    [self.smsCodeTextField.cell setPlaceholderAttributedString:nil];
    [self.smsCodeTextField setStringValue:@""];
    self.oldValue = nil;
    
    self.layer.opacity = 1.0;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSAttributedString *placeHolder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Login.code",nil) attributes:@{NSFontAttributeName: [NSFont fontWithName:@"Helvetica-Light" size:15], NSForegroundColorAttributeName: NSColorFromRGB(0xaeaeae)}];
        [self.smsCodeTextField.cell setPlaceholderAttributedString:placeHolder];
//        [self.smsCodeTextField setPlaceholderAttributedString:placeHolder];
        [self.smsCodeTextField.window makeFirstResponder:self.smsCodeTextField];
        
        [self.smsCodeTextField setStringValue:self.smsCodeTextField.stringValue];
    });
    
    [self setAnimation:[TMAnimations postionWithDuration:duration * 0.5 fromValue:self.layer.position toValue:NSMakePoint(self.layer.position.x, self.layer.position.y - 50)] forKey:@"position"];
}

- (void)performBlocking:(BOOL)isBlocking {
    BOOL isEnabled = !isBlocking;
    NSColor *textColor = isEnabled ? NSColorFromRGB(0x000000) : NSColorFromRGB(0x888888);
    
    [self.smsCodeTextField setEnabled:isEnabled];
    [self.smsCodeTextField setTextColor:textColor];

    
    
    if(!isBlocking) {
        [self.smsCodeTextField.window makeFirstResponder:self.smsCodeTextField];
        [self.smsCodeTextField setCursorToEnd];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.smsCodeTextField.window makeFirstResponder:self.smsCodeTextField];
            [self.smsCodeTextField setCursorToEnd];
        });
    }
}

- (BOOL)isValidCode {
    return self.code.length == 5;
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
        self.callTextField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"Login.willCallYou", nil), minutes, secStr];
    }
    [self.callTextField sizeToFit];
}

- (void)changeCallTextFieldString:(NSString *)string {
    self.callTextField.stringValue = string;
    [self.callTextField sizeToFit];
}

@end
