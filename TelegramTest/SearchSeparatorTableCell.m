//
//  SearchSeparatorTableCell.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchSeparatorTableCell.h"
#import "SearchSeparatorItem.h"

@interface SimpleTextField : NSTextField
@end

@implementation SimpleTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end

@interface SearchSeparatorTableCell()
@property (nonatomic, strong) SimpleTextField *textField;
@end

@implementation SearchSeparatorTableCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
//    [NSScroller preferredScrollerStyle] != NSScrollerStyleLegacy
    [NSColorFromRGB(0xf4f4f4) set];
    NSRectFill(NSMakeRect(0, 0, self.bounds.size.width - (YES ? DIALOG_BORDER_WIDTH : 0), self.bounds.size.height));
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        [self setWantsLayer:YES];
        
        self.textField = [[SimpleTextField alloc] initWithFrame:NSMakeRect(15, 4, 100, 20)];
        [self.textField setTextColor:NSColorFromRGB(0x9b9b9b)];
        [self.textField setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
        [self.textField setSelectable:NO];
        [self.textField setEditable:NO];
        [self.textField setBordered:NO];
        [self.textField setDrawsBackground:NO];
        [self.textField setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
        [self.textField setFont:TGSystemFont(13)];
        [self addSubview:self.textField];
    }
    return self;
}

-(void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    [self.textField setCenterByView:self];
    
    [self.textField setFrameOrigin:NSMakePoint(NSMinX(_textField.frame), 6)];
}


- (void)setHover:(BOOL)hover redraw:(BOOL)redraw {
    [super setHover:hover redraw:redraw];
}

- (void)redrawRow {
    SearchSeparatorItem *item = (SearchSeparatorItem *)self.rowItem;
    
    self.textField.stringValue =  item.itemCount == -1 ? NSLocalizedString(@"Search.LoadingMessages", nil) : (item.itemCount == 0 ? item.oneName : [NSString stringWithFormat:@"%d %@", item.itemCount, item.itemCount == 1 ? item.oneName : item.pluralName]);
    [self.textField sizeToFit];
    [self.textField setCenteredXByView:self];
    
    [self.textField setFrameOrigin:NSMakePoint(NSMinX(_textField.frame), 6)];
   
}

@end
