//
//  TMCheckBox.m
//  Telegram P-Edition
//
//  Created by keepcoder on 20.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMCheckBox.h"

@interface TMCheckBox ()
@property (nonatomic,assign) BOOL isChecked;
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic,strong) NSImageView *background;
@property (nonatomic,strong) NSImageView *checkbox;
@end

@implementation TMCheckBox

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isChecked = NO;
//        NSImage* bg =  image_checkbox();
//        NSImage* checkbox = image_checkboxCheck();
//        self.background = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, bg.size.width, bg.size.height)];
//        self.checkbox = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, bg.size.width, bg.size.height)];
        
//        self.background.image = bg;
//        self.checkbox.image = checkbox;
        
        [self addSubview:self.checkbox];
        
                         
        [self addSubview:self.background];
        
        [self update];
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}



-(void)setSelected:(BOOL)selected {
    if(selected == self->_isSelected)
        return;
    self->_isSelected = selected;
    [self update];
}

-(void)setChecked:(BOOL)checked {
    if(checked == self->_isChecked)
        return;
    self->_isChecked = checked;
    [self update];
}

-(BOOL)isChecked {
    return self->_isChecked;
}

-(BOOL)isSelected {
    return self->_isSelected;
}


-(void)update {
    [self.background setHidden:self.isSelected];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0.1];
        [[self.checkbox animator] setAlphaValue:self.isChecked];
    } completionHandler:^{
        [[self.checkbox animator] setHidden:!self.isChecked];
    }];
}


@end
