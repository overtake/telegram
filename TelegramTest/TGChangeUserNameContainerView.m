//
//  TGChangeUserNameContainerView.m
//  Telegram
//
//  Created by keepcoder on 13.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGChangeUserNameContainerView.h"
#import "UserInfoShortTextEditView.h"
#import "TGTimer.h"


@implementation TGChangeUserObserver

-(id)initWithDescription:(NSAttributedString *)desc placeholder:(NSString *)placeholder defaultUserName:(NSString *)defaultUserName {
    if(self = [super init]) {
        
        _desc = desc;
        
        _placeholder = placeholder;
        _defaultUserName = defaultUserName;
    }
    
    return self;
}

@end


@interface TGChangeUserNameContainerView ()<NSTextFieldDelegate>
@property (nonatomic,strong) UserInfoShortTextEditView *textView;
@property (nonatomic,strong) TMTextButton *button;
@property (nonatomic,strong) TMTextField *descriptionView;

@property (nonatomic,strong) NSProgressIndicator *progressView;
@property (nonatomic,strong) NSImageView *successView;
@property (nonatomic,strong) TGTimer *timer;
@property (nonatomic,assign) BOOL isSuccessChecked;
@property (nonatomic,assign) BOOL isRemoteChecked;
@property (nonatomic,strong) NSString *lastUserName;
@property (nonatomic,strong) NSString *checkedUserName;
@property (nonatomic,strong) RPCRequest *request;
@property (nonatomic,strong) TMTextField *telegramHolder;
@property (nonatomic,strong) TMTextField *statusTextField;

@end

#define GC NSColorFromRGB(0x61ad5e)

@implementation TGChangeUserNameContainerView

-(id)initWithFrame:(NSRect)frameRect observer:(TGChangeUserObserver *)observer {
    if(self = [super initWithFrame:frameRect]) {
        
        
        self.isFlipped = YES;
        
        _oberser = observer;
        
        self.successView = imageViewWithImage(image_UsernameCheck());
        
        self.progressView = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 15, 15)];
        
        [self.progressView setStyle:NSProgressIndicatorSpinningStyle];
        
        
        self.textView = [[UserInfoShortTextEditView alloc] initWithFrame:NSMakeRect(30, 14, NSWidth(self.frame) - 60, 20)];
        
        [self.successView setFrameOrigin:NSMakePoint(NSWidth(self.textView.frame) - NSWidth(self.successView.frame), 8)];
        
        [self.progressView setFrameOrigin:NSMakePoint(NSWidth(self.textView.frame) - NSWidth(self.progressView.frame), 5)];
        
        self.successView.autoresizingMask = self.progressView.autoresizingMask = NSViewMinXMargin;
        
        [self.progressView setHidden:YES];
        
        [self.successView setHidden:YES];
        
        
        [self.textView addSubview:self.successView];
        
        [self.textView addSubview:self.progressView];
        
        
        
        
        self.statusTextField = [TMTextField defaultTextField];
        
        [[self.statusTextField cell] setLineBreakMode:0];
        
        [self.statusTextField setTextColor:[NSColor redColor]];
        
        [self.statusTextField setStringValue:@"error cant set user name"];
        
        [self.statusTextField sizeToFit];
        
        [self.statusTextField setFrameOrigin:NSMakePoint(30, NSMaxY(_textView.frame) + 5)];
        
        [self addSubview:self.statusTextField];
        
        
        _telegramHolder = [TMTextField defaultTextField];
        [_telegramHolder setStringValue:@"telegram.me/"];
        [_telegramHolder setFont:TGSystemFont(15)];
        [_telegramHolder setTextColor:TEXT_COLOR];
        [_telegramHolder sizeToFit];
        
        [_telegramHolder setFrameOrigin:NSMakePoint(0, 2)];
        [self.textView addSubview:_telegramHolder];
        [self.textView.textView setFrameOrigin:NSMakePoint(NSMaxX(_telegramHolder.frame) - 5, 1)];
        
        
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
        [self.textView.textView setFrameOrigin:NSMakePoint(NSMaxX(_telegramHolder.frame) - 5, NSMinY(self.textView.textView.frame))];
        [self.textView.textView setFrameSize:NSMakeSize(NSWidth(self.textView.textView.frame), 20)];
        
        self.descriptionView = [[TMTextField alloc] initWithFrame:NSMakeRect(26, NSMaxY(_textView.frame), NSWidth(self.frame) - 60, 100)];
        
        [self.descriptionView setStringValue:NSLocalizedString(@"UserName.description", nil)];
        
        [self.descriptionView setFont:TGSystemFont(12)];
        
        [self.descriptionView sizeToFit];
        [self.descriptionView setSelectable:NO];
        [self.descriptionView setBordered:NO];
        [self.descriptionView setDrawsBackground:NO];
        [self addSubview:self.descriptionView];
        
        
    }
    
    return self;
}

-(void)setOberser:(TGChangeUserObserver *)oberser {
    _oberser = oberser;
    
    

    [_descriptionView setAttributedStringValue:oberser.desc];
    [_descriptionView sizeToFit];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    
    [str appendString:oberser.placeholder withColor:DARK_GRAY];
    [str setAlignment:NSLeftTextAlignment range:str.range];
    [str setFont:TGSystemFont(15) forRange:str.range];
    
    [[self.textView textView].cell setPlaceholderAttributedString:str];

    
    [self.textView.textView setStringValue:oberser.defaultUserName];
    self.checkedUserName = oberser.defaultUserName;
    
    [self updateChecker];
    
    [self setFrameSize:self.frame.size];
    
    // update interface
}

