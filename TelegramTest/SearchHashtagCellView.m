//
//  SearchHashtagCellView.m
//  Telegram
//
//  Created by keepcoder on 23.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "SearchHashtagCellView.h"
#import "SearchHashtagItem.h"
@interface SearchHashtagCellView ()
@property (nonatomic,strong) TMTextField *textField;
@end

@implementation SearchHashtagCellView



-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textField = [TMTextField defaultTextField];
        [_textField setFont:TGSystemFont(13)];
        [self addSubview:_textField];
    }
    
    return self;
}


-(void)redrawRow {
    
    SearchHashtagItem *item = (SearchHashtagItem *)[self rowItem];
    
    [_textField setStringValue:item.hashtag];
    
    [_textField sizeToFit];
    
    
    [_textField setCenterByView:self];
    
    [_textField setFrameOrigin:NSMakePoint(15, NSMinY(_textField.frame))];
    
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [DIALOG_BORDER_COLOR set];
    NSRectFill(NSMakeRect(15, 0, self.bounds.size.width - DIALOG_BORDER_WIDTH - 15, 1));
}



@end
