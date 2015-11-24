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
        [attr setFont:TGSystemFont(12) forRange:attr.range];
        
        _header = attr;
        self.height = height;
        _isFlipped = flipped;
        self.drawsSeparator = NO;
    }
    
    return self;
}

-(void)setAligment:(NSTextAlignment)aligment {
    NSMutableAttributedString *attr = [_header mutableCopy];
    
    [attr setAlignment:aligment range:attr.range];
    
    _header = attr;
}

-(void)setTextColor:(NSColor *)textColor {
    NSMutableAttributedString *attr = [_header mutableCopy];
    
    [attr addAttribute:NSForegroundColorAttributeName value:textColor range:attr.range];
    
    _header = attr;
}

-(void)setFont:(NSFont *)font {
    NSMutableAttributedString *attr = [_header mutableCopy];
    
    [attr addAttribute:NSFontAttributeName value:font range:attr.range];
    
    _header = attr;
    
}

-(BOOL)updateItemHeightWithWidth:(int)width {
    
    if(_autoHeight) {
        self.height = [_header sizeForTextFieldForWidth:width - (self.xOffset * 2)].height;
        
        return YES;
    }
    
    return NO;
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

-(void)mouseDown:(NSEvent *)theEvent {
    TGGeneralRowItem *item = (TGGeneralRowItem *) [self rowItem];
    
    if(item.callback != nil) {
        item.callback(item);
    }
    
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
    [self.textField setFrameOrigin:NSMakePoint(item.xOffset - 2, item.isFlipped ? NSHeight(self.frame) - s.height : 2 )];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    GeneralSettingsBlockHeaderItem *item = (GeneralSettingsBlockHeaderItem *)[self rowItem];
    
    if(item.drawsSeparator) {
        [DIALOG_BORDER_COLOR set];
        NSRectFill(NSMakeRect(item.xOffset, 0, NSWidth(dirtyRect) - item.xOffset*2, DIALOG_BORDER_WIDTH));
    }
    
    // Drawing code here.
}

@end
