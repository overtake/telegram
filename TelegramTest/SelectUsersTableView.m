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
#import "TGSearchRowView.h"



@interface SelectUsersTableView ()<TMSearchTextFieldDelegate>
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) TGSearchRowView *searchView;
@property (nonatomic,strong) TGSearchRowItem *searchItem;
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
        item.isSelected = [_selectedItems indexOfObject:@(obj.user_id)] != NSNotFound;
        [items addObject:item];
        
        if(items.count == 30)
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
    
    
    self.tm_delegate = self;
    
    [self removeAllItems:NO];
    
    self.items = items;
    
    self.searchItem = [[TGSearchRowItem alloc] init];
    
    self.searchView = [[TGSearchRowView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.bounds), 50)];
    
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
             item.isSelected = [_selectedItems indexOfObject:@(obj.user_id)] != NSNotFound;
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
    
    NSArray *copy;
    
    if(self.list.count > 0) {
        if([self.list[0] isKindOfClass:[TGSearchRowItem class]]) {
            copy = [self.list subarrayWithRange:NSMakeRange(1, self.list.count-1)];
        } else {
            copy = [self.list copy];
        }
    } else {
        copy = [self.list copy];
    }
    
    
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
    
    if(self.list) {
        for (NSNumber *exception in exceptions) {
            
            NSArray *copy;
            
            if(self.list.count > 0) {
                if([self.list[0] isKindOfClass:[TGSearchRowItem class]]) {
                   copy = [self.list subarrayWithRange:NSMakeRange(1, self.list.count-1)];
                } else {
                    copy = [self.list copy];
                }
            } else {
                copy = [self.list copy];
            }
            
            [copy enumerateObjectsUsingBlock:^(SelectUserItem * obj, NSUInteger idx, BOOL *stop) {
                if(obj.contact.user_id == [exception intValue]) {
                    [self removeItem:obj];
                    [self.items removeObject:obj];
                    *stop = YES;
                }
            }];
        }
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
    
    
    __block NSArray *sorted = [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.contact.user.n_id != %d",[UsersManager currentUserId]]];
    
    
    if(searchString.length > 0) {
        sorted = [sorted filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self.contact.user.fullName contains[c] %@) OR (self.contact.user.fullName contains[c] %@) OR (self.contact.user.fullName contains[c] %@)",searchString,transformed,reversed]];
    }
    
    
    if(searchString.length >= 5) {
        NSArray *usernames = [UsersManager findUsersByName:searchString];
        
        
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        
        [sorted enumerateObjectsUsingBlock:^(SelectUserItem *obj, NSUInteger idx, BOOL *stop) {
            [ids addObject:@(obj.contact.user_id)];
        }];
        
        NSArray *usersByName = [usernames filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self.n_id IN %@)",ids]];
        
        [usersByName enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
            
            if([obj isKindOfClass:[TL_userContact class]]) {
                sorted = [sorted arrayByAddingObject:[[SelectUserItem alloc] initWithObject:obj.contact]];
            }
            
        }];
    }
    
    
    
    
    
    NSRange range = NSMakeRange(1, self.list.count-1);
    
    NSArray *list = [self.list subarrayWithRange:range];
    
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeItem:obj tableRedraw:NO];
    }];
    
    [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:self.defaultAnimation];
    
    
    [self insert:sorted startIndex:1 tableRedraw:YES];
    
    
   

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
