//
//  TGSharedLinksTableView.m
//  Telegram
//
//  Created by keepcoder on 24.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSharedLinksTableView.h"
#import "TGSharedLinkRowView.h"
#import "SharedLinksHistoryFilter.h"
#import "MessageTableItemText.h"
@implementation TGSharedLinksTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [Notification addObserver:self selector:@selector(didChangeUpdateWebpage:) name:UPDATE_WEB_PAGES];
    }
    
    return self;
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(void)didChangeUpdateWebpage:(NSNotification *)notification
{
    
}

-(Class)rowViewClass {
    return [TGSharedLinkRowView class];
}
-(Class)historyFilter {
    return [SharedLinksHistoryFilter class];
}

-(BOOL)acceptMessageItem:(MessageTableItem *)item {
    return [item isKindOfClass:[MessageTableItemText class]] && ((MessageTableItemText *)item).webpage != nil;
}

-(int)heightWithItem:(MessageTableItemText *)item {
    return MAX(item.webpage.descSize.height+30, 60);
}

-(void)reloadWithString:(NSString *)string {
    
}

- (void)prepareItem:(MessageTableItemText *)item {
  //  [item.webpage makeSize:NSWidth(self.scrollView)-24];
}

@end
