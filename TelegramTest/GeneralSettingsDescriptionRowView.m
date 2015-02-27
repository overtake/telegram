//
//  GeneralSettingsDescriptionRowView.m
//  Telegram
//
//  Created by keepcoder on 27.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "GeneralSettingsDescriptionRowView.h"
#import "GeneralSettingsDescriptionRowItem.h"
@interface GeneralSettingsDescriptionRowView ()
@property (nonatomic,strong) TMTextField *descriptionField;
@end

@implementation GeneralSettingsDescriptionRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.descriptionField = [TMTextField defaultTextField];
        //[self.descriptionField setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview:self.descriptionField];
    }

    return self;
}


-(void)redrawRow {
    [super redrawRow];
    
    GeneralSettingsDescriptionRowItem *item = (GeneralSettingsDescriptionRowItem *) [self rowItem];
    
    [self.descriptionField setAttributedStringValue:item.attributedString];
    
    [self.descriptionField setFrameSize:NSMakeSize(NSWidth([Telegram rightViewController].view.frame) - 200, item.height)];
    
    
    [self.descriptionField setFrameOrigin:NSMakePoint(100, 0)];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    GeneralSettingsDescriptionRowItem *item = (GeneralSettingsDescriptionRowItem *) [self rowItem];
    [self.descriptionField setFrameSize:NSMakeSize(NSWidth([Telegram rightViewController].view.frame) - 200, item.height)];
}

@end
