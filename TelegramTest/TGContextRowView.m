//
//  TGContextRowView.m
//  Telegram
//
//  Created by keepcoder on 23/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGContextRowView.h"
#import "TGImageView.h"
#import "TGCTextView.h"
@interface TGContextRowView ()
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TMTextField *textField;
@property (nonatomic,strong) TMTextField *domainField;
@end

@implementation TGContextRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
   if(self.isSelected) {
        
        [BLUE_COLOR_SELECT set];
        
        NSRectFill(NSMakeRect(0, 0, NSWidth(dirtyRect) , NSHeight(dirtyRect)));
       
       
    } else {
        
        TMTableView *table = self.item.table;
        
        [DIALOG_BORDER_COLOR set];
        
        if([table indexOfItem:self.item] != table.count - 1) {
            NSRectFill(NSMakeRect(self.xTextOffset, 0, NSWidth(dirtyRect) - self.xTextOffset, DIALOG_BORDER_WIDTH));
        }
    }
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(10, 5, 50, 50)];
        _imageView.cornerRadius = 4;
        _imageView.layer.backgroundColor = GRAY_BORDER_COLOR.CGColor;
        _imageView.layer.cornerRadius = 4;
        [self addSubview:_imageView];
        
        _textField = [TMTextField defaultTextField];
        [[_textField cell] setTruncatesLastVisibleLine:YES];
        
        [self addSubview:_textField];
        
        _domainField = [TMTextField defaultTextField];
        [_domainField setFont:TGSystemFont(18)];
        [_domainField setTextColor:[NSColor whiteColor]];
        [_imageView addSubview:_domainField];
        
        
        
    }
    
    return self;
}

-(int)xTextOffset  {
    return 70;
}



-(TGContextRowItem *)item {
    return (TGContextRowItem *)[self rowItem];
}

-(void)redrawRow {
    [super redrawRow];
    
    [_imageView setObject:self.item.imageObject];
    
    [_textField setFrame:NSMakeRect(self.xTextOffset, 5, NSWidth(self.frame) - self.xTextOffset, 55)];
    
    [self.item.desc setSelected:self.isSelected];
    
    [_textField setAttributedStringValue:self.item.desc];
    
    [_domainField setStringValue:first_domain_character(self.item.botResult.content_url)];
    [_domainField sizeToFit];
    [_domainField setCenterByView:_imageView];
    [_domainField setHidden:self.item.imageObject != nil];
}


@end
