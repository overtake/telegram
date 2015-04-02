//
//  GeneralSettingsBlockHeaderView.m
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "GeneralSettingsBlockHeaderView.h"

@interface GeneralSettingsBlockHeaderItem ()
@property (nonatomic,assign,readonly) int rand;
@end

@implementation GeneralSettingsBlockHeaderItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _header = object;
        _rand = arc4random();
    }
    
    return self;
}

-(NSUInteger)hash {
    return _rand;
}

@end


@interface  GeneralSettingsBlockHeaderView()
@property (nonatomic,strong) TMTextField *textField;

@end


@implementation GeneralSettingsBlockHeaderView



-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.textField = [TMTextField defaultTextField];
        [self.textField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        [self.textField setTextColor:NSColorFromRGB(0x999999)];
        [[self.textField cell] setLineBreakMode:NSLineBreakByWordWrapping];
        [self.textField setFrameOrigin:NSMakePoint(100, 0)];
        
        [self addSubview:self.textField];
    }
    
    return self;
}


-(void)redrawRow {
    
    GeneralSettingsBlockHeaderItem *item = (GeneralSettingsBlockHeaderItem *)[self rowItem];
    
    [self.textField setStringValue:item.header];
    
    [self.textField sizeToFit];
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.textField setFrameSize:NSMakeSize(NSWidth(self.frame) - 200, NSHeight(self.frame))];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
