//
//  TMRowView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMRowView.h"

@interface TMRowView()
@end

@implementation TMRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedBackgroundColor = self.normalBackgroundColor = [NSColor whiteColor];
    }
    return self;
}

- (void)changeSelected:(BOOL)isSelected {
    
}

- (void)checkSelected:(BOOL)isSelected {
    
}

- (void) removeFromSuperview {
    [super removeFromSuperview];
}

- (void) viewWillMoveToSuperview:(NSView *)newSuperview {
    [super viewWillMoveToSuperview:newSuperview];
}

- (void) dealloc {

}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
}

- (void) redrawRow {
    [self checkSelected:self.isSelected];
}

- (void)setHover:(BOOL)hover redraw:(BOOL)redraw {
    if(self.isHover != hover) {
        self->_isHover = hover;
        if(redraw)
        {
            [self setNeedsDisplay:YES];
        }
    }
}


- (void) setItem:(id)item selected:(BOOL)isSelected {
    
    self.rowItem = item;
    
    if(self.isSelected != isSelected) {
        self.isSelected = isSelected;
        [self setBackgroundColor:isSelected ? self.selectedBackgroundColor : self.normalBackgroundColor];
        [self changeSelected:isSelected];
    }
    
    [self redrawRow];
}

@end