-(void)dispatchSaveBlock {
    [self performEnter];
}


- (void)performEnter {
    if([self accept]) {
        [self.textView.textView resignFirstResponder];
        if(self.oberser.willNeedSaveUserName != nil) {
            self.oberser.willNeedSaveUserName(self.textView.textView.stringValue);
        }
    }
}

-(BOOL)accept {
    return [[self defaultUsername] isEqualToString:self.textView.textView.stringValue] || (self.isRemoteChecked && self.isSuccessChecked) || self.textView.textView.stringValue.length == 0;
}

-(void)updateSaveButton {
    
    
    if(self.oberser.didChangedUserName != nil) {
        self.oberser.didChangedUserName(self.textView.textView.stringValue,[self accept]);
    }
    
}



- (void)controlTextDidChange:(NSNotification *)obj {
    
    [self.textView.textView setStringValue:[self.textView.textView.stringValue substringToIndex:MIN(40,self.textView.textView.stringValue.length)]];
    
    if((self.textView.textView.stringValue.length >= 5 && [self isNumberValid]) || self.textView.textView.stringValue.length == 0) {
        [self updateChecker];
    } else {
        [self.progressView setHidden:YES];
        [self.progressView stopAnimation:self];
        [self.successView setHidden:YES];
        
        self.isRemoteChecked = NO;
        self.isSuccessChecked = NO;

        
        if(![self isNumberValid]) {
            [self setState:[self errorWithKey:@"USERNAME_CANT_FIRST_NUMBER"] color:[NSColor redColor]];
        } else {
            [self setState:[self errorWithKey:@"USERNAME_MIN_SYMBOLS_ERROR"] color:[NSColor redColor]];
        }
        
    }
    
     [self updateSaveButton];
    
}

-(BOOL)isNumberValid {
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [self.textView.textView.stringValue rangeOfCharacterFromSet: nonNumbers];
    
    return r.location == 0;
}

-(NSString *)defaultUsername {
    return self.oberser.defaultUserName;
}


-(void)updateChecker {
    
    if([self.textView.textView.stringValue isEqualToString:[self defaultUsername]]) {
        [self.progressView setHidden:YES];
        [self.progressView stopAnimation:self];
        [self.successView setHidden:self.textView.textView.stringValue.length == 0];
        
        [self setState:nil color:nil];
        
        [self updateSaveButton];
        
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
                
                
                if([[self defaultUsername] isEqualToString:self.textView.textView.stringValue])
                {
                    [self updateChecker];
                    return;
                }
                
                NSString *userNameToCheck = self.lastUserName;
                
                
                
                self.request = [RPCRequest sendRequest:self.oberser.needApiObjectWithUserName(userNameToCheck) successHandler:^(RPCRequest *request, id response) {
                    
                    self.isSuccessChecked = [response isKindOfClass:[TL_boolTrue class]];
                    self.isRemoteChecked = YES;
                    self.checkedUserName = userNameToCheck;
                    
                    
                    if(self.isSuccessChecked) {
                        [self setState:self.checkedUserName.length > 0 ? [NSString stringWithFormat:[self errorWithKey:@"UserName.avaiable"],self.checkedUserName] : nil color:GC];
                    } else {
                        [self setState:[self errorWithKey:@"USERNAME_IS_ALREADY_TAKEN"] color:[NSColor redColor]];
                    }
                    
                    
                    
                    [self updateSaveButton];
                    
                    [self.progressView setHidden:YES];
                    [self.progressView stopAnimation:self];
                    
                    [self.successView setHidden:!self.isSuccessChecked];
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    
                    [self.progressView setHidden:YES];
                    [self.progressView stopAnimation:self];
                    
                    [self.successView setHidden:YES];
                    
                    [self setState:[self errorWithKey:error.error_msg] color:[NSColor redColor]];
                    
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

-(NSString *)errorWithKey:(NSString *)key {
    if(self.oberser.needDescriptionWithError != nil) {
        return self.oberser.needDescriptionWithError(key);
    }
    
    return NSLocalizedString(key, nil);
}

-(void)setState:(NSString *)state color:(NSColor *)color {
    [self.statusTextField setHidden:state.length == 0 || color == nil];
    self.statusTextField.stringValue = state;
    self.statusTextField.textColor = color;
    
    
    [self setFrameSize:self.frame.size];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    NSSize size = [self.descriptionView.attributedStringValue sizeForTextFieldForWidth:newSize.width - 60];
    
    [self.descriptionView setFrameSize:NSMakeSize(newSize.width - 60, size.height)];
    
    [self.statusTextField setFrameSize:[self.statusTextField.attributedStringValue sizeForTextFieldForWidth:NSWidth(self.descriptionView.frame)]];
    [self.descriptionView setFrameOrigin:NSMakePoint(30, !self.statusTextField.isHidden ? NSMaxY(_statusTextField.frame) : NSMaxY(_textView.frame))];
}

@end

