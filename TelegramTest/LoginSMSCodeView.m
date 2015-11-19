//
//  LoginSMSCodeView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "LoginSMSCodeView.h"
#import "NewLoginViewController.h"

@interface LoginSMSCodeView()<TMHyperlinkTextFieldDelegate>
@property (nonatomic, strong) TMTextField *smsCodeTextField;
@property (nonatomic, strong) TMHyperlinkTextField *callTextField;
@property (nonatomic, strong) NSString *oldValue;

@end

@implementation LoginSMSCodeView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.smsCodeTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(120,  20, self.bounds.size.width, 20)];
        self.smsCodeTextField.drawsBackground = NO;
        self.smsCodeTextField.delegate = self;
        [self.smsCodeTextField setPlaceholderPoint:NSMakePoint(2, 1)];
        self.smsCodeTextField.font = TGSystemLightFont(15);
        self.smsCodeTextField.focusRingType = NSFocusRingTypeNone;
        [self.smsCodeTextField setBordered:NO];
        [self addSubview:self.smsCodeTextField];
        
        
        
        
//        self.callTextField = [[TMHyperlinkTextField alloc] initWithFrame:NSMakeRect(120, 60, self.bounds.size.width - 120, 55)];
//        [self.callTextField setBordered:NO];
//        self.callTextField.wantsLayer = YES;
//        [self.callTextField setEditable:NO];
//        [self.callTextField setDrawsBackground:NO];
//        [self.callTextField setTextColor:NSColorFromRGB(0xaeaeae)];
//        [self.callTextField setFont:TGSystemFont(13)];
//        [self addSubview:self.callTextField];
//        
//        [self.callTextField setHardXOffset:44];
//        
//        [self.callTextField setUrl_delegate:self];
//        
//        [self.callTextField setDrawsBackground:YES];
//        [self.callTextField setBackgroundColor:[NSColor blueColor]];
//
//        
     //   self.backgroundColor = [NSColor redColor];
    }
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.callTextField setFrameSize:NSMakeSize(self.bounds.size.width - 120, NSHeight(self.bounds) - 61)];
}

-(BOOL)isFlipped {
    return YES;
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
    NSRectFill(NSMakeRect(self.bounds.size.width - 322, 49, 322, 1));
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
        NSAttributedString *placeHolder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Login.code",nil) attributes:@{NSFontAttributeName: TGSystemLightFont(15), NSForegroundColorAttributeName: NSColorFromRGB(0xaeaeae)}];
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


- (void) textField:(id)textField handleURLClick:(NSString *)url {
    [self.loginController sendSmsCode];
}

- (BOOL)isValidCode {
    return self.code.length == 5;
}



- (void)changeCallTextFieldString:(NSString *)string {
    self.callTextField.stringValue = string;
    [self.callTextField sizeToFit];
}

@end
