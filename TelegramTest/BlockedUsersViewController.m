//
//  BlockedUsersViewController.m
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "BlockedUsersViewController.h"
#import "ComposeActionBlockUsersBehavior.h"
@interface BlockedUsersViewController () <TMTableViewDelegate>
@property (nonatomic,strong) BTRButton *addButton;
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) TMTextField *noBlockedUsersView;
@end

@implementation BlockedUsersViewController

-(void)loadView {
    [super loadView];
    
    
    [self setCenterBarViewText:NSLocalizedString(@"BlockedUsers.BlockedUsers", nil)];
    
    
    TMView *rightView = [[TMView alloc] init];
    
    
    NSImage *image = [NSImage imageNamed:@"AddBlockUser"];
    
    self.addButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image.size.width, image.size.height)];
    
    [self.addButton setBackgroundImage:image forControlState:BTRControlStateNormal];
    
    
    [self.addButton addTarget:self action:@selector(addBlockUsers) forControlEvents:BTRControlEventClick];
    
    [rightView setFrameSize:self.addButton.frame.size];
    
    
    [rightView addSubview:self.addButton];
    
    [self setRightNavigationBarView:rightView animated:NO];
    
    
    
    self.noBlockedUsersView = [TMTextField defaultTextField];
    
    [self.noBlockedUsersView setStringValue:NSLocalizedString(@"BlockedUsers.NoBlockedUsers", nil)];
    
    [self.noBlockedUsersView setAlignment:NSCenterTextAlignment];
    
    [self.noBlockedUsersView setTextColor:GRAY_TEXT_COLOR];
    
    [self.noBlockedUsersView setFrameSize:NSMakeSize(NSWidth(self.view.frame), 40)];
    
    [self.noBlockedUsersView setCenterByView:self.view];
    
    
    self.noBlockedUsersView.autoresizingMask = NSViewMinYMargin | NSViewMaxYMargin | NSViewWidthSizable;
    
    [self.view addSubview:self.noBlockedUsersView];
    
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    
    [self.view addSubview:self.tableView.containerView];

}

-(void)addBlockUsers {
    NSMutableArray *filter = [[NSMutableArray alloc] init];
    
    NSArray *all = [[BlockedUsersManager sharedManager] all];
    
    [all enumerateObjectsUsingBlock:^(TL_contactBlocked *obj, NSUInteger idx, BOOL *stop) {
        [filter addObject:@(obj.user_id)];
    }];
    
    
    
    [[Telegram rightViewController] showComposeWithAction:[[ComposeAction alloc] initWithBehaviorClass:[ComposeActionBlockUsersBehavior class] filter:filter object:self]];
}


-(void)updateView {
    [self.tableView.containerView setHidden:self.tableView.list.count == 0];
    
    [self.noBlockedUsersView setHidden:self.tableView.list.count > 0];
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *all = [[BlockedUsersManager sharedManager] all];
    
    [self.tableView removeAllItems:NO];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [all enumerateObjectsUsingBlock:^(TL_contact *obj, NSUInteger idx, BOOL *stop) {
        
        BlockedUserRowItem *item = [[BlockedUserRowItem alloc] initWithObject:obj];
                
        [items addObject:item];
    }];
    
    [self.tableView insert:items startIndex:0 tableRedraw:NO];
    
    [self.tableView reloadData];
    
    [self updateView];
    
    
    [Notification addObserver:self selector:@selector(didChangeBlockedUsers:) name:USER_BLOCK];
    
}


-(void)didChangeBlockedUsers:(NSNotification *)notification {
    
    TL_contactBlocked *user = [notification.userInfo objectForKey:KEY_USER];
    
    NSArray *filter = [self.tableView.list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.contact.user_id = %d",user.user_id]];
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
    if(filter.count == 0)  {
        
        BlockedUserRowItem *item = [[BlockedUserRowItem alloc] initWithObject:user];
        
        [self.tableView insert:item atIndex:self.tableView.count tableRedraw:YES];
   
    } else {
        [self.tableView removeItem:filter[0] tableRedraw:YES];
        [self.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:0]];
    }
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
    
    [self updateView];
    
}




-(void)viewWillDisappear:(BOOL)animated {
    [Notification removeObserver:self];
}


- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return row == 0 ? 103 : 50;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [self.tableView cacheViewForClass:[BlockedUserRowView class] identifier:@"BlockedUserRowView" withSize:NSMakeSize(NSWidth(self.view.frame), 60)];
}

- (void)selectionDidChange:(NSInteger)row item:(TMRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *) item {
    return NO;
}


@end
