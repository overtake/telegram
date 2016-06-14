//
//  TGPVMiniControl.m
//  Telegram
//
//  Created by keepcoder on 04/05/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGPVMiniControl.h"

@implementation TGPVMiniControl

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.6);
        self.autoresizingMask = NSViewMinXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        
        self.wantsLayer = YES;
        self.layer.cornerRadius = 8;
    }
    
    return self;
}

@end
