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

@protocol SelectTableDelegate <NSObject>

@required
-(void)selectTableDidChangedItem:(SelectUserItem *)item;

@end

@interface SelectUsersTableView : TMTableView<TMTableViewDelegate>


@property (nonatomic,strong) NSArray *exceptions;

@property (nonatomic,strong) id <SelectTableDelegate> selectDelegate;

@property (nonatomic,copy) void (^multipleCallback)(NSArray *contacts);


@property (nonatomic,strong, readonly) NSArray *selectedItems;

@property (nonatomic,assign) NSUInteger selectLimit;

- (BOOL) canSelectItem;

- (void)ready;

- (void)search:(NSString *)searchString;

@end
