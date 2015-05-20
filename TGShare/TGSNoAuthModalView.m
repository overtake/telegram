//
//  TGSNoAuthModalView.m
//  Telegram
//
//  Created by keepcoder on 19.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSNoAuthModalView.h"

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
    }
    
    return self;
}

@end
