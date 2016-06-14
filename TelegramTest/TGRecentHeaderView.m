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
@property (nonatomic,strong) TGTextLabel *showMoreOrLess;
@end

@implementation TGRecentHeaderView

-(instancetype)initWithFrame:(NSRect)frameRect  {
    if(self = [super initWithFrame:frameRect]) {
        _textLabel = [[TGTextLabel alloc] init];
        [_textLabel setFrameOrigin:NSMakePoint(10, 0)];
        [_textLabel setBackgroundColor:NSColorFromRGB(0xf4f4f4)];
        [self addSubview:_textLabel];
        
        _showMoreOrLess = [[TGTextLabel alloc] init];
        [_showMoreOrLess setBackgroundColor:NSColorFromRGB(0xf4f4f4)];
        [self addSubview:_showMoreOrLess];
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
    
    [_textLabel setText:item.attrHeader maxWidth:NSWidth(self.frame)/2.0];
    
    [_textLabel setCenteredYByView:self];
    
    [_showMoreOrLess setHidden:item.otherItems.count == 0];
    
    if(!_showMoreOrLess.isHidden) {
        [_showMoreOrLess setText:item.isMore ? item.showLess : item.showMore maxWidth:NSWidth(self.frame)/2.0];
        
        [_showMoreOrLess setCenteredYByView:self];
        
        [_showMoreOrLess setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_showMoreOrLess.frame) - 10, NSMinY(_showMoreOrLess.frame))];
    }

}

@end
