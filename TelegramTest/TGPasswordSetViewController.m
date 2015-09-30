//
//  TGPasswordSetViewController.m
//  Telegram
//
//  Created by keepcoder on 27.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGPasswordSetViewController.h"
#import "UserInfoShortTextEditView.h"


@interface SecureField : TMView
@property (nonatomic,strong) NSSecureTextField *textView;
@end


@implementation SecureField

- (id)initWithFrame:(NSRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        self.textView = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width - 10, 24)];
        [self.textView setBordered:NO];
        [self.textView setFocusRingType:NSFocusRingTypeNone];
        [self.textView setAutoresizingMask:NSViewWidthSizable];
        [self.textView setFrameOrigin:NSMakePoint(8, 2)];
        [self.textView setDrawsBackground:NO];
        
        [self.textView setFont:TGSystemFont(15)];
        [self setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:self.textView];
    }
    return self;
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}

-(BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColorFromRGB(0xe6e6e6) set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
}


@end


@interface TGPasswordSetViewController ()<NSTextFieldDelegate>

@property (nonatomic,strong) SecureField *textView;

@end

@implementation TGPasswordSetViewController



-(void)loadView {
    [super loadView];
    
    
    self.view.isFlipped = YES;
    
    TMTextButton *doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"PasswordSettings.Next", nil)];
    
    
    weak();
    
    [doneButton setTapBlock:^{
        
        BOOL res = weakSelf.action.callback(self.textView.textView.stringValue);
        
        
        if(!res)
        {
            [self performShake];
        }
        
    }];
    
    
    
    [self setRightNavigationBarView:(TMView *)doneButton animated:NO];
    
    
     self.textView = [[SecureField alloc] initWithFrame:NSMakeRect(100, 80, NSWidth(self.view.frame) - 200, 23)];
    
    
    self.textView.textView.delegate = self;
    
    [self.view addSubview:self.textView];
    
    [self.textView.textView setAction:@selector(performEnter)];
    [self.textView.textView setTarget:self];
    [self.textView.textView setFrameOrigin:NSMakePoint(0, NSMinY(self.textView.textView.frame))];

}

-(void)performEnter {
    BOOL res = self.action.callback(self.textView.textView.stringValue);
    
    
    if(!res)
    {
        [self performShake];
    }
}

-(void)performShake {
    [self.textView.textView performShake:^{
        [self.textView.textView setWantsLayer:NO];
        [self.textView.textView.window makeFirstResponder:self.textView.textView];
        [self.textView.textView setSelectionRange:NSMakeRange(0, self.textView.textView.stringValue.length)];
    }];
}

-(void)setAction:(TGSetPasswordAction *)action {
    _action = action;
    
    
    if(!self.view)
    {
        [self loadView];
    }
    
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    
    [str appendString:action.title withColor:DARK_GRAY];
    [str setAlignment:NSLeftTextAlignment range:str.range];
    [str setFont:TGSystemFont(15) forRange:str.range];
    
    [[self.textView textView].cell setPlaceholderAttributedString:str];
   // [[self.textView textView] setPlaceholderPoint:NSMakePoint(0, 0)];
    
    [self setCenterBarViewText:action.header ?: action.title];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView.textView becomeFirstResponder];
    [self.textView.textView setSelectionRange:NSMakeRange(0, self.textView.textView.stringValue.length)];
}

@end
