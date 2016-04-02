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
#import "TGTextLabel.h"
@interface TGContextRowView ()
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TMTextField *textField;
@property (nonatomic,strong) TMTextField *domainSymbolView;
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
        
        _domainSymbolView = [TMTextField defaultTextField];
        [_domainSymbolView setFont:TGSystemFont(18)];
        [_domainSymbolView setTextColor:[NSColor whiteColor]];
        [_imageView addSubview:_domainSymbolView];
        
        
        
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
    
    [_textField setFrame:NSMakeRect(self.xTextOffset, 0, NSWidth(self.frame) - self.xTextOffset, self.item.descSize.height)];
    
    [_textField setCenteredYByView:_textField.superview];
    
    [self.item.desc setSelected:self.isSelected];
    
    [_textField setAttributedStringValue:self.item.desc];
    
    [_domainSymbolView setStringValue:self.item.domainSymbol];
    [_domainSymbolView sizeToFit];
    [_domainSymbolView setCenterByView:_imageView];
    [_domainSymbolView setHidden:self.item.imageObject != nil];
}


@end
