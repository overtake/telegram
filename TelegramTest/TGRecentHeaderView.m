//
//  TGRecentHeaderVoew.m
//  Telegram
//
//  Created by keepcoder on 27/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGRecentHeaderView.h"
#import "TGTextLabel.h"
#import "TGRecentHeaderItem.h"
@interface TGRecentHeaderView ()
@property (nonatomic,strong) TGTextLabel *textLabel;
@end

@implementation TGRecentHeaderView

-(instancetype)initWithFrame:(NSRect)frameRect  {
    if(self = [super initWithFrame:frameRect]) {
        _textLabel = [[TGTextLabel alloc] init];
        [_textLabel setFrameOrigin:NSMakePoint(10, 0)];
        [_textLabel setBackgroundColor:NSColorFromRGB(0xf4f4f4)];
        [self addSubview:_textLabel];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
        
    [NSColorFromRGB(0xf4f4f4) set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width - (YES ? DIALOG_BORDER_WIDTH : 0), self.bounds.size.height));
}

-(void)redrawRow {
    TGRecentHeaderItem *item = (TGRecentHeaderItem *) self.rowItem;
    
    [_textLabel setText:item.attrHeader maxWidth:NSWidth(self.frame)];
    
    [_textLabel setCenteredYByView:self];
}

@end
