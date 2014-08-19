//
//  SelectUsersTableView.h
//  Messenger for Telegram
//
//  Created by keepcoder on 21.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTableView.h"
#import "SelectUserRowView.h"
#import "SelectUserItem.h"
@interface SelectUsersTableView : TMTableView<TMTableViewDelegate>

typedef enum {
    SelectUsersTypeSingle = 1 << 1,
    SelectUsersTypeMultiple = 1 << 2
} SelectUsersType;

@property (nonatomic,assign) SelectUsersType selectType;

@property (nonatomic,strong) NSArray *exceptions;

@property (nonatomic,copy) void (^singleCallback)(TGContact *contact);
@property (nonatomic,copy) void (^multipleCallback)(NSArray *contacts);


@property (nonatomic,strong, readonly) NSArray *selectedItems;

@property (nonatomic,assign) NSUInteger selectLimit;

- (BOOL) canSelectItem;

- (void)ready;

- (void)search:(NSString *)searchString;

@end
