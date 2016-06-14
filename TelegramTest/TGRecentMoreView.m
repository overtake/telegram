//
//  TGRecentMoreView.m
//  Telegram
//
//  Created by keepcoder on 27/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGRecentMoreView.h"
#import "TGTextLabel.h"
#import "TGRecentMoreItem.h"

@interface TGRecentMoreView ()
@property (nonatomic,strong) TGTextLabel *textLabel;
@end

@implementation TGRecentMoreView


-(instancetype)initWithFrame:(NSRect)frameRect  {
    if(self = [super initWithFrame:frameRect]) {
        _textLabel = [[TGTextLabel alloc] init];
        
        [self addSubview:_textLabel];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)redrawRow {
    TGRecentMoreItem *item = (TGRecentMoreItem *) self.rowItem;
    
    [_textLabel setText:item.attrHeader maxWidth:NSWidth(self.frame)];
    
    [_textLabel setCenterByView:self];
}


@end
