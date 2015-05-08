//
//  TGModalView.m
//  Telegram
//
//  Created by keepcoder on 08.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGModalView.h"

@interface TGModalView ()

@end

@implementation TGModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
    }
    
    return self;
}

-(void)show:(NSWindow *)window animated:(BOOL)animated {
    
}
-(void)close:(BOOL)animated {
    
}

@end
