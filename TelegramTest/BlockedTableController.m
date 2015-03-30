//
//  BlockedTableController.m
//  Messenger for Telegram
//
//  Created by keepcoder on 07.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BlockedTableController.h"
#import "BlockedUsersManager.h"
#import "TGDateUtils.h"
#import "SelectUserItem.h"
@interface BlockedTableController ()
@end
@implementation BlockedTableController

@synthesize blockedList = _blockedList;
@synthesize isLocked = _isLocked;

-(void)didChangeBlockedUsers:(NSNotification *)notification {
    
    TL_contactBlocked *user = [notification.userInfo objectForKey:KEY_USER];
    
    [self beginUpdates];
    if([_blockedList indexOfObject:user] == NSNotFound)  {
        [self insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:_blockedList.count] withAnimation:NSTableViewAnimationEffectNone];
        
        [_blockedList addObject:user];
        
    } else {
        [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:[_blockedList indexOfObject:user]] withAnimation:NSTableViewAnimationEffectNone];
        
        [_blockedList removeObject:user];
        
    }
    [self endUpdates];
    
}



-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self.removeButton setEnabled:self.selectedRowIndexes.count > 0];
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
         _blockedList = [[[BlockedUsersManager sharedManager] all] mutableCopy];
        [Notification addObserver:self selector:@selector(didChangeBlockedUsers:) name:USER_BLOCK];
        self.delegate = self;
        self.dataSource = self;
       
    }
    
    return self;
}

-(void)setRemoveButton:(NSButton *)removeButton {
    self->_removeButton = removeButton;
    [self.removeButton setEnabled:self.selectedRowIndexes.count > 0];
}

-(void)addBlockedUsers:(NSArray *)items {
    
    CHECK_LOCKER(_isLocked);
    
    _isLocked = YES;
    
    NSMutableArray *users = [[NSMutableArray alloc] init];
    
    for (SelectUserItem *item in items) {
        [users addObject:@(item.user.n_id)];
    }
    
    [self unblock:users block:YES];
}

-(void)unblockSelected {
    
    CHECK_LOCKER(_isLocked);
    
     _isLocked = YES;
    
    NSMutableArray *users = [[NSMutableArray alloc] init];
    
    NSArray *selected = [_blockedList objectsAtIndexes:self.selectedRowIndexes];
    
    for (TL_contactBlocked *contact in selected) {
        [users addObject:@(contact.user_id)];
    }
    
    [self unblock:users block:NO];
}




-(void)unblock:(NSMutableArray *)list block:(BOOL)block {
    
    if(list.count == 0) {
        _isLocked = NO;
        return;
    }
    
    
    NSNumber *user_id = list[0];
    [list removeObjectAtIndex:0];
    
    [[BlockedUsersManager sharedManager] block:block user_id:[user_id intValue] completeHandler:^(BOOL response) {
        
        if(list.count > 0) {
            [self unblock:list block:block];
        } else {
            _isLocked = NO;
        }
        
    }];
}


-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _blockedList.count;
}



-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    TL_contactBlocked *contact = _blockedList[row];
    
    TLUser *user = [[UsersManager sharedManager] find:[contact user_id]];
    
    if([tableColumn.identifier isEqualToString:@"initials"]) {
        return user.fullName;
    }
    if([tableColumn.identifier isEqualToString:@"phone"]) {
        return user.phoneWithFormat;
    }
    
    return nil;
}

@end
