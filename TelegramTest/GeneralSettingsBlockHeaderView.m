//
//  GeneralSettingsBlockHeaderView.m
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "GeneralSettingsBlockHeaderView.h"

@interface GeneralSettingsBlockHeaderItem ()

@end

@implementation GeneralSettingsBlockHeaderItem





-(id)initWithString:(NSString *)header height:(int)height flipped:(BOOL)flipped {
    if(self = [super init]) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:header withColor:GRAY_TEXT_COLOR];
        [attr setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:attr.range];
        
        _header = attr;
        self.height = height;
        _isFlipped = flipped;
    }
    
    return self;
}

-(Class)viewClass {
    return [GeneralSettingsBlockHeaderView class];
}


@end


@interface  GeneralSettingsBlockHeaderView()
@property (nonatomic,strong) TMTextField *textField;

@end


@implementation GeneralSettingsBlockHeaderView



-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.textField = [TMTextField defaultTextField];

        [[self.textField cell] setLineBreakMode:NSLineBreakByWordWrapping];
        [self.textField setFrameOrigin:NSMakePoint(100, 0)];
       
        
        
        [self addSubview:self.textField];
    }
    
    return self;
}





-(void)redrawRow {
    
    GeneralSettingsBlockHeaderItem *item = (GeneralSettingsBlockHeaderItem *)[self rowItem];
    
    [self.textField setAttributedStringValue:item.header];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    GeneralSettingsBlockHeaderItem *item = (GeneralSettingsBlockHeaderItem *)[self rowItem];
    
    NSSize s = [item.header sizeForTextFieldForWidth:NSWidth(self.frame) - item.xOffset*2];
    
    [self.textField setFrameSize:NSMakeSize(NSWidth(self.frame) - item.xOffset*2, s.height )];
    [self.textField setFrameOrigin:NSMakePoint(item.xOffset, item.isFlipped ? NSHeight(self.frame) - s.height : 0 )];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
