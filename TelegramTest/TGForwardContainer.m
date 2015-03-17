//
//  TGForwardContainer.m
//  Telegram
//
//  Created by keepcoder on 17.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGForwardContainer.h"


@interface TGForwardContainer ()

@property (nonatomic,strong) TMTextField *namesField;
@property (nonatomic,strong) TMTextField *descriptionField;

@end

@implementation TGForwardContainer

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [super drawRect:dirtyRect];
    
    [GRAY_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(0, 0, 2, NSHeight(self.frame)));
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.descriptionField = [TMTextField defaultTextField];
        self.namesField = [TMTextField defaultTextField];
        
        [self.descriptionField setStringValue:@"test"];
        
        
        [self.namesField setStringValue:@"super test"];
        
        
        [self.namesField setFrame:NSMakeRect(15, NSHeight(frameRect) - 13, NSWidth(frameRect), 20)];
        
        [self.descriptionField setFrame:NSMakeRect(15, 0, NSWidth(frameRect), 20)];
        
        [self addSubview:self.descriptionField];
        [self addSubview:self.namesField];
        
    }
    
    return self;
}


-(void)setFwdObject:(TGForwardObject *)fwdObject {
    _fwdObject = fwdObject;
    
    [self updateLayout];
}


-(void)updateLayout {
    
    
    
    [self setNeedsDisplay:YES];
}


@end
