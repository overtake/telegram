//
//  TGSNoAuthModalView.m
//  Telegram
//
//  Created by keepcoder on 19.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSNoAuthModalView.h"
#import "BTRButton.h"
#import "ShareViewController.h"
@interface TGSNoAuthModalView ()
@property (nonatomic,strong) BTRButton *cancelButton;
@end

@implementation TGSNoAuthModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.backgroundColor = [NSColor whiteColor];
        
        NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect), 40)];
        
        [textField setStringValue:NSLocalizedString(@"NoAuthDescription", nil)];
        [textField setFont:TGSystemFont(14)];
        [textField setBackgroundColor:GRAY_TEXT_COLOR];
        [textField setDrawsBackground:NO];
        [textField setAlignment:NSCenterTextAlignment];
        [textField setDrawsBackground:NO];
        [textField setSelectable:NO];
        [textField setBordered:NO];
        [textField setCenterByView:self];
        
        [self addSubview:textField];
        
        
        _cancelButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), 50)];
        
        _cancelButton.layer.backgroundColor = [NSColor whiteColor].CGColor;
        
        [_cancelButton setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
        
        [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forControlState:BTRControlStateNormal];
        
        
        [_cancelButton addBlock:^(BTRControlEvents events) {
            [ShareViewController close];
        } forControlEvents:BTRControlEventClick];
        
        
        TMView *topSeparator = [[TMView alloc] initWithFrame:NSMakeRect(0, 49, NSWidth(self.frame), DIALOG_BORDER_WIDTH)];
        
        topSeparator.backgroundColor = DIALOG_BORDER_COLOR;
        
       
        
        [self addSubview:_cancelButton];
        
        [self addSubview:topSeparator];

    }
    
    return self;
}

@end
