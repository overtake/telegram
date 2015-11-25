//
//  SearchLoadMoreCell.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 5/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SearchLoadMoreCell.h"

@interface SearchLoadMoreCell()
@property (nonatomic, strong) TMTextButton *loadMore;
@end

@implementation SearchLoadMoreCell

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    weakify();
    
    
    self.loadMore = [[TMTextButton alloc] init];
    [self.loadMore setTextColor:BLUE_UI_COLOR];
    [self.loadMore setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
    [self.loadMore setFont:TGSystemFont(13)];
    [self.loadMore setTapBlock:^{
        SearchLoadMoreItem *item = (SearchLoadMoreItem *)[strongSelf rowItem];
        if(item.clickBlock)
            item.clickBlock();
    }];
    [self addSubview:self.loadMore];
    return self;
}

- (void)setHover:(BOOL)hover redraw:(BOOL)redraw {
    [super setHover:hover redraw:redraw];
}

- (void)redrawRow {
    [super redrawRow];
    
    SearchLoadMoreItem *item = (SearchLoadMoreItem *)[self rowItem];
    
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Search.More", nil), item.num ];
    
    [self.loadMore setStringValue:text];
    [self.loadMore sizeToFit];
    [self.loadMore setCenterByView:self];
    [self.loadMore setFrameOrigin:NSMakePoint(self.loadMore.frame.origin.x, self.loadMore.frame.origin.y + 2)];
}

-(void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self.loadMore setCenterByView:self];
    [self.loadMore setFrameOrigin:NSMakePoint(self.loadMore.frame.origin.x, self.loadMore.frame.origin.y + 2)];
}


@end
