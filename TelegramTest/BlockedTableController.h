//
//  BlockedTableController.h
//  Messenger for Telegram
//
//  Created by keepcoder on 07.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlockedTableController : NSTableView<NSTableViewDataSource,NSTableViewDelegate>
@property (nonatomic,strong,readonly) NSMutableArray *blockedList;
@property (nonatomic,assign,readonly) BOOL isLocked;

@property (nonatomic,strong) NSButton *addButton;
@property (nonatomic,strong) NSButton *removeButton;

-(void)addBlockedUsers:(NSArray *)uids;
-(void)unblockSelected;
@end
