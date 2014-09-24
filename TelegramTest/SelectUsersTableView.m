//
//  SelectUsersTableView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 21.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SelectUsersTableView.h"
#import "NSString+Extended.h"
#import "TMSearchTextField.h"


@interface SelectUsersSearchItem : TMRowItem

@end

@implementation SelectUsersSearchItem

-(NSUInteger)hash {
    return -1;
}

@end

@interface SelectUsersSearchView : TMRowView
@property (nonatomic,strong) TMSearchTextField *searchField;
@end

@implementation SelectUsersSearchView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.searchField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(10, 10, NSWidth(frameRect) - 20, 30)];
        
        self.searchField.autoresizingMask = NSViewWidthSizable ;
        
        [self addSubview:self.searchField];
        
    }
    
    return self;
}

-(void)redrawRow {
    self.searchField.delegate = self.rowItem.table;
}



@end

@interface SelectUsersTableView ()<TMSearchTextFieldDelegate>
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) SelectUsersSearchView *searchView;
@property (nonatomic,strong) SelectUsersSearchItem *searchItem;
@end

@implementation SelectUsersTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectLimit = 1;
    }
    return self;
}

static NSCache *cacheItems;

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheItems = [[NSCache alloc] init];
    });
}



-(void)ready {
    NSArray *contacts = [[NewContactsManager sharedManager] all];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    contacts = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self.user_id IN %@)",self.exceptions]];
    
    
    [contacts enumerateObjectsUsingBlock:^(TL_contact *obj, NSUInteger idx, BOOL *stop) {
        
        SelectUserItem *item = [[SelectUserItem alloc] initWithObject:obj];
        
        [items addObject:item];
        
        if(idx == 30)
            *stop = YES;
    }];
    
    
    [items filterUsingPredicate:[NSPredicate predicateWithFormat:@"self.contact.user.n_id != %d",[UsersManager currentUserId]]];
    
//    
//    [items sortUsingComparator:^NSComparisonResult(SelectUserItem* obj1, SelectUserItem* obj2) {
//        int first = obj1.contact.user.lastSeenTime;
//        int second = obj2.contact.user.lastSeenTime;
//        
//        if ( first > second ) {
//            return (NSComparisonResult)NSOrderedAscending;
//        } else if ( first < second ) {
//            return (NSComparisonResult)NSOrderedDescending;
//        } else {
//            return (NSComparisonResult)NSOrderedSame;
//        }
//        
//    }];
    
     NSLog(@"test4");
    
    self.tm_delegate = self;
    
    [self removeAllItems:NO];
    
    self.items = items;
    
    self.searchItem = [[SelectUsersSearchItem alloc] init];
    
    self.searchView = [[SelectUsersSearchView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.bounds), 50)];
    
    [self insert:self.searchItem atIndex:0 tableRedraw:NO];
    
    [self insert:self.items startIndex:1 tableRedraw:NO];
    
    
    [self reloadData];
    
    if(contacts.count > 30)
        dispatch_after_seconds(0.3, ^{
            [self insertOther:[contacts subarrayWithRange:NSMakeRange(30, contacts.count - 30)]];
        });
    
}

-(void)insertOther:(NSArray *)other {
    
    [ASQueue dispatchOnStageQueue:^{
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        [other enumerateObjectsUsingBlock:^(TL_contact *obj, NSUInteger idx, BOOL *stop) {
            
             SelectUserItem *item = [[SelectUserItem alloc] initWithObject:obj];
             [items addObject:item];
            
        }];
        
        [[ASQueue mainQueue] dispatchOnQueue:^{
            [self.items addObjectsFromArray:items];
            [self insert:items startIndex:self.count tableRedraw:NO];
            [self reloadData];
        }];
    }];
    
    
}

- (void)setSelectLimit:(NSUInteger)selectLimit {
    self->_selectLimit = selectLimit;
    NSUInteger count = self.count;
    
    NSArray *copy = [self.list subarrayWithRange:NSMakeRange(1, self.list.count-1)];
    
    for (SelectUserItem *item in copy) {
        item.isSelected = NO;
    }
    
    [self cancelSelection];
    
    for(int i = 1; i < count; i++) {
        SelectUserRowView *cell = (SelectUserRowView *)[self viewAtColumn:0 row:i makeIfNecessary:NO];;
        [cell needUpdateSelectType];
    }
}

- (void)setExceptions:(NSArray *)exceptions {
    self->_exceptions = exceptions;
    
    
    for (NSNumber *exception in exceptions) {
    
        NSArray *copy = [self.list subarrayWithRange:NSMakeRange(1, self.list.count-1)];
        
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
    return self.selectLimit == 0;
}

- (void)selectionDidChange:(NSInteger)row item:(SelectUserItem *)item {
    
    [self.selectDelegate selectTableDidChangedItem:item];
    
    if(self.multipleCallback != nil) {
        self.multipleCallback(@[item.contact]);
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
    return self.selectLimit > self.selectedItems.count || self.selectLimit == 0;
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
    return row == 0 ? 50 : 50;
}


- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *)item {
    return row == 0 ? self.searchView : [self cacheViewForClass:[SelectUserRowView class] identifier:@"SelectUserRowView" withSize:NSMakeSize(NSWidth(self.frame), 50)];
}

-(void)searchFieldTextChange:(NSString *)searchString {
    [self search:searchString];
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
    
    
    NSRange range = NSMakeRange(1, self.list.count-1);
    
    NSArray *list = [self.list subarrayWithRange:range];
    
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeItem:obj tableRedraw:NO];
    }];
    
    [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:self.defaultAnimation];
    
    
    [self insert:sorted startIndex:1 tableRedraw:YES];
    
    
   

}

-(void)keyDown:(NSEvent *)theEvent {
     [self.searchView.searchField becomeFirstResponder];
    
    [self.searchView.searchField keyDown:theEvent];
}

-(BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *)item {
    return NO;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
