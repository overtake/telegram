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


typedef enum {
    SelectTableTypeUser,
    SelectTableTypeChats,
    SelectTableTypeCommon,
    SelectTableConversations
} SelectTableType ;

@protocol SelectTableDelegate <NSObject>

@required
-(void)selectTableDidChangedItem:(id)item;

@end

@interface SelectUsersTableView : TMTableView<TMTableViewDelegate>


@property (nonatomic,strong) NSArray *exceptions;

@property (nonatomic,strong) id <SelectTableDelegate> selectDelegate;

@property (nonatomic,copy) void (^multipleCallback)(NSArray *contacts);


@property (nonatomic,strong) NSArray *selectedItems;

-(void)addItems:(NSArray *)items;
-(void)removeSelectedItems;

@property (nonatomic,assign) NSUInteger selectLimit;

@property (nonatomic,assign,readonly) SelectTableType type;

- (BOOL) canSelectItem;

- (void)readyContacts;
- (void)readyChats;

- (void)readyConversations;

//SelectUserItems;
- (void)readyCommon:(NSArray *)items;

- (void)search:(NSString *)searchString;

@end
