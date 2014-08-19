//
//  SelectUsersTableView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 21.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SelectUsersTableView.h"
#import "NSString+Extended.h"
@interface SelectUsersTableView ()
@property (nonatomic,strong) NSMutableArray *items;
@end

@implementation SelectUsersTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _selectType = SelectUsersTypeSingle;
        _selectLimit = MAX_CHAT_USERS;
        
        
    }
    return self;
}

-(void)ready {
    NSArray *contacts = [[NewContactsManager sharedManager] all];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [contacts enumerateObjectsUsingBlock:^(TGContact * obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *exc = [self.exceptions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.intValue = %d",obj.user_id]];
        
        if(exc.count == 0)
            [items addObject:[[SelectUserItem alloc] initWithObject:obj]];
    }];
    
    [items sortUsingComparator:^NSComparisonResult(SelectUserItem* obj1, SelectUserItem* obj2) {
        int first = obj1.contact.user.lastSeenTime;
        int second = obj2.contact.user.lastSeenTime;
        
        if ( first > second ) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( first < second ) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
        
    }];
    
    
    self.tm_delegate = self;
    
    [self removeAllItems:NO];
    
    self.items = items;
    [self insert:self.items startIndex:0 tableRedraw:NO];
    [self reloadData];
    
    
}


- (void)setSelectType:(SelectUsersType)selectType {
    self->_selectType = selectType;
    NSUInteger count = self.count;
    
    for (SelectUserItem *item in self.list) {
        item.isSelected = NO;
    }
    
    [self cancelSelection];
    
    for(int i = 0; i < count; i++) {
        SelectUserRowView *cell = (SelectUserRowView *)[self viewAtColumn:0 row:i makeIfNecessary:NO];;
        [cell needUpdateSelectType];
    }
}

- (void)setExceptions:(NSArray *)exceptions {
    self->_exceptions = exceptions;
    
    
    for (NSNumber *exception in exceptions) {
    
        NSArray *copy = [self.list copy];
        
        [copy enumerateObjectsUsingBlock:^(SelectUserItem * obj, NSUInteger idx, BOOL *stop) {
            if(obj.contact.user_id == [exception intValue]) {
                [self removeItem:obj];
                [self.items removeObject:obj];
                *stop = YES;
            }
        }];
    }
}

- (BOOL) selectionWillChange:(NSInteger)row item:(SelectUserItem *) item {
    return self.selectType == SelectUsersTypeSingle;
}

- (void)selectionDidChange:(NSInteger)row item:(SelectUserItem *)item {
    if(self.singleCallback != nil) {
        self.singleCallback(item.contact);
    }
}

-(BOOL)isSelectable:(NSInteger)row item:(TMRowItem *)item {
    return YES;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.count;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return YES;
}


-(BOOL)canSelectItem {
    return self.selectLimit > self.selectedItems.count;
}

-(NSArray *)selectedItems {
    NSMutableArray *selected = [[NSMutableArray alloc] init];
    for (SelectUserItem *item in self.items) {
        if(item.isSelected) {
            [selected addObject:item];
        }
    }
    
    return selected;
}

- (CGFloat) rowHeight:(NSUInteger)row item:(TMRowItem *)item {
    return 60;
}


- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *)item {
    return [self cacheViewForClass:[SelectUserRowView class] identifier:@"SelectUserRowView"];
}

- (void)search:(NSString *)searchString {
    searchString = [searchString trim];
    
    NSMutableString *transformed = [searchString mutableCopy];
    CFMutableStringRef bufferRef = (__bridge CFMutableStringRef)transformed;
    CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, false);
    
    
    
    NSMutableString *reversed = [searchString mutableCopy];
    bufferRef = (__bridge CFMutableStringRef)reversed;
    CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, true);
    
    
    NSArray *sorted = [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.contact.user.n_id != %d",[UsersManager currentUserId]]];
    
    
    if(searchString.length > 0) {
        sorted = [sorted filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self.title.string contains[c] %@) OR (self.title.string contains[c] %@) OR (self.title.string contains[c] %@)",searchString,transformed,reversed]];
    }
    
    
    [self removeAllItems:NO];
    
    [self insert:sorted startIndex:0 tableRedraw:NO];
    
    [self reloadData];

}



- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
