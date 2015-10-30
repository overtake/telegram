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
        [Notification addObserver:self selector:@selector(didChangeUpdateWebpage:) name:UPDATE_WEB_PAGE_ITEMS];
    }
    
    return self;
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(void)didChangeUpdateWebpage:(NSNotification *)notification
{
    NSArray *ids = notification.userInfo[KEY_MESSAGE_ID_LIST];
    
    if(self.items.count <= 1)
        return;
    
    NSArray *items = [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.message.n_id IN %@",ids]];
    
    [items enumerateObjectsUsingBlock:^(MessageTableItemText *obj, NSUInteger idx, BOOL *stop) {
        
        [obj updateWebPage];
        
        NSUInteger index = [self indexOfItem:obj];
        
        if(index != NSNotFound) {
            [self noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:index]];
            
            [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
        
        
    }];
    
    
}

-(Class)rowViewClass {
    return [TGSharedLinkRowView class];
}
-(Class)historyFilter {
    return [SharedLinksHistoryFilter class];
}

-(BOOL)acceptMessageItem:(MessageTableItem *)item {
    return [item isKindOfClass:[MessageTableItemText class]];
}

-(int)heightWithItem:(MessageTableItemText *)item {
    return item.webpage ? MAX(item.webpage.descSize.height+30, 60) : MAX(item.allAttributedLinksSize.height + 10, 60);
}

-(NSPredicate *)searchPredicateWithString:(NSString *)string {
    return [NSPredicate predicateWithBlock:^BOOL(MessageTableItemText *evaluatedObject, NSDictionary *bindings) {
        
        if(evaluatedObject.webpage)
        {
            return [evaluatedObject.webpage.webpage.title searchInStringByWordsSeparated:string] || [evaluatedObject.webpage.webpage.n_description searchInStringByWordsSeparated:string] || [evaluatedObject.webpage.webpage.site_name searchInStringByWordsSeparated:string];
        }
        
        return [evaluatedObject.allAttributedLinks.string containsString:string];
        
    }];
}

-(id)remoteFilter {
    return [TL_inputMessagesFilterUrl create];
}

- (void)prepareItem:(MessageTableItemText *)item {
  //  [item.webpage makeSize:NSWidth(self.scrollView)-24];
}

@end
