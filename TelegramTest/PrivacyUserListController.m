//
//  PrivacyUserListController.m
//  Telegram
//
//  Created by keepcoder on 20.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PrivacyUserListController.h"
#import "PrivacyUserListItemView.h"
@interface PrivacyUserListController () <TMTableViewDelegate>
@property (nonatomic,strong) BTRButton *addButton;
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) TMTextField *noUsers;

@end

@implementation PrivacyUserListController


-(void)loadView {
    [super loadView];
    
    [self setCenterBarViewText:NSLocalizedString(@"PrivacyUserListController.Header", nil)];

    
    TMView *rightView = [[TMView alloc] init];
    
    
    NSImage *image = [NSImage imageNamed:@"AddBlockUser"];
    
    self.addButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image.size.width, image.size.height)];
    
    [self.addButton setBackgroundImage:image forControlState:BTRControlStateNormal];
    
    
    [self.addButton addTarget:self action:@selector(addUsers) forControlEvents:BTRControlEventClick];
    
    [rightView setFrameSize:self.addButton.frame.size];
    
    
    [rightView addSubview:self.addButton];
    
    [self setRightNavigationBarView:rightView animated:NO];
    
    
    
    self.noUsers = [TMTextField defaultTextField];
    
    [self.noUsers setStringValue:NSLocalizedString(@"PrivacyUserListController.NoUsers", nil)];
    
    [self.noUsers setAlignment:NSCenterTextAlignment];
    
    [self.noUsers setTextColor:GRAY_TEXT_COLOR];
    
    [self.noUsers setFrameSize:NSMakeSize(NSWidth(self.view.frame), 40)];
    
    [self.noUsers setCenterByView:self.view];
    
    
    self.noUsers.autoresizingMask = NSViewMinYMargin | NSViewMaxYMargin | NSViewWidthSizable;
    
    [self.view addSubview:self.noUsers];
    
    
    self.tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    self.tableView.tm_delegate = self;
    
    
    [self.view addSubview:self.tableView.containerView];
    
}


-(void)addUsers {
    if(self.addCallback)
        self.addCallback();
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Notification removeObserver:self];
    
    [self.privacy setValue:[self userIds] forKey:self.arrayKey];
    
   
}

-(void)updateView {
    [self.tableView.containerView setHidden:self.tableView.list.count == 0];
    
    [self.noUsers setHidden:self.tableView.list.count > 0];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.centerTextField setStringValue:self.title];
    
    
    [self.tableView removeAllItems:NO];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [[self.privacy valueForKey:self.arrayKey] enumerateObjectsUsingBlock:^(TL_contact *obj, NSUInteger idx, BOOL *stop) {
        
        PrivacyUserListItem *item = [[PrivacyUserListItem alloc] initWithObject:obj];
        
        item.controller = self;
        
        [items addObject:item];
    }];
    
    [self.tableView insert:items startIndex:0 tableRedraw:NO];
    
    [self.tableView reloadData];
    
    [self updateView];
    
}


//-(void)didChangeBlockedUsers:(NSNotification *)notification {
//    
//    TL_contactBlocked *user = [notification.userInfo objectForKey:KEY_USER];
//    
//    NSArray *filter = [self.tableView.list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.contact.user_id = %d",user.user_id]];
//    
//    self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
//    
//    if(filter.count == 0)  {
//        
//        BlockedUserRowItem *item = [[BlockedUserRowItem alloc] initWithObject:user];
//        
//        [self.tableView insert:item atIndex:self.tableView.count tableRedraw:YES];
//        
//    } else {
//        [self.tableView removeItem:filter[0] tableRedraw:YES];
//        [self.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:0]];
//    }
//    
//    self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
//    
//    [self updateView];
//    
//}



-(void)_didRemoveItem:(PrivacyUserListItem *)item {
    self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
    [self.tableView removeItem:item tableRedraw:YES];
    [self.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:0]];
   
    self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
        
    [self updateView];
}

-(NSArray *)userIds {
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [self.tableView.list enumerateObjectsUsingBlock:^(PrivacyUserListItem *obj, NSUInteger idx, BOOL *stop) {
        
        [ids addObject:@(obj.user.n_id)];
        
    }];
    
    return ids;
}

- (CGFloat)rowHeight:(NSUInteger)row item:(TMRowItem *) item {
    return row == 0 ? 103 : 50;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    return [self.tableView cacheViewForClass:[PrivacyUserListItemView class] identifier:@"PrivacyUserListItemView" withSize:NSMakeSize(NSWidth(self.view.frame), 60)];
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
